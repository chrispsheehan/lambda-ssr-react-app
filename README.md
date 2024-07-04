# lambda-ssr-react-app

https://www.youtube.com/watch?v=LRohAW0WYZM

https://wittcode.com/blogs/server-side-rendering-react-with-express

```json
{
  "resource": "/{proxy+}",
  "path": "/dev",
  "httpMethod": "GET",
  "headers": {
    "accept": "application/json",
    "accept-encoding": "gzip, deflate, br",
    "content-type": "application/json",
    "host": "example.execute-api.us-east-1.amazonaws.com",
    "user-agent": "Mozilla/5.0",
    "x-amzn-trace-id": "Root=1-5f84e54d-18aebc25e15fef6ed2ad0e7d",
    "x-forwarded-for": "127.0.0.1",
    "x-forwarded-port": "443",
    "x-forwarded-proto": "https"
  },
  "multiValueHeaders": {
    "accept": ["application/json"],
    "accept-encoding": ["gzip, deflate, br"],
    "content-type": ["application/json"],
    "host": ["example.execute-api.us-east-1.amazonaws.com"],
    "user-agent": ["Mozilla/5.0"],
    "x-amzn-trace-id": ["Root=1-5f84e54d-18aebc25e15fef6ed2ad0e7d"],
    "x-forwarded-for": ["127.0.0.1"],
    "x-forwarded-port": ["443"],
    "x-forwarded-proto": ["https"]
  },
  "queryStringParameters": null,
  "multiValueQueryStringParameters": null,
  "pathParameters": {
    "proxy": "dev"
  },
  "stageVariables": null,
  "requestContext": {
    "resourceId": "123456",
    "resourcePath": "/{proxy+}",
    "httpMethod": "GET",
    "extendedRequestId": "ZXl4jHlmFiAFRWg=",
    "requestTime": "04/Jul/2024:19:15:12 +0000",
    "path": "/dev",
    "accountId": "123456789012",
    "protocol": "HTTP/1.1",
    "stage": "dev",
    "domainPrefix": "example",
    "requestTimeEpoch": 1591175712312,
    "requestId": "c77de98e-4992-11e8-9dd0-af0edeb1234a",
    "identity": {
      "cognitoIdentityPoolId": null,
      "accountId": null,
      "cognitoIdentityId": null,
      "caller": null,
      "sourceIp": "127.0.0.1",
      "principalOrgId": null,
      "accessKey": null,
      "cognitoAuthenticationType": null,
      "cognitoAuthenticationProvider": null,
      "userArn": null,
      "userAgent": "Mozilla/5.0",
      "user": null
    },
    "domainName": "example.execute-api.us-east-1.amazonaws.com",
    "apiId": "1234567890"
  },
  "body": null,
  "isBase64Encoded": false
}
```