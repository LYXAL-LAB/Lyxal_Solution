import React from 'react';

interface FooterProps {
  companyName?: string;
  version?: string;
  status?: 'success' | 'warning' | 'error' | 'info';
  showDate?: boolean;
}

const Footer: React.FC<FooterProps> = ({ 
  companyName = "LYXAL",
  version = "v1.0.0", 
  status = "success",
  showDate = true 
}) => {
  const statusColors = {
    success: 'text-success',
    warning: 'text-warning', 
    error: 'text-error',
    info: 'text-info'
  };

  const currentDate = new Date().toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  });

  return (
    <footer className="footer footer-center sm:footer-horizontal p-6 bg-base-200/80 backdrop-blur-sm text-base-content border-t border-base-300">
      <aside className="items-center grid-flow-col">
        <div className="flex items-center gap-2">
          <span className="text-sm">
            Copyright © {new Date().getFullYear()} {companyName}
          </span>
          <div className="flex items-center gap-1">
            <div className={`w-2 h-2 rounded-full ${statusColors[status]} animate-pulse`}></div>
            <span className="text-xs text-base-content/70">Opérationnel</span>
          </div>
        </div>
      </aside>
      
      <nav className="grid-flow-col gap-4 md:place-self-center md:justify-self-end">
        <div className="flex items-center gap-4 text-sm text-base-content/70">
          <span>{version}</span>
          {showDate && <span>{currentDate}</span>}
        </div>
      </nav>
    </footer>
  );
};

export default Footer; 