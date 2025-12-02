import React, { type ReactNode } from 'react';

interface LayoutProps {
  children: ReactNode;
  header?: ReactNode;
  headerType?: 'sticky' | 'fixed' | 'static' | 'floating';
  footer?: ReactNode;
  footerType?: 'default' | 'compact' | 'dark' | 'glass';
  footerPosition?: 'static' | 'sticky' | 'fixed';
  
  /* Configuration du Main */
  mainWidth?: 'standard' | 'full' | 'narrow';
  mainPadding?: 'standard' | 'compact' | 'spacious' | 'flush';
  
  className?: string;
}

const Layout: React.FC<LayoutProps> = ({ 
  children, 
  header, 
  headerType = 'sticky', 
  footer, 
  footerType = 'default', 
  footerPosition = 'static',
  
  /* Valeurs par défaut pour le Main */
  mainWidth = 'full',     // Par défaut : prend toute la largeur pour laisser les sections gérer
  mainPadding = 'flush',  // Par défaut : aucun padding pour permettre les fonds full-width
  
  className = ''
}) => {
  return (
    <div className={`layout-root ${className}`}>
      {header && (
        <header className={`header-root header-${headerType}`}>
          {header}
        </header>
      )}

      <main className={`main-root main-${mainWidth} main-${mainPadding}`}>
        {children}
      </main>

      {footer && (
        <footer className={`footer-root footer-${footerType} footer-${footerPosition}`}>
          {footer}
        </footer>
      )}
    </div>
  );
};

export default Layout;

