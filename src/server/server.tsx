import { config } from "dotenv";
config();

import express, { NextFunction, Request, Response } from 'express';
import { StaticRouter } from 'react-router-dom/server';
import ReactDOMServer from 'react-dom/server';
import App from '../client/components/App';
import fs from 'fs';
import path from 'path';
import { Location } from 'react-router-dom';
import React from 'react';
import awsServerlessExpress from 'aws-serverless-express';
import { APIGatewayProxyEvent, Context } from "aws-lambda";

const getEnvVar = (varName: string): string => {
  const value = process.env[varName];
  if (!value) {
    throw new Error(`Environment variable ${varName} is required but not defined`);
  }
  return value;
}

const port: string | undefined = process.env.PORT;
const appEnv: string = getEnvVar('APP_ENV');
const publicPath: string = getEnvVar('PUBLIC_PATH');
const basePath: string = getEnvVar('BASE_PATH');
const staticSource: string = getEnvVar('STATIC_SOURCE');

const staticDir = path.resolve(__dirname, staticSource);

const app = express();

console.log(`APP_ENV: ${appEnv}`);
console.log(`PUBLIC_PATH: ${publicPath}`);
console.log(`BASE_PATH: ${basePath}`);
console.log(`STATIC_SOURCE: ${staticSource}`);

app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(`Request received: ${req.method} ${req.url}`);
  next();
});


switch (appEnv) {
  case 'local':
  case 'docker':
    app.use(publicPath, express.static(staticDir));
    break;
  default:
    console.log("Non-local environment detected. Static routing handled in CDN.")
}

app.get(`/*`, async (req: Request, res: Response) => {
  try {
    const indexHtml = await createReactApp(req.url);
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.status(200).send(indexHtml);
  } catch (error) {
    console.error('Error rendering app:', error);
    res.status(500).send('An error occurred');
  }
});

// Fallback route for any other routes not explicitly handled
app.all('*', (req: Request, res: Response) => {
  console.log(`***ROUTE NOT SUPPORTED*** ${req.method}: ${req.url}`);
  res.status(404).send('Route not supported');
});

/**
 * Produces the initial non-interactive HTML output of React
 * components. The hydrateRoot method is called on the client
 * to make this HTML interactive.
 * @param {string} location
 * @return {string}
 */
const createReactApp = async (location: string | Partial<Location<any>>) => {
  const indexPath = path.resolve(__dirname, "index.html");

  const reactApp = ReactDOMServer.renderToString(
    <StaticRouter location={location} basename={`${basePath}`}>
      <App />
    </StaticRouter>
  );

  let html: string;
  html = await fs.promises.readFile(indexPath, 'utf-8');
  const reactHtml = html.replace(
    '<div id="root"><main><div>Loading App...</div></main></div>', `<div id="root">${reactApp}</div>`);
  return reactHtml;
};

// For local testing
if (port) {
  app.listen(port, () => {
    console.log(`App started: http://localhost:${port}${basePath}home`);
  });
}

const server = awsServerlessExpress.createServer(app);

exports.handler = (event: APIGatewayProxyEvent, context: Context) => {
  awsServerlessExpress.proxy(server, event, context);
};
