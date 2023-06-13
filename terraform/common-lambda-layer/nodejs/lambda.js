//for mocking, this file is not to be tested.

const aws = require('aws-sdk')
const lambda = new aws.Lambda()

const invoke = (params) => {
    return lambda.invoke(params).promise()
}


module.exports = {
   invoke
}