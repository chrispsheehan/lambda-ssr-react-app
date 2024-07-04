import express from 'express';
import {StaticRouter} from 'react-router-dom/server';
import ReactDOMServer from 'react-dom/server';
import App from '../client/components/App';
import fs from 'fs';
import awsServerlessExpress from 'aws-serverless-express';

const PORT = process.env.PORT || 3001;
const basename = process.env.REACT_APP_BASENAME || '/';

const app = express();
app.use(`/static`, express.static(__dirname));

app.get('*', async (req, res) => {
    // const indexHtml = await createReactApp(req.url);
    // res.setHeader('Content-Type', 'text/html; charset=utf-8');
    // res.status(200).send(indexHtml);

    try {
      console.log('Request received:', req.url);
      const indexHtml = await createReactApp(req.url);
      res.setHeader('Content-Type', 'text/html; charset=utf-8'); // Set the Content-Type header
      res.status(200).send(indexHtml);
    } catch (error) {
      console.error('Error rendering app:', error);
      res.status(500).send('An error occurred');
    }
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
    <StaticRouter location={location}>
      <App />
    </StaticRouter>
  );
  const html = await fs.promises.readFile(`${__dirname}/index.html`, 'utf-8');
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