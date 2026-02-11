import React from 'react';

export const Dashboard: React.FC = () => {
  return (
    <div className="space-y-6">
      <header className="mb-8">
        <h2 className="text-3xl font-bold text-dark">Dashboard</h2>
        <p className="text-secondary">Overview of your icon system status.</p>
      </header>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
          <h3 className="text-sm font-semibold text-secondary uppercase tracking-wider">Total Icons</h3>
          <p className="text-4xl font-bold text-dark mt-2">11,275</p>
          <div className="mt-4 text-sm text-green-500 flex items-center gap-1">
            <span>●</span> Active
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
          <h3 className="text-sm font-semibold text-secondary uppercase tracking-wider">Installed Packs</h3>
          <p className="text-4xl font-bold text-dark mt-2">3</p>
          <p className="text-sm text-secondary mt-1">Lucide, Tabler, Heroicons</p>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
          <h3 className="text-sm font-semibold text-secondary uppercase tracking-wider">Storage Usage</h3>
          <p className="text-4xl font-bold text-dark mt-2">45 MB</p>
          <p className="text-sm text-secondary mt-1">On Bunny CDN</p>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
        <h3 className="text-lg font-bold mb-4 text-dark">Quick Actions</h3>
        <div className="flex gap-4">
          <button className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-blue-600 transition">
            Sync Database
          </button>
          <button className="px-4 py-2 bg-secondary text-white rounded-lg hover:bg-slate-600 transition">
            Upload to CDN
          </button>
        </div>
      </div>
    </div>
  );
};

