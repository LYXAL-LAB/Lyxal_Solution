import React from 'react';
import { StudioPageRenderer } from '@/components/studio';
import { StudioErrorBoundary } from '@/components/studio/StudioErrorBoundary';

/**
 * Page de test pour le Studio Runtime
 * 
 * Cette page teste le rendu 100% DB-driven d'une page complète
 * définie dans SurrealDB via studio_page:test_page
 * 
 * Aucun code React en dur ici - tout vient de la DB !
 */
export const StudioTestPage: React.FC = () => {
  return (
    <div className="studio-test-page" style={{ padding: '20px' }}>
      <StudioErrorBoundary>
        <StudioPageRenderer pageCode="test_page" />
      </StudioErrorBoundary>
    </div>
  );
};

