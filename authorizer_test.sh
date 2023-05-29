#!/bin/bash
set -eux
#assign credentials to variables
CLIENT_ID=5160k0ou0rdr4rf6d86r16t0mb
USER_POOL_ID=us-east-1_XuvZQmBE8
USERNAME=jianzhong
PASSWORD=tester2023
URL=https://aaiiuxs4r8.execute-api.us-east-1.amazonaws.com/prod/registrations
#sign-up user:
aws cognito-idp sign-up \
 --client-id ${CLIENT_ID} \
 --username ${USERNAME} \
 --password ${PASSWORD} 
 
#confirm user:
aws cognito-idp admin-confirm-sign-up  \
  --user-pool-id ${USER_POOL_ID} \
  --username ${USERNAME} 
  
#authenticate and get token
TOKEN=$(
    aws cognito-idp initiate-auth \
 --client-id ${CLIENT_ID} \
 --auth-flow USER_PASSWORD_AUTH \
 --auth-parameters USERNAME=${USERNAME},PASSWORD=${PASSWORD} \
 --query 'AuthenticationResult.IdToken' \
 --output text 
    )
#make API call:
curl -H "Authorization: ${TOKEN}" ${URL} | jq