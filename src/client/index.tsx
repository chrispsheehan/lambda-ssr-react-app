import React from 'react';
import { hydrateRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './components/App';

const stage = process.env.STAGE;

const rootElement = document.getElementById('root');
if (rootElement) {
  hydrateRoot(
    rootElement,
    <React.StrictMode>
      <BrowserRouter basename={`/${stage}`}>
        <App />
      </BrowserRouter>
    </React.StrictMode>
  );
} else {
  console.error("Root element not found. Please ensure there is an element with the id 'root' in your HTML.");
}
