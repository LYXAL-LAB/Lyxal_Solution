import React from 'react';
import { StudioPageRenderer } from '@/components/studio';
import { StudioErrorBoundary } from '@/components/studio/StudioErrorBoundary';

/**
 * Page de démonstration du CircularMenu DB-driven
 *
 * Cette page rend complètement la page définie en DB :
 * studio_page:circular_menu_demo
 *
 * Aucun code React en dur ici - tout vient de SurrealDB !
 */
const CircularMenuDemoPage: React.FC = () => {
  return (
    <div className="circular-menu-demo-page">
      <StudioErrorBoundary>
        <StudioPageRenderer pageCode="circular_menu_demo" />
      </StudioErrorBoundary>
    </div>
  );
};

export default CircularMenuDemoPage;
