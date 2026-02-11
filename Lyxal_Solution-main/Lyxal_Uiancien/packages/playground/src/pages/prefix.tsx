import React from 'react';
import { Main } from '../layouts';

const PrefixPage: React.FC = () => {
  return (
    <Main theme="light">
      <div className="p-8">
        <h2 className="text-2xl font-bold mb-4">CSS Prefix Testing</h2>
        <div className="grid gap-4">
          <div className="alert alert-warning">
            <div>
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 flex-shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
              </svg>
              <span>This page demonstrates CSS prefix usage. Check the source for prefix configurations.</span>
            </div>
          </div>
          <button className="btn btn-primary">Normal Button</button>
          <button className="lyxal-btn lyxal-btn-primary">Prefixed Button</button>
          <div className="lyxal-card bg-base-100 shadow-xl">
            <div className="lyxal-card-body">
              <h3 className="lyxal-card-title">Prefixed Card</h3>
              <p>This card uses custom CSS prefixes.</p>
            </div>
          </div>
        </div>
      </div>
    </Main>
  );
};

export default PrefixPage;
