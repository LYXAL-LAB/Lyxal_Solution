import React, { useState, useEffect } from 'react';
import { Home, SignIn } from './pages/website';

const Router: React.FC = () => {
  const [currentPath, setCurrentPath] = useState(window.location.pathname);

  useEffect(() => {
    const handlePopState = () => {
      setCurrentPath(window.location.pathname);
    };

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  // Navigation function
  const navigate = (path: string) => {
    window.history.pushState({}, '', path);
    setCurrentPath(path);
  };

  // Make navigate function globally available
  useEffect(() => {
    (window as any).navigate = navigate;
  }, []);

  const renderPage = () => {
    switch (currentPath) {
      case '/signin':
        return <SignIn />;
      case '/':
      default:
        return <Home />;
    }
  };

  return <>{renderPage()}</>;
};

export default Router; 