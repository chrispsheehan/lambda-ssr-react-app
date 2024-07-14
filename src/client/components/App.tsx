import { Routes, Route } from 'react-router-dom';
import Home from './Home';
import About from './About';
import Navbar from './Navbar';
import React, { useState, useEffect } from 'react';

const App = () => {
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setHydrated(true);
    }, 1000); // Simulate a 1-second delay

    return () => clearTimeout(timer);
  }, []);

  return (
    <main>
      <Navbar />
      {hydrated ? (
        <Routes>
          <Route path="/home" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="*" element={<Home />} />
        </Routes>
      ) : (
        <div>Loading App...</div>
      )}
    </main>
  );
};

export default App;
