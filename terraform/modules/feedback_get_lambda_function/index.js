// set up rest api, lambda and domain name:
// https://hands-on.cloud/terraform-api-gateway/#:~:text=Setting%20up%20the%20API%20Gateway%20Module,-At%20the%20root&text=To%20manage%20the%20API%20Gateway,or%20import%20an%20API%20key.&text=Replace%20the%20default%20value%20as,enter%20these%20values%20at%20runtime.

// setup dynamodb table, lambdas for CRUD and State Locking in Terraform
// https://dynobase.dev/dynamodb-terraform/


// https://repost.aws/knowledge-center/lambda-kmsaccessdeniedexception-errors

// https://github.com/awsdocs/aws-doc-sdk-examples/blob/main/javascript/example_code/dynamodb/ddb_getitem.js
// https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/dynamodb-example-query-scan.html
// https://stackoverflow.com/questions/43708017/aws-lambda-api-gateway-error-malformed-lambda-proxy-response

// https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/dynamodb-example-table-read-write.html

// you have to use POST in th epostman call even for your get feedback lambda call.  see article below.
// https://stackoverflow.com/questions/41371970/accessdeniedexception-unable-to-determine-service-operation-name-to-be-authoriz


// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');

// Set the region 
AWS.config.update({region: 'us-east-1'});

// Create the DynamoDB service object
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});

const {createLogger} = require('./createLogger')
const logger = createLogger('feedback_get_lambda_function')
// const REGISTRATION_TABLE = process.env.REGISTRATION_TABLE; // obtaining the table name
const FEEDBACK_TABLE = 'feedback_table-Prod'
const CORS_ALLOWED_ORIGIN = "*";


const QUERY_THRESHOLD_IN_MILILSECONDS = 30000

/**

 * Usage

 * Query priority. batchId > claimNumber > recordSource = status > timeStart = timeEnd

 * If given a batchId, all other params will be ignored and all records returned.

 * If given a claimNumber, but no batchId, all other params will be ignored and all records returned.

 * If given a recordSource and/or status, timeStart and timeEnd are required.

 * Must give at least one of batchId, claimNumber, recordSource or status.
 */
const baseDbQuery = {
   TableName: FEEDBACK_TABLE
}


const emailIndexQuery = {
  ...baseDbQuery,
  IndexName: 'emailIndex'
}

const phoneIndexQuery = {
  ...baseDbQuery,
  IndexName: 'phoneIndex'
}

const statusIndexQuery = {
  ...baseDbQuery,
  IndexName: 'statusIndex'
}

const registrationTypeIndexQuery = {
   ...baseDbQuery,
   IndexName: 'registrationTypeIndex'
}
 

// Must explicitly include ProjectionExpression on all queries. This prevents PII from being returned

// by the DB and keeps this api clean from all PII.

// Attributes that may contain PII and must be left out: ThirdPartyEmail, ThirdPartyName.

const baseProjection = '#status, startTime, registrationType, firstName, lastName, phone, email'

 

// This function builds out the DB query based on the query string from the API. With 6 query string

// parameters, there are 63 possible combinations of parameters, each requiring a different DB query or error msg.

// To reduce the code needed to build the DB query, early returns are used in combination with an array

// map so that a DB query or error message is returned for every possible combination.

const buildDbQuery = (queryStringParameters) => {

  if (!Object.keys(queryStringParameters).length) {

    return {

      error: 'Query params are required.'

    }

  }

  const sentParams = Object.keys(queryStringParameters).filter(key => queryStringParameters[key])

  const { createdAt, email, phone, status, startTime, endTime } = queryStringParameters

 

  // Query string priority. batchId and claimNumber will short circuit and ignore other params.
  if (email) {
    return {
      ...emailIndexQuery,
      KeyConditionExpression: '#email = :email',

      // Explicit projection expression to prevent any PII from being returned from the DB.
      ProjectionExpression: baseProjection,
      ExpressionAttributeValues: {
        ':email': {S: email}
      },
      ExpressionAttributeNames: {
        '#email': 'email',
        '#status': 'status'
      }
    }
  }

  if (phone) {
    return {
      ...phoneIndexQuery,
      KeyConditionExpression: '#phone = :phone',

      // Explicit projection expression to prevent any PII from being returned from the DB.
      ProjectionExpression: baseProjection,
      ExpressionAttributeValues: {
        ':phone': phone
      },
      ExpressionAttributeNames: {
        '#phone': 'phone',
        '#status': 'status'
      }
    }
  }

  // createdAt and status queries require start and end.
  if (status && !(startTime && endTime)) {
    return {
      error: 'Queries for status must include a start and end.'
    }
  }

  if (startTime && endTime && Number(startTime) >= Number(endTime)) {
    return {
      error: 'Queries contianing start and end must have a end after start.'
    }
  }

 

  // For remaining possible query params, use the following map.
  const paramDbQueryMap = [
    {
      params: ['startTime'],
      dbQuery: {
        error: 'Queries must contain registrationType, or status.'
      }
    },
    {

      params: ['endTime'],
      dbQuery: {
        error: 'Queries must contain registrationType, or status.'
      }
    },
    {

      // timeStart and timeEnd would require a scan instead of a query, so it is disallowed.
      params: ['startTime', 'endTime'],
      dbQuery: {
        error: 'Queries must contain createdAt, or status.'
      }
    },
    {
      params: ['registrationType', 'startTime', 'endTime'],
      dbQuery: {
        ...createdAtIndexQuery,
        KeyConditionExpression: '#registrationType = :registrationType AND #createdAt BETWEEN :startTime AND :endTime',

        // Explicit projection expression to prevent any PII from being returned from the DB.
        ProjectionExpression: '#createdAt, startTime, endTime, ' + baseProjection,
        ScanIndexForward: false, // Get results by descending order.

        ExpressionAttributeValues: {
          ':registrationType': registrationType,
          ':startTime': Number(startTime),
          ':endTime': Number(endTime)
        },

        ExpressionAttributeNames: {
          '#registrationType': 'registrationType',
          '#createdAt': 'createdAt',
          '#status': 'status'
        }
      }
    },
    {

      params: ['registrationType', 'status', 'startTime', 'endTime'],
      dbQuery: {
        ...registrationTypeIndexQuery,
        KeyConditionExpression: '#registrationType = :registrationType AND #createdAt BETWEEN :start AND :end',

        // Explicit projection expression to prevent any PII from being returned from the DB.
        ProjectionExpression: 'startTime, endTime, ' + baseProjection,
        FilterExpression: '#status = :sts',
        ScanIndexForward: false, // Get results by descending order.

        ExpressionAttributeValues: {
          ':registrationType': registrationType,
          ':start': Number(startTime),
          ':end': Number(endTime),
          ':sts': status
        },

        ExpressionAttributeNames: {
          '#registrationType': 'registrationType',
          '#createdAt': 'createdAt',
          '#status': 'status'
        }
      }
    },
    {

      params: ['status', 'startTime', 'endTime'],
      dbQuery: {
        ...statusIndexQuery,
        KeyConditionExpression: '#status = :status AND #createdAt BETWEEN :startTime AND :endTime',

        // This query's index does not include the baseProjection Attributes, so baseProjection is not needed.

        ProjectionExpression: baseProjection,

        ScanIndexForward: false, // Get results by descending order.

        ExpressionAttributeValues: {
          ':status': status,
          ':start': Number(startTime),
          ':end': Number(endTime)
        },

        ExpressionAttributeNames: {
          '#status': 'status',
          '#createdAt': 'createdAt'

        }

      }

    }

  ]

 

  const queryMatch = paramDbQueryMap.find(map => {

    if (map.params.length !== sentParams.length) return false

    return map.params.every(param => {

      return sentParams.includes(param)

    })

  })

 

  return queryMatch

    ? queryMatch.dbQuery

    : {

        error: 'Queries must contain cratedAt, email, registrationType, or status.'

      }

}

 



exports.handler = async (event) => {
   console.log(`index.js get-feedback start`)
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

   const dbQuery = buildDbQuery(event.queryStringParameters)

   if (dbQuery.error) {

      logger('invalid parameters were passed in')

      return {

        body: `Invalid parameters: ${JSON.stringify(event.queryStringParameters)}.

          Error: ${dbQuery.error}`,

        headers: {

          'Content-Type': 'application/json',

          'Access-Control-Allow-Origin': "*"

        },

        statusCode: 400

      }

    }

    
    let result

    try{
      const queryStart = Date.now()
      result = await ddb.query(dbQuery).promise()
      const queryEnd = Date.now()
      const queryTime = queryEnd - queryStart
       logger('get_upload_diagnostics_query', { queryRunTimeMilliSec: queryTime })
    } catch (err){
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
         console.log(`index.js get-feedback end`)
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
    }
    

  



//    // const {email, phone} = event.queryStringParameters          // destructuring to get passed in query info
//    const { email, phone, status, start, end } = event.queryStringParameters
//    console.log(`email: ${email}`)
//    console.log(`phone: ${phone}`)

//   const params = {
//       IndexName: 'emailIndex',
//       ExpressionAttributeValues: {
//          ':e': {S: email},
//          ':p' : {S: phone}
//       // ':topic' : {S: 'PHRASE'}
//       },
//       ExpressionAttributeNames:{
//          '#email' : 'email',
//          '#status' : 'status',
//          '#phone' : 'phone',
//       },
//       KeyConditionExpression: '#email = :e AND #phone = :p',
//       ProjectionExpression: '#status, registrationType, firstName, lastName, phone',
//       // FilterExpression: 'contains (Subtitle, :topic)',
//       ConsistentRead: false,
//       TableName: FEEDBACK_TABLE
//    };

//    console.log(`params: ${JSON.stringify(params, null, 4)}`)
  
   
//    try{
//       result = await ddb.query(params).promise()
//    } catch(err){
//       console.log("Error", err);
//       const failureResponse = {
//          statusCode: 400,
//          body: JSON.stringify(err),
//          headers: {
//             "Content-Type": "application/json",
//             "Access-Control-Allow-Headers": "Content-Type",
//             "Access-Control-Allow-Origin" : "*",
//             "Access-Control-Allow-Methods": "OPTIONS,GET"
//          },
//          isBase64Encoded: false
//       }

//       return failureResponse
//    } finally{
//       console.log(`index.js get-feedback end`)
//    }

//    const successResponse = {
//       statusCode: 200,
//       headers: {
//          "Content-Type": "application/json",
//          "Access-Control-Allow-Headers": "Content-Type",
//          "Access-Control-Allow-Origin" : "*",
//          "Access-Control-Allow-Methods": "OPTIONS,GET",
//          "Access-Control-Allow-Credentials" : true // Required for cookies, authorization headers with HTTPS
//       },
//       body:  JSON.stringify(result), //sending the array of registrations as stringified JSON in the response
//    }
   
//    return successResponse
// };