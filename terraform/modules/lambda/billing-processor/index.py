# Billing Notification Processor Lambda
# Receives SNS notifications from billing alarms and forwards to Slack

import json
import logging
import os
import urllib3

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

http = urllib3.PoolManager()

def lambda_handler(event, context):
    """Process billing alarm notifications and send to Slack"""
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Extract SNS message
        if 'Records' not in event or len(event['Records']) == 0:
            logger.warning("No Records found in event")
            return {'statusCode': 400, 'body': 'No SNS records found'}
        
        sns_record = event['Records'][0]
        sns_message = json.loads(sns_record['Sns']['Message'])
        
        # Extract alarm details
        alarm_name = sns_message.get('AlarmName', 'Unknown')
        new_state = sns_message.get('NewStateValue', 'UNKNOWN')
        reason = sns_message.get('NewStateReason', 'No reason provided')
        timestamp = sns_message.get('StateChangeTime', 'Unknown time')
        
        # Extract threshold and current value from trigger
        trigger = sns_message.get('Trigger', {})
        threshold = trigger.get('Threshold', 'N/A')
        metric_name = trigger.get('MetricName', 'N/A')
        
        # Determine emoji and color based on state
        if new_state == 'ALARM':
            emoji = '🚨'
            color = '#FF0000'  # Red
            state_text = 'ALARM - Action Required!'
        elif new_state == 'OK':
            emoji = '✅'
            color = '#00FF00'  # Green
            state_text = 'OK - Back to Normal'
        else:
            emoji = '⚠️'
            color = '#FFA500'  # Orange
            state_text = new_state
        
        # Send to Slack
        send_to_slack(alarm_name, state_text, reason, threshold, timestamp, emoji, color)
        
        return {
            'statusCode': 200,
            'body': json.dumps('Billing notification processed successfully')
        }
        
    except Exception as e:
        logger.error(f"Error processing billing alarm: {e}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }


def send_to_slack(alarm_name, state, reason, threshold, timestamp, emoji, color):
    """Send formatted notification to Slack"""
    slack_webhook_url = os.environ.get('SLACK_WEBHOOK_URL')
    
    if not slack_webhook_url:
        logger.warning("SLACK_WEBHOOK_URL not configured, skipping Slack notification")
        return
    
    try:
        slack_message = {
            "text": f"{emoji} AWS Billing Alarm: {alarm_name}",
            "attachments": [
                {
                    "color": color,
                    "blocks": [
                        {
                            "type": "header",
                            "text": {
                                "type": "plain_text",
                                "text": f"{emoji} Billing Alert: {alarm_name}"
                            }
                        },
                        {
                            "type": "section",
                            "fields": [
                                {
                                    "type": "mrkdwn",
                                    "text": f"*Status:*\n{state}"
                                },
                                {
                                    "type": "mrkdwn",
                                    "text": f"*Threshold:*\n${threshold} USD"
                                }
                            ]
                        },
                        {
                            "type": "section",
                            "text": {
                                "type": "mrkdwn",
                                "text": f"*Reason:*\n{reason}"
                            }
                        },
                        {
                            "type": "context",
                            "elements": [
                                {
                                    "type": "mrkdwn",
                                    "text": f"⏰ {timestamp}"
                                }
                            ]
                        },
                        {
                            "type": "section",
                            "text": {
                                "type": "mrkdwn",
                                "text": "<https://console.aws.amazon.com/billing/home|View AWS Billing Dashboard> | <https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#alarmsV2:|View CloudWatch Alarms>"
                            }
                        }
                    ]
                }
            ]
        }
        
        encoded_msg = json.dumps(slack_message).encode('utf-8')
        resp = http.request(
            'POST',
            slack_webhook_url,
            body=encoded_msg,
            headers={'Content-Type': 'application/json'}
        )
        
        if resp.status == 200:
            logger.info(f"Slack notification sent for {alarm_name}")
        else:
            logger.error(f"Slack notification failed with status {resp.status}: {resp.data}")
            
    except Exception as e:
        logger.error(f"Slack notification error: {e}", exc_info=True)
