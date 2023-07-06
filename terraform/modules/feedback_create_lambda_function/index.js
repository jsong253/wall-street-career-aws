// https://hands-on.cloud/terraform-api-gateway/#:~:text=Setting%20up%20the%20API%20Gateway%20Module,-At%20the%20root&text=To%20manage%20the%20API%20Gateway,or%20import%20an%20API%20key.&text=Replace%20the%20default%20value%20as,enter%20these%20values%20at%20runtime.
// https://repost.aws/knowledge-center/lambda-kmsaccessdeniedexception-errors

// setup dynamodb table, lambdas for CRUD and State Locking in Terraform
// https://dynobase.dev/dynamodb-terraform/

// https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-dynamo-db.html
const FEEDBACK_TABLE = 'feedback_table-Prod';
const AWS = require("aws-sdk"); 
const documentClient = new AWS.DynamoDB.DocumentClient();

const uuid = ()=>
([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, (a) =>
  (a ^ ((Math.random() * 16) >> (a / 4))).toString(16)
)

exports.handler = async (event) => {
  console.log(`index.js create-feedback start`)

  const errors = []
  const records = []
  console.log(`event: ${JSON.stringify(event, null, 4)}`)

  const body = JSON.parse(event.body)

  console.log(` body: ${JSON.stringify(body, null, 4)}`)

  // Store date and time in human-readable format in a variable
  let now = date.toISOString();

  const currentDate = Date.now();

  const newItem = {
    ...body,
    start: currentDate.toUTCString(), 
    // createdAt: new Date().getTime(),
    createdAt: currentDate.getTime(),
    // createdAt: `${new Date(new Date().toISOString()).getTime()}`,
    ID: uuid(),
    expiryPeriod: this.getTTLTimestamp(new Date(), 31), // specify TTL
  };
   
  console.log(`newItem: ${JSON.stringify( newItem, null, 4)}`)
  // insert it to the table
  try{
    await documentClient
    .put({
      TableName: FEEDBACK_TABLE,
      Item: newItem,
     })
    .promise();
    records.push(newItem)
    
  } catch (e){
    console.log(`Error when saving feedback data into dynamodb table: ${JSON.stringify(e, null, 4)}`)
    errors.push(e)
  } finally{
    console.log(`index.js create-feedback end`)
  }

  if (errors.length > 0) {
    const failureResponse = {
      statusCode: 400,
      body: JSON.stringify(errors),
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Origin" : "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST"
      },
      isBase64Encoded: false
    }

    return failureResponse
  }
 
  const successResponse = {
    statusCode: 200,
    body: JSON.stringify(records,null,4),
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Allow-Origin" : "*",
      "Access-Control-Allow-Methods": "OPTIONS,POST",
      "Access-Control-Allow-Credentials" : true             // Required for cookies, authorization headers with HTTPS
    },
    isBase64Encoded: false
  }

  return successResponse
}

exports.getTTLTimestamp = (timestamp, daysToAdd)=>{
  const millsecondPerSecond = 1000

  const days = parseInt(daysToAdd)
  const newTimestamp = new Date(timestamp).setDate(timestamp.getDate() + days)

  return Math.floor(newTimestamp/millsecondPerSecond)
}


