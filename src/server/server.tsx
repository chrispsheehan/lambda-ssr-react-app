import { config } from "dotenv";
config();

import express from 'express';
import { StaticRouter } from 'react-router-dom/server';
import ReactDOMServer from 'react-dom/server';
import App from '../client/components/App';
import fs from 'fs';
import path from 'path';
import awsServerlessExpress from 'aws-serverless-express';
import { Location } from 'react-router-dom';
import React from 'react';
import { APIGatewayProxyEvent, Context } from 'aws-lambda';

const port = process.env.PORT;
const stage = process.env.STAGE;
const appEnv = process.env.APP_ENV;
const staticSource = process.env.STATIC_SOURCE;

var staticDir: string;

const app = express();

console.log(`STAGE: ${stage}`);
console.log(`APP_ENV: ${appEnv}`);
console.log(`STATIC_SOURCE: ${staticSource}`);

const isLocal = (appEnv == 'local' || appEnv == 'docker')


if (isLocal) {
  staticDir = path.resolve(__dirname, `${staticSource}`);
  console.log(`loading /static to ${staticDir}`);
  app.use(`/static`, express.static(staticDir));
} else {
  throw new Error('Invalid APP_ENV value');
}

console.log(`STATIC_DIR: ${staticDir}`);

app.get(`/${stage}/*`, async (req, res) => {
  try {
    console.log(`${req.method}: ${req.url}`);
    const indexHtml = await createReactApp(req.url);
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.status(200).send(indexHtml);
  } catch (error) {
    console.error('Error rendering app:', error);
    res.status(500).send('An error occurred');
  }
});

// Fallback route for any other routes not explicitly handled
app.all('*', (req, res) => {
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
  const reactApp = ReactDOMServer.renderToString(
    <StaticRouter location={location} basename={`/${stage}`}>
      <App />
    </StaticRouter>
  );
  const html = await fs.promises.readFile(path.resolve(staticDir, 'index.html'), 'utf-8');
  const reactHtml = html.replace(
    '<div id="root"></div>', `<div id="root">${reactApp}</div>`);
  return reactHtml;
};

const server = awsServerlessExpress.createServer(app);

exports.handler = (event: APIGatewayProxyEvent, context: Context) => {
  awsServerlessExpress.proxy(server, event, context);
};

// For local testing
if (isLocal) {
  app.listen(port, () => {
    console.log(`App started: http://localhost:${port}/${stage}/home`);
  });
}
