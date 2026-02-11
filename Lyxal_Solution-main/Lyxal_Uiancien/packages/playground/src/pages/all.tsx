import React from 'react';
import { Main } from '../layouts';

const AllPage: React.FC = () => {
  return (
    <Main theme="light">
      <div className="p-8 max-w-6xl mx-auto">
        <h1 className="text-4xl font-bold mb-8 text-center">All Lyxal UI Components</h1>

        {/* Keyboard Shortcuts */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold mb-4">Keyboard Shortcuts</h2>
          <div className="grid gap-4">
            <div className="flex gap-2 items-center">
              <kbd className="kbd">K</kbd>
              <kbd className="kbd kbd-xs">Xsmall</kbd>
              <kbd className="kbd kbd-sm">Small</kbd>
              <kbd className="kbd kbd-md">Medium</kbd>
              <kbd className="kbd kbd-lg">Large</kbd>
              <kbd className="kbd kbd-xl">Xlarge</kbd>
            </div>
            <div className="flex gap-2 items-center">
              <span>Press</span>
              <kbd className="kbd kbd-sm">F</kbd>
              <span>to pay respects.</span>
            </div>
            <div className="flex gap-2 items-center">
              <kbd className="kbd">ctrl</kbd>
              <span>+</span>
              <kbd className="kbd">shift</kbd>
              <span>+</span>
              <kbd className="kbd">del</kbd>
            </div>
          </div>
        </section>

        {/* Buttons */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold mb-4">Buttons</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <button className="btn">Default</button>
            <button className="btn btn-primary">Primary</button>
            <button className="btn btn-secondary">Secondary</button>
            <button className="btn btn-accent">Accent</button>
            <button className="btn btn-info">Info</button>
            <button className="btn btn-success">Success</button>
            <button className="btn btn-warning">Warning</button>
            <button className="btn btn-error">Error</button>
          </div>
        </section>

        {/* Badges */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold mb-4">Badges</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <span className="badge">Default</span>
            <span className="badge badge-primary">Primary</span>
            <span className="badge badge-secondary">Secondary</span>
            <span className="badge badge-accent">Accent</span>
            <span className="badge badge-info">Info</span>
            <span className="badge badge-success">Success</span>
            <span className="badge badge-warning">Warning</span>
            <span className="badge badge-error">Error</span>
          </div>
        </section>

        {/* Progress Bars */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold mb-4">Progress Bars</h2>
          <div className="grid gap-4">
            <progress value="20" max="100" className="progress">Default</progress>
            <progress value="25" max="100" className="progress progress-primary">Primary</progress>
            <progress value="40" max="100" className="progress progress-secondary">Secondary</progress>
            <progress value="60" max="100" className="progress progress-accent">Accent</progress>
            <progress value="80" max="100" className="progress progress-info">Info</progress>
            <progress value="90" max="100" className="progress progress-success">Success</progress>
          </div>
        </section>

        {/* Alerts */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold mb-4">Alerts</h2>
          <div className="grid gap-4">
            <div className="alert">
              <div>
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" className="stroke-info h-6 w-6 flex-shrink-0">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span>Default alert message.</span>
              </div>
            </div>
            <div className="alert alert-info">
              <div>
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" className="h-6 w-6 flex-shrink-0 stroke-current">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span>Info alert with icon.</span>
              </div>
            </div>
            <div className="alert alert-success">
              <div>
                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 flex-shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span>Success! Operation completed.</span>
              </div>
            </div>
          </div>
        </section>

        {/* Cards */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold mb-4">Cards</h2>
          <div className="grid md:grid-cols-2 gap-6">
            <div className="card bg-base-100 shadow-xl">
              <div className="card-body">
                <h3 className="card-title">Simple Card</h3>
                <p>This is a simple card component with title and content.</p>
                <div className="card-actions justify-end">
                  <button className="btn btn-primary">Action</button>
                </div>
              </div>
            </div>
            <div className="card bg-base-100 shadow-xl image-full">
              <figure>
                <div className="bg-gradient-to-r from-primary to-accent h-48 rounded-t-box"></div>
              </figure>
              <div className="card-body">
                <h3 className="card-title text-white">Image Card</h3>
                <p className="text-white/80">Card with background image placeholder.</p>
              </div>
            </div>
          </div>
        </section>

        {/* Form Elements */}
        <section className="mb-12">
          <h2 className="text-2xl font-bold mb-4">Form Elements</h2>
          <div className="grid md:grid-cols-2 gap-6">
            <div className="form-control">
              <label className="label">
                <span className="label-text">Email</span>
              </label>
              <input type="email" placeholder="your@email.com" className="input input-bordered" />
            </div>
            <div className="form-control">
              <label className="label">
                <span className="label-text">Password</span>
              </label>
              <input type="password" className="input input-bordered" />
            </div>
            <div className="form-control">
              <label className="label cursor-pointer">
                <span className="label-text">Remember me</span>
                <input type="checkbox" className="checkbox" />
              </label>
            </div>
            <div className="form-control">
              <label className="label cursor-pointer">
                <span className="label-text">Accept terms</span>
                <input type="checkbox" className="toggle toggle-primary" />
              </label>
            </div>
          </div>
        </section>

        <div className="alert alert-info">
          <div>
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" className="stroke-current h-6 w-6 flex-shrink-0">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <span>This page shows a representative sample of Lyxal UI components. For the complete collection, see the original Astro version.</span>
          </div>
        </div>
      </div>
    </Main>
  );
};

export default AllPage;
