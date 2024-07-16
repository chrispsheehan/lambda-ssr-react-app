# lambda-ssr-react-app

A ReactJS SSR app hosted in AWS.

### Inspiration

- https://www.youtube.com/watch?v=LRohAW0WYZM
- https://wittcode.com/blogs/server-side-rendering-react-with-express
- https://aws.amazon.com/blogs/compute/building-server-side-rendering-for-react-in-aws-lambda
- https://react.dev/reference/react-dom/server

## Run Locally

- Live load changes to `/src` and `/tests`. Runs `/tests` on every change.
- Runs in `docker-compose` using `.env.docker` environmental variables.

```sh
just run
```

## Debug Locally

- 

## Deploy

- Run `Deploy Environment` in Github Actions.
  - or cd into `tf/cdn` and `tf/ssr` to deploy manually.

- Required aws permissions below.

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

- Enter the below into the lambda test console to simulate api calls.

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