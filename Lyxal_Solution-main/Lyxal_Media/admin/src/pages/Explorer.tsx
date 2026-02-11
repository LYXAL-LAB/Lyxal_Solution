import React, { useState } from 'react';
import { RepoBrowser } from '../components/RepoBrowser';

interface Repo {
  id: number;
  full_name: string;
  description: string;
  html_url: string;
  stargazers_count: number;
  default_branch: string;
  owner: {
    avatar_url: string;
  };
  license?: {
    key: string;
    name: string;
  };
}

interface PreviewIcon {
    name: string;
    content: string;
}

const RepoDescription: React.FC<{ text: string }> = ({ text }) => {
    const [expanded, setExpanded] = useState(false);
    const isLong = text.length > 150;

    if (!isLong) return <p className="text-secondary mt-1 text-sm">{text}</p>;

    return (
        <div className="mt-1">
            <div className={`text-secondary text-sm ${expanded ? 'max-h-48 overflow-y-auto pr-2 custom-scrollbar' : 'line-clamp-2'}`}>
                {text}
            </div>
            <button 
                onClick={() => setExpanded(!expanded)}
                className="text-xs text-primary hover:underline mt-1 font-medium cursor-pointer flex items-center gap-1"
            >
                {expanded ? (
                    <>Show less <span className="text-[10px]">▲</span></>
                ) : (
                    <>Read more <span className="text-[10px]">▼</span></>
                )}
            </button>
        </div>
    );
};

export const Explorer: React.FC = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<Repo[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  // Gestion du preview
  const [previewRepo, setPreviewRepo] = useState<number | null>(null);
  const [previewIcons, setPreviewIcons] = useState<PreviewIcon[]>([]);
  const [loadingPreview, setLoadingPreview] = useState(false);
  
  // Gestion du browser
  const [browsingRepo, setBrowsingRepo] = useState<string | null>(null);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) return;

    setLoading(true);
    setError(null);
    setPreviewRepo(null);

    try {
      const res = await fetch(`http://localhost:3000/api/search?q=${encodeURIComponent(query)}`);
      if (!res.ok) throw new Error('Search failed');
      const data = await res.json();
      setResults(data.items || []);
    } catch (err) {
      setError('Failed to fetch repositories. Is the API server running?');
    } finally {
      setLoading(false);
    }
  };

  const handlePreview = async (repo: Repo) => {
      if (previewRepo === repo.id) {
          setPreviewRepo(null);
          return;
      }

      setPreviewRepo(repo.id);
      setLoadingPreview(true);
      setPreviewIcons([]);

      try {
          const res = await fetch(`http://localhost:3000/api/preview?repo=${repo.full_name}`);
          const data = await res.json();
          if (data.items) {
              setPreviewIcons(data.items);
          }
      } catch (e) {
          console.error(e);
      } finally {
          setLoadingPreview(false);
      }
  };

  const handleInstall = async (repo: Repo, customPath?: string) => {
    const pathMsg = customPath ? ` (Folder: ${customPath})` : '';
    if (!confirm(`Add ${repo.full_name} to packs configuration?${pathMsg}`)) return;
    
    try {
        const filterRegex = customPath 
            ? `${customPath.replace(/\//g, '\\/')}\\/.*\\.svg$` 
            : "icons/.*\\.svg$";

        await fetch('http://localhost:3000/api/config/add', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                name: repo.full_name.split('/')[1].toLowerCase(),
                repo: repo.full_name,
                branch: repo.default_branch,
                description: repo.description,
                license: repo.license?.name || 'Unknown',
                website: repo.html_url,
                filter: filterRegex
            })
        });
        alert('Pack added! Go to "Packs" page to sync.');
    } catch (e) {
        alert('Error adding pack.');
    }
  };

  return (
    <div className="space-y-6">
      <header>
        <h2 className="text-3xl font-bold text-dark">Pack Explorer</h2>
        <p className="text-secondary">Search for icon packs on GitHub and add them to your system.</p>
      </header>

      {/* Search Bar */}
      <form onSubmit={handleSearch} className="flex gap-4">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search GitHub (e.g. 'lucide', 'material icons', 'weather')"
          className="flex-1 px-4 py-3 rounded-lg border border-slate-300 focus:outline-none focus:ring-2 focus:ring-primary shadow-sm"
        />
        <button
          type="submit"
          disabled={loading}
          className="bg-primary text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-600 transition-colors disabled:opacity-50 cursor-pointer"
        >
          {loading ? 'Searching...' : 'Search'}
        </button>
      </form>

      {error && (
        <div className="bg-red-50 text-red-600 p-4 rounded-lg border border-red-200">
          {error}
        </div>
      )}

      {/* Modale Browser */}
      {browsingRepo && (
          <RepoBrowser 
            repoFullName={browsingRepo} 
            onClose={() => setBrowsingRepo(null)}
            onSelectFolder={(path) => {
                const repo = results.find(r => r.full_name === browsingRepo);
                if (repo) handleInstall(repo, path);
                setBrowsingRepo(null);
            }}
          />
      )}

      {/* Results List */}
      <div className="grid grid-cols-1 gap-4">
        {results.map((repo) => (
          <div key={repo.id} className="bg-white p-6 rounded-xl shadow-sm border border-slate-200 flex flex-col gap-4">
            <div className="flex items-start gap-4">
                <img src={repo.owner.avatar_url} alt="" className="w-12 h-12 rounded-full bg-slate-100 shrink-0" />
                
                <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-start gap-4">
                        <div className="flex-1 min-w-0">
                            <h3 className="text-lg font-bold text-dark flex items-center gap-2 flex-wrap">
                                <span className="truncate">{repo.full_name}</span>
                                <span className="text-xs font-normal px-2 py-0.5 bg-slate-100 rounded text-slate-600 border border-slate-200 shrink-0">
                                {repo.default_branch}
                                </span>
                            </h3>
                            <RepoDescription text={repo.description || 'No description provided.'} />
                        </div>
                        <div className="flex flex-col items-end gap-2 shrink-0">
                            <span className="text-sm font-medium text-yellow-600 flex items-center gap-1">
                                ⭐ {repo.stargazers_count.toLocaleString()}
                            </span>
                            {repo.license && (
                                <span className="text-xs text-slate-500">
                                    ⚖️ {repo.license.name}
                                </span>
                            )}
                        </div>
                    </div>

                    <div className="mt-4 flex gap-3">
                        <button 
                            onClick={() => handleInstall(repo)}
                            className="px-4 py-1.5 bg-dark text-white text-sm rounded-md hover:bg-slate-800 transition-colors cursor-pointer"
                        >
                        Install (Auto)
                        </button>
                        <button 
                            onClick={() => setBrowsingRepo(repo.full_name)}
                            className="px-4 py-1.5 bg-blue-50 text-blue-700 border border-blue-200 text-sm rounded-md hover:bg-blue-100 transition-colors cursor-pointer"
                        >
                        📁 Browse & Install
                        </button>
                        <button 
                            onClick={() => handlePreview(repo)}
                            className={`px-4 py-1.5 text-sm rounded-md border transition-colors cursor-pointer flex items-center gap-2
                                ${previewRepo === repo.id ? 'bg-blue-50 border-blue-200 text-blue-700' : 'bg-white border-slate-200 text-slate-700 hover:bg-slate-50'}
                            `}
                        >
                            {previewRepo === repo.id ? 'Hide Preview' : '👁️ Preview'}
                        </button>
                        <a 
                            href={repo.html_url} 
                            target="_blank" 
                            rel="noreferrer"
                            className="px-4 py-1.5 bg-slate-100 text-slate-700 text-sm rounded-md hover:bg-slate-200 transition-colors"
                        >
                        GitHub
                        </a>
                    </div>
                </div>
            </div>

            {/* Zone de Preview */}
            {previewRepo === repo.id && (
                <div className="mt-2 p-4 bg-slate-50 rounded-lg border border-slate-200">
                    <h4 className="text-xs font-semibold text-secondary uppercase tracking-wider mb-3">
                        Icon Preview (Random Sample)
                    </h4>
                    
                    {loadingPreview ? (
                        <div className="flex justify-center py-8 text-secondary">
                            <span className="animate-pulse">Loading icons from GitHub...</span>
                        </div>
                    ) : (
                        <div className="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 gap-4">
                            {previewIcons.map((icon, idx) => (
                                <div key={idx} className="flex flex-col items-center gap-2 p-2 bg-white rounded shadow-sm border border-slate-100" title={icon.name}>
                                    <div 
                                        className="w-8 h-8 text-slate-700 [&>svg]:w-full [&>svg]:h-full [&>svg]:fill-current [&>svg]:stroke-current"
                                        dangerouslySetInnerHTML={{ __html: icon.content }} 
                                    />
                                    <span className="text-[10px] text-slate-500 truncate w-full text-center">
                                        {icon.name.replace('.svg', '')}
                                    </span>
                                </div>
                            ))}
                            {previewIcons.length === 0 && (
                                <div className="col-span-full text-center py-4 text-secondary text-sm">
                                    No SVG icons found in standard folders (icons/, src/...).
                                </div>
                            )}
                        </div>
                    )}
                </div>
            )}
          </div>
        ))}

        {!loading && results.length === 0 && query && !error && (
          <div className="text-center py-12 text-secondary">
            No repositories found for "{query}".
          </div>
        )}
      </div>
    </div>
  );
};
