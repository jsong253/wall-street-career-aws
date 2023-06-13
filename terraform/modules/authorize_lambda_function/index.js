// https://hands-on.cloud/terraform-api-gateway/#:~:text=Setting%20up%20the%20API%20Gateway%20Module,-At%20the%20root&text=To%20manage%20the%20API%20Gateway,or%20import%20an%20API%20key.&text=Replace%20the%20default%20value%20as,enter%20these%20values%20at%20runtime.


// const { verifyToken, verifyBrowserToken } = require('../../scaffold/okta')
const { verifyToken } = require('./okta')                 // gt it from lambda layer
const { createLogger } = require('./createLogger')
const logger = createLogger('authorize_lambda_function')

exports.handler = async (event) => {
  logger('authorize_lambda begin')

  const expectedAud = 'https://travelers-dev.oktapreview.com/oauth2/aus130rsqrd51M6HQ0h8'
  const tokenString = event.authorizationToken.replace(/bearer\s/ig, '').trim()
  let authorized = false

  try {
    await verifyToken(tokenString, expectedAud)
    authorized = true
  } catch (e) {
    logger('Token verification failed', { message: e })
  }

  logger('authorize_lambda end')
  
  const authPolicy = {
    principalId: 'na',
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: 'Allow',
          Resource: event.methodArn
        }
      ]
    }
  }

  const denyPolicy = {
    principalId: 'na',
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: 'Deny',
          Resource: event.methodArn
        }
      ]
    }
  }
  return authorized ? authPolicy : denyPolicy
}