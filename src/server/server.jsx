import express from 'express';
import {StaticRouter} from 'react-router-dom/server';
import ReactDOMServer from 'react-dom/server';
import App from '../client/components/App';
import fs from 'fs';

const app = express();
app.use('/static', express.static(__dirname)); //s3 here
const PORT = process.env.PORT;

app.get('*', async (req, res) => {
    const indexHtml = await createReactApp(req.url);
    res.status(200).send(indexHtml);
});

app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
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