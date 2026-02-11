import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import App from './App';
import { RoutesDashboard } from './pages/admin/routes';
import { NewRoute } from './pages/admin/routes/new';
import { RouteDetails } from './pages/admin/routes/[id]';

const AppRouter: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        {/* Routes principales */}
        <Route path="/" element={<App />} />
        <Route path="/app" element={<App />} />

        {/* Administration des routes */}
        <Route path="/admin/routes" element={<RoutesDashboard />} />
        <Route path="/admin/routes/new" element={<NewRoute />} />
        <Route path="/admin/routes/:id" element={<RouteDetails />} />
      </Routes>
    </BrowserRouter>
  );
};

export default AppRouter; 