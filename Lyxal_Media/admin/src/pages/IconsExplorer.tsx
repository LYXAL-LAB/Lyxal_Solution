import React, { useEffect, useState } from 'react';
import { Surreal } from 'surrealdb';

// Configuration DB (DEV ONLY - ne pas exposer en prod)
const db = new Surreal();
const DB_CONFIG = {
    endpoint: 'wss://lyxal-solution-06d9qbd4uptppckv6vqkthhk2k.aws-euw1.surreal.cloud',
    username: 'admin',
    password: 'admin',
    namespace: 'Lyxal_Solution',
    database: 'Developpement'
};

interface Icon {
    id: string;
    identity: {
        name: string;
        pack: string; // Record ID string
        slug: string;
    };
    resource: {
        content: string;
        viewbox: string;
    };
    presentation: {
        label: string;
        category: string;
        tags: string[];
    };
}

export const IconsExplorer: React.FC = () => {
    const [icons, setIcons] = useState<Icon[]>([]);
    const [loading, setLoading] = useState(false);
    const [page, setPage] = useState(1);
    const [search, setSearch] = useState('');
    const [totalPages, setTotalPages] = useState(1);
    const [dbReady, setDbReady] = useState(false);

    // Initialisation connexion DB
    useEffect(() => {
        const connect = async () => {
            try {
                await db.connect(DB_CONFIG.endpoint, {
                    auth: { username: DB_CONFIG.username, password: DB_CONFIG.password }
                });
                await db.use({ namespace: DB_CONFIG.namespace, database: DB_CONFIG.database });
                setDbReady(true);
            } catch (e) {
                console.error('DB Connection failed:', e);
            }
        };
        connect();
        
        return () => { db.close(); };
    }, []);

    // Debounce search
    const [debouncedSearch, setDebouncedSearch] = useState('');
    useEffect(() => {
        const timer = setTimeout(() => setDebouncedSearch(search), 500);
        return () => clearTimeout(timer);
    }, [search]);

    useEffect(() => {
        if (dbReady) fetchIcons();
    }, [page, debouncedSearch, dbReady]);

    const fetchIcons = async () => {
        setLoading(true);
        try {
            // Appel direct à la fonction SurrealDB
            const result = await db.query<[{ items: Icon[], total: number, pages: number }]>(
                `fn::icon_search($page, $limit, $q, $pack)`, 
                {
                    page: page,
                    limit: 50,
                    q: debouncedSearch,
                    pack: '' // Filtre pack vide pour l'instant
                }
            );

            // Surreal retourne un tableau de résultats, le premier résultat contient notre objet retourné par la fonction
            if (result && result[0]) {
                setIcons(result[0].items || []);
                setTotalPages(result[0].pages || 1);
            }
        } catch (e) {
            console.error('Failed to fetch icons', e);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-6 h-full flex flex-col">
            <header className="flex justify-between items-center flex-shrink-0">
                <div>
                    <h2 className="text-3xl font-bold text-dark">Icon Explorer</h2>
                    <p className="text-secondary">Search and manage your installed vector icons.</p>
                </div>
            </header>

            {/* Search Bar */}
            <div className="flex-shrink-0">
                <input
                    type="text"
                    placeholder="Search icons (name, tags)..."
                    value={search}
                    onChange={e => { setSearch(e.target.value); setPage(1); }}
                    className="w-full px-4 py-3 rounded-lg border border-slate-300 focus:outline-none focus:ring-2 focus:ring-primary shadow-sm"
                />
            </div>

            {/* Content Area */}
            <div className="flex-grow overflow-y-auto bg-white rounded-xl border border-slate-200 p-4">
                {loading ? (
                    <div className="flex justify-center items-center h-64 text-slate-400">Loading icons...</div>
                ) : icons.length === 0 ? (
                    <div className="flex flex-col justify-center items-center h-64 text-slate-400">
                        <span className="text-4xl mb-4">🔍</span>
                        <p>No icons found.</p>
                        {debouncedSearch && <button onClick={() => setSearch('')} className="text-primary mt-2 hover:underline">Clear search</button>}
                    </div>
                ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-6 lg:grid-cols-8 gap-4">
                        {icons.map(icon => (
                            <div key={icon.id} 
                                className="group flex flex-col items-center p-4 rounded-lg border border-slate-100 hover:border-blue-300 hover:shadow-md transition-all cursor-pointer bg-slate-50 hover:bg-white"
                                title={`${icon.presentation.label} (${icon.identity.slug})`}
                                onClick={() => navigator.clipboard.writeText(icon.resource.content).then(() => alert('SVG copied!'))}
                            >
                                <div 
                                    className="w-10 h-10 text-slate-700 group-hover:text-primary transition-colors flex items-center justify-center"
                                    dangerouslySetInnerHTML={{ __html: icon.resource.content }}
                                />
                                <span className="text-xs text-center text-slate-500 truncate w-full px-1 group-hover:text-dark">
                                    {icon.identity.name}
                                </span>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            {/* Footer Pagination */}
            <div className="flex justify-between items-center flex-shrink-0 pt-4 border-t border-slate-200">
                <button 
                    disabled={page <= 1}
                    onClick={() => setPage(p => p - 1)}
                    className="px-4 py-2 border rounded hover:bg-slate-50 disabled:opacity-50"
                >
                    Previous
                </button>
                <span className="text-sm text-slate-500">
                    Page {page} of {totalPages}
                </span>
                <button 
                    disabled={page >= totalPages}
                    onClick={() => setPage(p => p + 1)}
                    className="px-4 py-2 border rounded hover:bg-slate-50 disabled:opacity-50"
                >
                    Next
                </button>
            </div>
        </div>
    );
};

