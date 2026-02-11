// Frontend entry point - imported by index.html
import React from 'react';
import ReactDOM from 'react-dom/client';

// Import Lyxal UI directly
import '../lyxalui/index';
import '../lyxalui/theme/index';

// Simple test component with Lyxal UI
const App: React.FC = () => {
  return (
    <div className="min-h-screen bg-base-100 text-base-content p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-8 text-center">
          🚀 Lyxal UI Playground
        </h1>

        <div className="card bg-base-200 shadow-xl">
          <div className="card-body">
            <h2 className="card-title">Lyxal UI is working! 🎉</h2>
            <p>Tailwind CSS + Lyxal UI plugin loaded successfully</p>

            <div className="flex flex-wrap gap-4 mt-6">
              <button className="btn btn-primary">Primary Button</button>
              <button className="btn btn-secondary">Secondary Button</button>
              <button className="btn btn-accent">Accent Button</button>
              <button className="btn btn-info">Info Button</button>
              <button className="btn btn-success">Success Button</button>
              <button className="btn btn-warning">Warning Button</button>
              <button className="btn btn-error">Error Button</button>
            </div>

            <div className="flex flex-wrap gap-4 mt-4">
              <span className="badge badge-primary">Primary Badge</span>
              <span className="badge badge-secondary">Secondary Badge</span>
              <span className="badge badge-accent">Accent Badge</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

// Client-side rendering (Bun fullstack bundler will handle this)
const rootElement = document.getElementById('root');
if (rootElement) {
  ReactDOM.createRoot(rootElement).render(<App />);
} else {
  console.error('Root element not found');
}
