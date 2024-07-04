import express from 'express';
import onFinished from 'on-finished';
import {StaticRouter} from 'react-router-dom/server';
import ReactDOMServer from 'react-dom/server';
import App from '../client/components/App';
import fs from 'fs';
import path from 'path';
import awsServerlessExpress from 'aws-serverless-express';

const PORT = process.env.PORT || 3001;

const app = express();
app.use(`/static`, express.static(__dirname));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use((req, res, next) => { 
  console.log(`Params: ${JSON.stringify(req.params)}`); // log out requests
  console.log(`Headers: ${JSON.stringify(req.headers)}`);
  console.log(`${req.method}: ${JSON.stringify(req.url)}`);
  onFinished(res, function () {
    // log out invalid requests
    app.all('/*', function(req, res) {
      console.error(`***ROUTE NOT SUPPORTED***\n`);
      res.status(404).json({message: "invalidRoute"})
    });
  })
  next();
})

app.get('*', async (req, res) => {
    // const indexHtml = await createReactApp(req.url);
    // res.setHeader('Content-Type', 'text/html; charset=utf-8');
    // res.status(200).send(indexHtml);

    try {
      const staticDir = path.resolve(__dirname);

      fs.readdir(staticDir, (err, files) => {
        if (err) {
          return res.status(500).send('Error reading static files directory');
        }
      
        console.log("files:" + files);
      });

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