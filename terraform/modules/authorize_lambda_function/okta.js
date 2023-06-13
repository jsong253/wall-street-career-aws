const OktaJwtVerifier = require('@okta/jwt-verifier')

const oktaJwtVerifier = new OktaJwtVerifier({
  issuer: 'https://travelers-dev.oktapreview.com/oauth2/aus130rsqrd51M6HQ0h8',
  assertClaims: {
    cid: '0oa130rmd72AXU1zI0h8',
    'scp.includes': ['filetracking-write']
  }
})

const verifyToken = (tokenString, expectedAud) => {
  return oktaJwtVerifier.verifyAccessToken(tokenString, expectedAud)
}

module.exports = {
  verifyToken
}