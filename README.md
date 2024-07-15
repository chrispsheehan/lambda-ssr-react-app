# lambda-ssr-react-app

### Inspiration

- https://www.youtube.com/watch?v=LRohAW0WYZM
- https://wittcode.com/blogs/server-side-rendering-react-with-express
- https://docs.aws.amazon.com/amplify/latest/userguide/server-side-rendering-amplify.html
- https://react.dev/reference/react-dom/server

## Run Locally

- Live load changes to `/src` and `/tests`
- Run `/tests` on every change

```sh
just run
```

## Deploy

- Run `Deploy Environment` in Github Actions

- Required aws permissions

```json
[
  "dynamodb:*", 
  "s3:*", 
  "lambda:*", 
  "iam:*",
  "apigateway:*",
  "logs:*"
]
```

## lambda test payload

```json
{
  "httpMethod": "GET",
  "resource": "/dev/about",
  "path": "/dev/about",
  "headers": {
    "Content-Type": "application/json"
  },
  "requestContext": {
    "resourcePath": "/dev/about",
    "httpMethod": "GET",
    "requestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef",
    "requestTime": "09/Apr/2015:12:34:56 +0000",
    "path": "/dev/about"
  }
}
```