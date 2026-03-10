const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, DeleteCommand } = require("@aws-sdk/lib-dynamodb");

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

    await docClient.send(new DeleteCommand(params));

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify({ message: "Course deleted successfully", id: id })
    };
  } catch (err) {
    console.error("Error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message })
    };
  }
};

