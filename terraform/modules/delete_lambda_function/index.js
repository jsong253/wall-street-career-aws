// https://dynobase.dev/dynamodb-terraform/

// https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-dynamo-db.html     // need to do this


const AWS = require("aws-sdk");
const REGISTRATION_TABLE = 'registration_table-Prod';

const documentClient = new AWS.DynamoDB.DocumentClient();

module.exports.handler = async (event, context) => {
console.log(`index.js delete-registrations start`)

 const id = event.body.id;
 let result

 console.log(`event.body: ${JSON.stringify( event.body, null, 4)}`)

 console.log(`id: ${id}`)

 result = await documentClient
   .delete({
     TableName: REGISTRATION_TABLE,
     Key: {
       ID: id,
     },
 }).promise();

       
 const successResponse = {
    statusCode: 200,
    body: JSON.stringify(result),
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Allow-Origin" : "*",
      "Access-Control-Allow-Methods": "OPTIONS,POST",
      "Access-Control-Allow-Credentials" : true             // Required for cookies, authorization headers with HTTPS
    },
    isBase64Encoded: false
  }

  console.log(`index.js delete-registrations end`)
  return successResponse
}
