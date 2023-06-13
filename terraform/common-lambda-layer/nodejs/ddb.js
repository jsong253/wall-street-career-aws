//this file won't be unit tested. just here to sub out the aws dynamo calls
const aws = require('aws-sdk')
const ddb = new aws.DynamoDB({ apiVersion: '2012-08-10' })

const updateItem = (params) => {
    return ddb.updateItem(params).promise()
}

const putItem = (params) => {
    return ddb.putItem(params).promise()
}

const getItem = (params) => {
    return ddb.getItem(params).promise()
}

const scan = (params) => {
    return ddb.scan(params).promise()
}

const query = (params, cb) => {
    return ddb.query(params, cb)
}

module.exports = {
    putItem,
    updateItem,
    getItem,
    scan,
    query
}