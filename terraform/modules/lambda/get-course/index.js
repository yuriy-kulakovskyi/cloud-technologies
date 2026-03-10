const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({ region: "eu-central-1" });
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event, context) => {
  try {
    // Parse the body if it's a string (API Gateway format)
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event;
    const id = body.id || event.id;

    const params = {
      TableName: "courses",
      Key: {
        id: id
      }
    };

    const data = await docClient.send(new GetCommand(params));

    if (!data.Item) {
      return {
        statusCode: 404,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
        body: JSON.stringify({ error: "Course not found" })
      };
    }

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(data.Item)
    };
  } catch (err) {
    console.error("Error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message })
    };
  }
};

