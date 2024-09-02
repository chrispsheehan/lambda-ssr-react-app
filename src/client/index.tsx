import React from 'react';
import { hydrateRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './components/App';

const basePath = process.env.BASE_PATH;

const rootElement = document.getElementById('root');
if (rootElement) {
  hydrateRoot(
    rootElement,
    <React.StrictMode>
      <BrowserRouter basename={`${basePath}`}>
        <App />
      </BrowserRouter>
    </React.StrictMode>
  );
} else {
  console.error("Root element not found. Please ensure there is an element with the id 'root' in your HTML.");
}
