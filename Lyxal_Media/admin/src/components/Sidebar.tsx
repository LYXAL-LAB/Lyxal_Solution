import React from 'react';

interface SidebarProps {
  currentPage: string;
  onNavigate: (page: string) => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ currentPage, onNavigate }) => {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: '📊' },
    { id: 'icons', label: 'Icon Explorer', icon: '🔍' },
    { id: 'store', label: 'Lyxal Store', icon: '🛍️' },
    { id: 'explorer', label: 'Github Explorer', icon: '🌍' },
    { id: 'packs', label: 'Installed Packs', icon: '📦' },
    { id: 'dictionary', label: 'Dictionary', icon: '📖' },
  ];

  return (
    <aside className="w-64 bg-dark text-white flex flex-col h-full shadow-xl">
      <div className="p-6 border-b border-gray-700">
        <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-400 to-purple-500 bg-clip-text text-transparent">
          Lyxal SVG
        </h1>
        <p className="text-xs text-gray-400 mt-1">Admin Studio v1.0</p>
      </div>
      
      <nav className="flex-1 p-4 space-y-2">
        {menuItems.map(item => (
          <button
            key={item.id}
            onClick={() => onNavigate(item.id)}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200
              ${currentPage === item.id 
                ? 'bg-primary text-white shadow-lg shadow-blue-500/30' 
                : 'text-gray-400 hover:bg-gray-800 hover:text-white'
              }`}
          >
            <span className="text-xl">{item.icon}</span>
            <span className="font-medium">{item.label}</span>
          </button>
        ))}
      </nav>

      <div className="p-4 border-t border-gray-700 text-xs text-gray-500 text-center">
        Powered by Lyxal Solution
      </div>
    </aside>
  );
};

