import express from 'express';
import { StaticRouter } from 'react-router-dom/server';
import ReactDOMServer from 'react-dom/server';
import App from '../client/components/App';
import fs from 'fs';
import path from 'path';
import awsServerlessExpress from 'aws-serverless-express';

const PORT = process.env.PORT || 3001;
const stage = process.env.STAGE || 'dev';

const app = express();
const staticDir = path.resolve(__dirname, process.env.STATIC_DIR || '../dist/public/static');
app.use(`/static`, express.static(staticDir));

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
const createReactApp = async (location) => {
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

exports.handler = (event, context) => {
  awsServerlessExpress.proxy(server, event, context);
};

// For local testing
if (process.env.NODE_ENV !== 'lambda') {
  app.listen(PORT, () => {
    console.log(`Server started on port ${PORT}`);
  });
}
