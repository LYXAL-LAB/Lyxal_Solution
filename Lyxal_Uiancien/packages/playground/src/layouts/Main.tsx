import React from 'react';

interface MainLayoutProps {
  dir?: 'ltr' | 'rtl';
  theme?: string;
  children: React.ReactNode;
}

const Main: React.FC<MainLayoutProps> = ({
  dir = 'ltr',
  theme = 'light',
  children
}) => {
  // Set theme on document element for global theming
  React.useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    document.documentElement.setAttribute('dir', dir);
  }, [theme, dir]);

  return (
    <>
      {children}
    </>
  );
};

export default Main;
