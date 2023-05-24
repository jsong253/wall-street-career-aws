//for mocking, this file is not to be tested.

const aws = require('aws-sdk')

const sm = new aws.SecretsManager({ region: 'us-east-1' })

 

const getSecretValue = (params) => {

    return sm.getSecretValue(params).promise()

}

 

module.exports = {

    getSecretValue

}