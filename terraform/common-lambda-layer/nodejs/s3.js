const aws = require('aws-sdk')
const sts = require('./sts')
const s3 = new aws.S3({ signatureVersion: 'v4' })

const newS3 = p => new aws.S3(p)

const headObject = (params) => {
    return s3.headObject(params).promise()
}
 
const getObject = (params) => {
    return s3.getObject(params).promise()
}

const copyObject = (params) => {
    return s3.copyObject(params).promise()
}

const deleteObject = (params) => {
    return s3.deleteObject(params).promise()
}

const listObjectsV2 = p => s3.listObjectsV2(p).promise()

const getS3Assumed = async (RoleArn, logger) => {
    const params = {
        RoleArn,
        RoleSessionName: 'trv-ccc-ext-upload-assumed-role',
        DurationSeconds: process.env.LAMBDA_TIMEOUT,
        ExternalId: process.env.EXTERNAL_ID
    }

    const assumedRole = await sts.assumeRole(params)
        .catch(error => {
        logger('assume-role-failed', { error, params, RoleArn })
        })

    if (!assumedRole)
        return false
    logger('assumed-role-success', { params })

    const s3 = await new aws.S3({
        apiVersion: '2006-03-01',
        accessKeyId: assumedRole.Credentials.AccessKeyId,
        secretAccessKey: assumedRole.Credentials.SecretAccessKey,
        sessionToken: assumedRole.Credentials.SessionToken,
    })

    return s3
}


module.exports = {
    headObject,
    copyObject,
    deleteObject,
    listObjectsV2,
    getS3Assumed,
    newS3
}