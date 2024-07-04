import React from 'react';
import {hydrateRoot} from 'react-dom/client';
import {BrowserRouter} from 'react-router-dom';
import App from './components/App';

hydrateRoot(document.getElementById('root'),
  <React.StrictMode>
    <BrowserRouter basename='/dev'>
      <App />
    </BrowserRouter>
  </React.StrictMode>);