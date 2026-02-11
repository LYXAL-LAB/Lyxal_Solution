import React from 'react';
import { createRoot } from 'react-dom/client';
import { ViewerProvider } from './context/ViewerContext';
import { PDFDocument } from './components/pdf/PDFDocument';

const App = () => {
  // URL du fichier de test (servi par dev.ts via le proxy /viewer/)
  const testUrl = '/renderer/web/compressed.tracemonkey-pldi-09.pdf';

  return (
    <div style={{ height: '100vh', background: '#333' }}>
      <ViewerProvider>
          <PDFDocument url={testUrl} />
      </ViewerProvider>
    </div>
  );
};

const root = createRoot(document.getElementById('root')!);
root.render(<App />);
