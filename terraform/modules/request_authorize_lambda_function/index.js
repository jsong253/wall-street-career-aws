const { getSecretValue } = require('./sm')
const { createLogger } = require('./createLogger') 

exports.handler = async (event, context, callback) => {
    const key = `WallStreetCareerSecretKey`
    const logger = createLogger('request-authorizer')

    logger('request=authorize start')

    const secret = event.headers['WSC-SHAREDSECRET']
    logger(`secret: ${secret}`)

    const shhh = await getSecretValue({ SecretId: `ShareSecret` })
    logger(`shhh: ${JSON.stringify(shhh, null, 4)}`)

    if (!shhh) {
        logger('secret-not-present', { alert_itoc: true })
        return
    }

    if (!shhh.SecretString) {
        logger('secret-string-not-present', { alert_itoc: true })
        return
    }

    let superSecret = ''

    try {
        superSecret = JSON.parse(shhh.SecretString)[key]
        logger(`superSecret: ${superSecret}`)

        if (!superSecret) {
            logger('key-not-present-in-secret-string', { alert_itoc: true })
            return
        }
    } catch (error) {
        logger('unable-to-parse-secret-string', { alert_itoc: true, err: error })
        return
    } 
 

    if (superSecret === secret) {
        const policy = generateAllow('me', event.methodArn)
        logger('authorized-call', { policy })
        logger('request=authorize end')
        callback(null, policy)
    }
    else {
        logger('unathorized-call')
        logger('request=authorize end')
        callback('Unauthorized')
    }
}

const generatePolicy = (principalId, effect, resource, headers) => {
    let authResponse = {}
    authResponse.principalId = principalId

    if (effect && resource) {
        authResponse.policyDocument = {
            Version: '2012-10-17',
            Statement: [{
                Action: 'execute-api:Invoke',
                Effect: effect,
                Resource: resource
            }]
        }
    }

    authResponse.context = headers
    return authResponse
}
 
const generateAllow = (principalId, resource) => {
    return generatePolicy(principalId, 'Allow', resource)
}