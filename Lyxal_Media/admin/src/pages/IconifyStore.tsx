import React, { useEffect, useState } from 'react';

interface LyxalPack {
    id: string;
    name: string;
    file: string;
    url: string;
    size: number;
    isInstalled: boolean;
}

export const LyxalStore: React.FC = () => {
    const [packs, setPacks] = useState<LyxalPack[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [installing, setInstalling] = useState<string | null>(null);
    const [deleting, setDeleting] = useState<string | null>(null);

    useEffect(() => {
        fetchPacks();
    }, []);

    const fetchPacks = async () => {
        try {
            const res = await fetch('http://localhost:3000/api/Lyxal/list');
            const data = await res.json();
            setPacks(data.items || []);
        } catch (e) {
            console.error('Failed to load Lyxal packs', e);
        } finally {
            setLoading(false);
        }
    };

    const handleInstall = async (pack: LyxalPack) => {
        if (!confirm(`Install ${pack.name}? This may take a while.`)) return;

        setInstalling(pack.id);
        try {
            const res = await fetch('http://localhost:3000/api/Lyxal/install', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url: pack.url })
            });
            
            if (res.ok) {
                // Mise à jour optimiste
                setPacks(packs.map(p => p.id === pack.id ? { ...p, isInstalled: true } : p));
                alert(`✅ ${pack.name} installed successfully!`);
            } else {
                throw new Error('Install failed');
            }
        } catch (e) {
            alert('❌ Error installing pack. Check server logs.');
        } finally {
            setInstalling(null);
        }
    };

    const handleDelete = async (pack: LyxalPack) => {
        if (!confirm(`Are you sure you want to delete ${pack.name} and ALL its icons?`)) return;

        setDeleting(pack.id);
        try {
            const res = await fetch('http://localhost:3000/api/Lyxal/delete', {
                method: 'DELETE',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ prefix: pack.id })
            });
            
            if (res.ok) {
                setPacks(packs.map(p => p.id === pack.id ? { ...p, isInstalled: false } : p));
                alert(`🗑️ ${pack.name} deleted.`);
            } else {
                throw new Error('Delete failed');
            }
        } catch (e) {
            alert('❌ Error deleting pack.');
        } finally {
            setDeleting(null);
        }
    };

    const filteredPacks = packs.filter(p => 
        p.name.toLowerCase().includes(search.toLowerCase()) || 
        p.id.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <header className="flex justify-between items-center">
                <div>
                    <h2 className="text-3xl font-bold text-dark">Lyxal Store</h2>
                    <p className="text-secondary">Browse and install packs from the official Lyxal repository.</p>
                </div>
                <div className="text-sm text-slate-500 bg-white px-3 py-1 rounded border">
                    {packs.length} collections available
                </div>
            </header>

            {/* Search */}
            <div className="sticky top-0 z-10 bg-slate-50 pt-2 pb-4">
                <input
                    type="text"
                    placeholder="Filter packs (e.g. material, carbon, brand)..."
                    value={search}
                    onChange={e => setSearch(e.target.value)}
                    className="w-full px-4 py-3 rounded-lg border border-slate-300 focus:outline-none focus:ring-2 focus:ring-primary shadow-sm"
                />
            </div>

            {/* Grid */}
            {loading ? (
                <div className="text-center py-20 text-secondary animate-pulse">Loading catalog from GitHub...</div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                    {filteredPacks.map(pack => (
                        <div key={pack.id} className={`p-4 rounded-xl border transition-all flex flex-col justify-between h-32
                            ${pack.isInstalled 
                                ? 'bg-green-50 border-green-200' 
                                : 'bg-white border-slate-200 hover:shadow-md hover:border-blue-200'
                            }
                        `}>
                            <div>
                                <div className="flex justify-between items-start">
                                    <h3 className="font-bold text-dark truncate" title={pack.name}>{pack.name}</h3>
                                    {pack.isInstalled && <span className="text-green-600 text-xs font-bold">INSTALLED</span>}
                                </div>
                                <code className="text-xs text-slate-400 mt-1 block">{pack.id}</code>
                            </div>

                            <div className="flex justify-between items-center mt-4">
                                <span className="text-xs text-slate-400">{(pack.size / 1024).toFixed(0)} KB</span>
                                
                                {pack.isInstalled ? (
                                    <div className="flex gap-2">
                                        <button 
                                            className="text-xs bg-white border border-blue-200 text-blue-700 px-3 py-1.5 rounded font-medium hover:bg-blue-50"
                                            onClick={() => handleInstall(pack)}
                                            disabled={installing === pack.id}
                                        >
                                            {installing === pack.id ? 'Syncing...' : 'Synchroniser'}
                                        </button>
                                        <button 
                                            className="text-xs bg-white border border-red-200 text-red-700 px-3 py-1.5 rounded font-medium hover:bg-red-50"
                                            onClick={() => handleDelete(pack)}
                                            disabled={deleting === pack.id}
                                        >
                                            {deleting === pack.id ? '...' : 'Delete'}
                                        </button>
                                    </div>
                                ) : (
                                    <button 
                                        onClick={() => handleInstall(pack)}
                                        disabled={installing !== null}
                                        className={`text-xs px-3 py-1.5 rounded font-medium text-white transition-colors
                                            ${installing === pack.id 
                                                ? 'bg-slate-400 cursor-wait' 
                                                : 'bg-primary hover:bg-blue-600'
                                            }
                                        `}
                                    >
                                        {installing === pack.id ? 'Installing...' : 'Install'}
                                    </button>
                                )}
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
};

