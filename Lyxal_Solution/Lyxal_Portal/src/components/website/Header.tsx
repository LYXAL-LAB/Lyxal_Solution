import React from 'react';

interface HeaderProps {
  companyName?: string;
  showNavigation?: boolean;
  navigationItems?: Array<{ label: string; href: string }>;
  ctaText?: string;
  ctaHref?: string;
  onNavigate?: (path: string) => void;
}

const Header: React.FC<HeaderProps> = ({
  companyName = "LYXAL",
  showNavigation = true,
  navigationItems = [
    { label: "Fonctionnalités", href: "/features" },
    { label: "Tarifs", href: "/pricing" },
    { label: "À propos", href: "/about" },
    { label: "Contact", href: "/contact" }
  ],
  ctaText = "Sign In",
  ctaHref = "/signin",
  onNavigate
}) => {
  const handleNavigation = (path: string) => {
    if (onNavigate) {
      onNavigate(path);
    } else {
      window.location.href = path;
    }
  };

  return (
    <header className="navbar bg-base-200 shadow-sm">
      <div className="navbar-start">
        <div className="flex items-center">
          <button 
            onClick={() => handleNavigation('/')}
            className="text-2xl font-bold text-primary hover:text-primary-focus cursor-pointer"
          >
            {companyName}
          </button>
        </div>
      </div>
      
      {showNavigation && (
        <div className="navbar-center hidden lg:flex">
          <ul className="menu menu-horizontal px-1">
            {navigationItems.map((item, index) => (
              <li key={index}>
                <button 
                  onClick={() => handleNavigation(item.href)}
                  className="link link-hover"
                >
                  {item.label}
                </button>
              </li>
            ))}
          </ul>
        </div>
      )}
      
      <div className="navbar-end">
        <button 
          onClick={() => handleNavigation(ctaHref)}
          className="btn btn-primary"
        >
          {ctaText}
        </button>
      </div>
    </header>
  );
};

export default Header; 