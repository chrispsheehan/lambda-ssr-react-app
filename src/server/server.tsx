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
import axios from "axios";
import awsServerlessExpress from 'aws-serverless-express';
import { APIGatewayProxyEvent, Context } from "aws-lambda";
import retrieveFileFromCloudFront from './cloudfront';

const getEnvVar = (varName: string): string => {
  const value = process.env[varName];
  if (!value) {
    throw new Error(`Environment variable ${varName} is required but not defined`);
  }
  return value;
}

const port: string | undefined = process.env.PORT;
const stage: string = getEnvVar('STAGE');
const appEnv: string = getEnvVar('APP_ENV');
const staticSource: string = getEnvVar('STATIC_SOURCE');

var staticDir: string;

const app = express();

console.log(`STAGE: ${stage}`);
console.log(`APP_ENV: ${appEnv}`);
console.log(`STATIC_SOURCE: ${staticSource}`);

const publicPath = `/${stage}/public`;

app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(`Request received: ${req.method} ${req.url}`);
  next();
});

switch (appEnv) {
  case 'local':
  case 'docker':
    staticDir = path.resolve(__dirname, staticSource);
    app.use(`${publicPath}/static`, express.static(path.resolve(staticDir, 'static')));
    app.use(`${publicPath}/assets`, express.static(path.resolve(staticDir, 'assets')));
    app.use(`${publicPath}/assets/styles`, express.static(path.resolve(staticDir, 'assets/styles')));
    break;

  case 'production':
    app.use(`${publicPath}/static`, retrieveFileFromCloudFront(`${staticSource}/static`));
    break;

  default:
    throw new Error('Invalid APP_ENV value');
}

app.get(`/${stage}/*`, async (req: Request, res: Response) => {
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
  const indexFileRef = "static/index.html";
  const scriptPath = `${stage}/public/static/client.js`;
  const faviconFileRef = "assets/favicon.ico";
  const stylesCSSFileRef = "assets/styles/styles.scss";

  const reactApp = ReactDOMServer.renderToString(
    <StaticRouter location={location} basename={`/${stage}`}>
      <App />
    </StaticRouter>
  );

  let html: string;
  let faviconPath: string;
  let scssPath: string;
  if (appEnv === 'production') {
    const indexPath = `${staticSource}/${indexFileRef}`;
    const response = await axios.get(indexPath);
    if (response.status !== 200) {
      throw new Error('Failed to fetch index.html from CloudFront');
    }
    html = response.data;
    faviconPath = `${staticSource}/${faviconFileRef}`;
    scssPath = `${staticSource}/${stylesCSSFileRef}`;
  } else {
    const indexPath = path.resolve(staticDir, indexFileRef);
    html = await fs.promises.readFile(indexPath, 'utf-8');
    faviconPath = `${publicPath}/${faviconFileRef}`;
    scssPath = `${publicPath}/${stylesCSSFileRef}`
  }

  const reactHtml = html.replace(
    '<div id="root"><main><div>Loading App...</div></main></div>', `<div id="root">${reactApp}</div>`)
    .replace('{{FAVICON_PATH}}', faviconPath)
    .replace('{{SCRIPT_PATH}}', scriptPath)
    .replace('{{STYLE_CSS_PATH}}', scssPath);
  return reactHtml;
};

// For local testing
if (port) {
  app.listen(port, () => {
    console.log(`App started: http://localhost:${port}/${stage}/home`);
  });
}

const server = awsServerlessExpress.createServer(app);

exports.handler = (event: APIGatewayProxyEvent, context: Context) => {
  awsServerlessExpress.proxy(server, event, context);
};
