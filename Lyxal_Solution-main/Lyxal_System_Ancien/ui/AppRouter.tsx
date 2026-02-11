import React, { useState, useEffect } from 'react';
import Home from './pages/website/Home';
import App from './App';

const AppRouter: React.FC = () => {
  const [currentPage, setCurrentPage] = useState<string>(window.location.pathname);

  useEffect(() => {
    const handlePopState = () => {
      setCurrentPage(window.location.pathname);
    };

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  const navigate = (path: string) => {
    setCurrentPage(path);
    window.history.pushState({}, '', path);
  };

  const renderPage = () => {
    switch (currentPage) {
      case '/app':
        return <App />;
      case '/':
      default:
        return <Home onNavigate={navigate} />;
    }
  };

  return <>{renderPage()}</>;
};

export default AppRouter; 