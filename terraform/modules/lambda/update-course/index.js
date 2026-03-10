const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({ region: "eu-central-1" });
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event, context) => {
  try {
    // Parse the body if it's a string (API Gateway format)
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event;
    
    const courseItem = {
      id: body.id,
      title: body.title,
      watchHref: body.watchHref,
      authorId: body.authorId,
      length: body.length,
      category: body.category
    };

    const params = {
      TableName: "courses",
      Item: courseItem
    };

    await docClient.send(new PutCommand(params));

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(courseItem)
    };
  } catch (err) {
    console.error("Error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message })
    };
  }
};

