import {Routes, Route} from 'react-router-dom';
import Home from './Home';
import About from './About';
import Navbar from './Navbar';
import React from 'react';

const App = () => {
  return (
    <main>
      <Navbar />
      <Routes>
        <Route path="/home" element={ <Home/> } />
        <Route path="/about" element={ <About/> } />
        <Route path="*" element={ <Home/> } />
      </Routes>
    </main>
  );
};

export default App;