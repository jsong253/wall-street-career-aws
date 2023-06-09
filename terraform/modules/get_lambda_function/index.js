// set up rest api, lambda and domain name:
// https://hands-on.cloud/terraform-api-gateway/#:~:text=Setting%20up%20the%20API%20Gateway%20Module,-At%20the%20root&text=To%20manage%20the%20API%20Gateway,or%20import%20an%20API%20key.&text=Replace%20the%20default%20value%20as,enter%20these%20values%20at%20runtime.

// setup dynamodb table, lambdas for CRUD and State Locking in Terraform
// https://dynobase.dev/dynamodb-terraform/


// https://repost.aws/knowledge-center/lambda-kmsaccessdeniedexception-errors

// https://github.com/awsdocs/aws-doc-sdk-examples/blob/main/javascript/example_code/dynamodb/ddb_getitem.js
// https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/dynamodb-example-query-scan.html
// https://stackoverflow.com/questions/43708017/aws-lambda-api-gateway-error-malformed-lambda-proxy-response

// https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/dynamodb-example-table-read-write.html

// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');

// Set the region 
AWS.config.update({region: 'us-east-1'});

// Create the DynamoDB service object
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});

// const REGISTRATION_TABLE = process.env.REGISTRATION_TABLE; // obtaining the table name
const REGISTRATION_TABLE = 'registration_table-Prod'
const CORS_ALLOWED_ORIGIN = "*";

exports.handler = async (event) => {
   console.log(`index.js get-registrations start`)
   // console.log(`event: ${JSON.stringify(event, null, 4)}`)
   
   // need to check the passed in parameters and query the dynamoDB to see if there is a match in the registration table
   if (!event.queryStringParameters) {
      return {
         body: 'Query params are required',
         headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': "${var.cors_allowed_origin}"
         },
         statusCode: 400
      }
   }

   console.log(`event.queryStringParameters: ${JSON.stringify(event.queryStringParameters, null, 4)}`)

   const {email, password} = event.queryStringParameters          // destructuring to get passed in query info
   console.log(`email: ${email}`)
   console.log(`password: ${password}`)

  const params = {
      IndexName: 'emailIndex',
      ExpressionAttributeValues: {
         ':e': {S: email},
         ':p' : {S: password}
      // ':topic' : {S: 'PHRASE'}
      },
      ExpressionAttributeNames:{
         '#email' : 'email',
         '#status' : 'status',
         '#password' : 'password',
      },
      KeyConditionExpression: '#email = :e AND #password = :p',
      ProjectionExpression: '#status, registrationType, firstName, lastName, phone',
      // FilterExpression: 'contains (Subtitle, :topic)',
      ConsistentRead: false,
      TableName: REGISTRATION_TABLE
   };

   console.log(`params: ${JSON.stringify(params, null, 4)}`)
  
   let result
   
   try{
      result = await ddb.query(params).promise()
   } catch(err){
      console.log("Error", err);
      const failureResponse = {
         statusCode: 400,
         body: JSON.stringify(err),
         headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Origin" : "*",
            "Access-Control-Allow-Methods": "OPTIONS,GET"
         },
         isBase64Encoded: false
      }

      return failureResponse
   } finally{
      console.log(`index.js get-registrations end`)
   }

   const successResponse = {
      statusCode: 200,
      headers: {
         "Content-Type": "application/json",
         "Access-Control-Allow-Headers": "Content-Type",
         "Access-Control-Allow-Origin" : "*",
         "Access-Control-Allow-Methods": "OPTIONS,GET",
         "Access-Control-Allow-Credentials" : true // Required for cookies, authorization headers with HTTPS
      },
      body:  JSON.stringify(result), //sending the array of registrations as stringified JSON in the response
   }
   
   return successResponse
};