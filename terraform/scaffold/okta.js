const OktaJwtVerifier = require('@okta/jwt-verifier')


const oktaJwtVerifier = new OktaJwtVerifier({

  issuer: process.env.ISSUER,

  assertClaims: {

    cid: process.env.CLIENT_ID,

    'scp.includes': [process.env.SCOPE]

  }

})

 

const oktaBrowserJwtVerifier = new OktaJwtVerifier({

  issuer: process.env.BROWSER_ISSUER,

  assertClaims: {

    cid: process.env.BROWSER_CLIENT_ID,

    'groups.includes': [process.env.BROWSER_OKTA_GROUP]

  }

})

 

/// This will throw if the token is invalid, but I want to leave this

// wrapper as thin as possible so errors will be handled by the caller

const verifyToken = (tokenString, expectedAud) => {

  return oktaJwtVerifier.verifyAccessToken(tokenString, expectedAud)

}

 

const verifyBrowserToken = (tokenString, expectedAud) => {

  return oktaBrowserJwtVerifier.verifyAccessToken(tokenString, expectedAud)

}

 

module.exports = {

  verifyBrowserToken,

  verifyToken

}