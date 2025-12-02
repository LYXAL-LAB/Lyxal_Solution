// Test minimal version without imports
import React from 'react';
import ReactDOM from 'react-dom/client';

// Minimal test component
const TestApp = () => {
  return React.createElement('div', null, 'Hello World - Testing...');
};

// Client-side rendering (Bun fullstack bundler will handle this)
const rootElement = document.getElementById('root');
if (rootElement) {
  ReactDOM.createRoot(rootElement).render(<TestApp />);
} else {
  console.error('Root element not found');
}
