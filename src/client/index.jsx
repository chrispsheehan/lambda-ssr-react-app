import React from 'react';
import {hydrateRoot} from 'react-dom/client';
import {BrowserRouter} from 'react-router-dom';
import App from './components/App';

const stage = process.env.STAGE || 'dev';

hydrateRoot(document.getElementById('root'),
  <React.StrictMode>
    <BrowserRouter basename={`/${stage}`}>
      <App />
    </BrowserRouter>
  </React.StrictMode>);