import React, { useState } from 'react';
import { Sidebar } from './components/Sidebar';
import { Dashboard } from './pages/Dashboard';
import { Explorer } from './pages/Explorer';
import { Packs } from './pages/Packs';
import { Dictionary } from './pages/Dictionary';
import { LyxalStore } from './pages/LyxalStore';
import { IconsExplorer } from './pages/IconsExplorer';

function App() {
  const [currentPage, setCurrentPage] = useState('dashboard');

  const renderPage = () => {
    switch(currentPage) {
      case 'dashboard': return <Dashboard />;
      case 'icons': return <IconsExplorer />;
      case 'explorer': return <Explorer />;
      case 'store': return <LyxalStore />;
      case 'packs': return <Packs />;
      case 'dictionary': return <Dictionary />;
      default: return <Dashboard />;
    }
  };

  return (
    <div className="flex h-screen w-full">
      <Sidebar currentPage={currentPage} onNavigate={setCurrentPage} />
      <main className="flex-1 overflow-auto p-8">
        {renderPage()}
      </main>
      </div>
  );
}

export default App;
