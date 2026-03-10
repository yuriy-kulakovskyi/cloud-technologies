# Error Processing Lambda Function
# This function processes CloudWatch log events and sends notifications to SNS (email) and Slack

import base64
import boto3
import gzip
import json
import logging
import os
import urllib3
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

http = urllib3.PoolManager()

def logpayload(event):
    """Decode and decompress CloudWatch log data"""
    logger.setLevel(logging.DEBUG)
    
    # Validate event structure
    if 'awslogs' not in event:
        raise ValueError("Invalid event structure: missing 'awslogs' key. This function expects CloudWatch Logs events.")
    
    if 'data' not in event['awslogs']:
        raise ValueError("Invalid event structure: missing 'data' key in awslogs.")
    
    logger.debug(event['awslogs']['data'])
    compressed_payload = base64.b64decode(event['awslogs']['data'])
    uncompressed_payload = gzip.decompress(compressed_payload)
    log_payload = json.loads(uncompressed_payload)
    return log_payload


def error_details(payload):
    """Extract error details from log payload"""
    error_msg = ""
    log_events = payload['logEvents']
    logger.debug(payload)
    loggroup = payload['logGroup']
    logstream = payload['logStream']
    lambda_func_name = loggroup.split('/')
    logger.debug(f'LogGroup: {loggroup}')
    logger.debug(f'Logstream: {logstream}')
    logger.debug(f'Function name: {lambda_func_name[3]}')
    logger.debug(log_events)
    
    for log_event in log_events:
        error_msg += log_event['message']
    
    logger.debug('Message: %s' % error_msg.split("\n"))
    return loggroup, logstream, error_msg, lambda_func_name


def publish_to_sns(loggroup, logstream, error_msg, lambda_func_name):
    """Send notification to SNS (email)"""
    sns_arn = os.environ.get('SNS_TOPIC_ARN')
    
    if not sns_arn:
        logger.warning("SNS_TOPIC_ARN not configured, skipping email notification")
        return
    
    snsclient = boto3.client('sns')
    try:
        message = ""
        message += "\nLambda error summary\n\n"
        message += "##########################################################\n"
        message += f"# Function Name: {lambda_func_name[3]}\n"
        message += f"# LogGroup: {loggroup}\n"
        message += f"# LogStream: {logstream}\n"
        message += "# Error Message:\n"
        message += f"# \t{str(error_msg.split(chr(10)))}\n"
        message += "##########################################################\n"
        message += f"\nView logs: https://console.aws.amazon.com/cloudwatch/home?region={os.environ.get('DEPLOYMENT_REGION', 'us-east-1')}#logsV2:log-groups/log-group/{loggroup.replace('/', '$252F')}\n"

        snsclient.publish(
            TargetArn=sns_arn,
            Subject=f'⚠️ Lambda Error: {lambda_func_name[3]}',
            Message=message
        )
        logger.info(f"Email notification sent via SNS for {lambda_func_name[3]}")
    except ClientError as e:
        logger.error(f"SNS publish error: {e}")


def publish_to_slack(loggroup, logstream, error_msg, lambda_func_name):
    """Send notification to Slack"""
    slack_webhook_url = os.environ.get('SLACK_WEBHOOK_URL')
    
    if not slack_webhook_url:
        logger.warning("SLACK_WEBHOOK_URL not configured, skipping Slack notification")
        return
    
    try:
        # Truncate error message if too long
        error_preview = error_msg[:500] + "..." if len(error_msg) > 500 else error_msg
        
        slack_message = {
            "text": f"⚠️ Lambda Function Error Detected",
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": f"⚠️ Error in {lambda_func_name[3]}"
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": f"*Function:*\n{lambda_func_name[3]}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Log Group:*\n`{loggroup}`"
                        }
                    ]
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": f"*Error Message:*\n```{error_preview}```"
                    }
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": f"<https://console.aws.amazon.com/cloudwatch/home?region={os.environ.get('DEPLOYMENT_REGION', 'us-east-1')}#logsV2:log-groups/log-group/{loggroup.replace('/', '$252F')}|View Logs in CloudWatch>"
                    }
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
            logger.info(f"Slack notification sent for {lambda_func_name[3]}")
        else:
            logger.error(f"Slack notification failed with status {resp.status}: {resp.data}")
            
    except Exception as e:
        logger.error(f"Slack publish error: {e}")


def lambda_handler(event, context):
    """Main Lambda handler"""
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Parse CloudWatch log event
        pload = logpayload(event)
        lgroup, lstream, errmessage, lambdaname = error_details(pload)
        
        # Send notifications
        publish_to_sns(lgroup, lstream, errmessage, lambdaname)
        publish_to_slack(lgroup, lstream, errmessage, lambdaname)
        
        return {
            'statusCode': 200,
            'body': json.dumps('Notifications sent successfully')
        }
    except ValueError as ve:
        logger.error(f"Validation error: {ve}")
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': 'Invalid event structure',
                'message': str(ve),
                'expected_format': 'CloudWatch Logs subscription filter event with awslogs.data field'
            })
        }
    except Exception as e:
        logger.error(f"Error processing log event: {e}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal processing error',
                'message': str(e)
            })
        }
