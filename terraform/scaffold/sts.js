//for mocking, this file is not to be tested.
const aws = require('aws-sdk')
const sts = new aws.STS({ apiVersion: '2011-06-15' })

const assumeRole = (params) => {
    return sts.assumeRole(params).promise()
}

module.exports = {
    assumeRole
}