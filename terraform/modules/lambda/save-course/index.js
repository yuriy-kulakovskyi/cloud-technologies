const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({ region: "eu-central-1" });
const docClient = DynamoDBDocumentClient.from(client);

const replaceAll = (str, find, replace) => {
  return str.replace(new RegExp(find, "g"), replace);
};

exports.handler = async (event, context) => {
  try {
    // Parse the body if it's a string (API Gateway format)
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event;
    
    const id = replaceAll(body.title, " ", "-").toLowerCase();
    const courseItem = {
      id: id,
      title: body.title,
      watchHref: `http://www.pluralsight.com/courses/${id}`,
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