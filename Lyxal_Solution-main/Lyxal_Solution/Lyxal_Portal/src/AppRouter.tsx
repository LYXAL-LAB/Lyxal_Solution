import React, { useState, useEffect } from 'react';
import Home from './pages/website/Home';
import SignIn from './pages/website/SignIn';
import App from './App';
import { StudioTestPage } from './pages/test/StudioTestPage';
import CircularMenuDemoPage from './pages/CircularMenuDemoPage';

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
      case '/signin':
        return <SignIn />;
      case '/app':
        return <App />;
      case '/test':
        return <StudioTestPage />;
      case '/demo/circular-menu':
        return <CircularMenuDemoPage />;
      case '/':
      default:
        return <Home onNavigate={navigate} />;
    }
  };

  return <>{renderPage()}</>;
};

export default AppRouter; 