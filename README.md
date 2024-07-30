# lambda-ssr-react-app

A ReactJS SSR app hosted in AWS.

## Overview

Render SSR app on the client side via an AWS Lambda function. Commonly used to increase SEO scores. This approach could also abstract back end API interactions away from the client side - think authentication.

Cloudfront is used to host the initial index.html as well as other static assets.

### Inspiration

- https://www.youtube.com/watch?v=LRohAW0WYZM
- https://wittcode.com/blogs/server-side-rendering-react-with-express
- https://aws.amazon.com/blogs/compute/building-server-side-rendering-for-react-in-aws-lambda
- https://react.dev/reference/react-dom/server

## Run Locally

- Live load changes to `/src` and `/tests`. Runs `/tests` on every change.
- Runs in `docker-compose` using `.env.docker` environmental variables.
- Access via `http://localhost:3001/docker/`

```sh
just run
```

## Debug Locally

- Create `.env` file as per values found in `.env.local`.
- Access via `http://localhost:3001/local/`

```sh
just debug
```

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