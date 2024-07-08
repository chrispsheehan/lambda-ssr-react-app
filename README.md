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
docker-compose up
```

## Deploy

- Build and deploy ssr app to aws

```sh
just deploy
```

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