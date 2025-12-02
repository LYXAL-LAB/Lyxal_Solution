import React from 'react';
import { Main } from '../layouts';

const pages = [
  { path: '/all', name: 'All Components' },
  { path: '/demo', name: 'Demo' },
  { path: '/calendar', name: 'Calendar' },
  { path: '/light', name: 'Light Theme' },
  { path: '/dark', name: 'Dark Theme' },
  { path: '/LTR', name: 'Left-to-Right' },
  { path: '/RTL', name: 'Right-to-Left' },
  { path: '/prefix', name: 'Prefix' },
];

const IndexPage: React.FC = () => {
  return (
    <Main>
      <div className="flex flex-col gap-10 min-h-screen justify-center items-center p-4">
        <div className="w-full max-w-lg flex flex-col gap-4">
          <h1 className="font-bold text-lg">Welcome to Lyxal UI Playground</h1>
          <div className="text-base-content/50 flex flex-col gap-4">
            <p>This is a React TypeScript project where you can test Lyxal UI components from the source (not the NPM package)</p>
            <p>
              Start by editing this file:
              <pre className="font-mono text-sm bg-base-200 px-1 rounded break-all whitespace-pre-wrap mt-2">
                /src/playground/src/components/Demo.tsx
              </pre>
            </p>
            <p>You can see the result and test the components in the following pages:</p>
          </div>
        </div>
        <ul className="menu w-full max-w-lg border border-base-content/10 rounded-box">
          <li className="menu-title">Pages</li>
          {pages.map((page) => (
            <li key={page.path}>
              <a className="font-mono" href={page.path}>
                {page.name}
              </a>
            </li>
          ))}
        </ul>
      </div>
    </Main>
  );
};

export default IndexPage;
