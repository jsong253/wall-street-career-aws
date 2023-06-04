// https://hands-on.cloud/terraform-api-gateway/#:~:text=Setting%20up%20the%20API%20Gateway%20Module,-At%20the%20root&text=To%20manage%20the%20API%20Gateway,or%20import%20an%20API%20key.&text=Replace%20the%20default%20value%20as,enter%20these%20values%20at%20runtime.
exports.handler = async (event) => {
  console.log(`index.js authorize-lambda-function start`)
  const errors = []
  const records = []
  const data = JSON.parse(event.body)

  console.log(`data: ${JSON.stringify(data, null, 4)}`)

  if (errors.length > 0) {
    const failureResponse = {
      statusCode: 400,
      body: JSON.stringify(errors),
      headers: {},
      isBase64Encoded: false
    }

    return failureResponse
  }
 
  const successResponse = {
    statusCode: 200,
    body: JSON.stringify(records),
    headers: {},
    isBase64Encoded: false
  }

  console.log(`index.js authorize-lambda-function end`)
  return successResponse
}
