const aws = require('aws-sdk')

const mc = new AWS.MediaConvert({
    apiVersion: '2017-08-29',
    // "describeEndpoints" is heavily rate limited and endpoint does not change per AWS account
    endpoint: process.env.MEDIACONVERT_ENDPOINT,
})

const createJob = (params) => {
    return mc.createJob(params).promise()
}

module.exports = {
    createJob  
}