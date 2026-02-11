import React, { useState, useEffect } from 'react';

interface TreeItem {
    path: string;
    mode: string;
    type: 'tree' | 'blob';
    sha: string;
    size?: number;
    url: string;
}

interface RepoBrowserProps {
    repoFullName: string;
    onClose: () => void;
    onSelectFolder: (path: string, sha: string) => void;
}

export const RepoBrowser: React.FC<RepoBrowserProps> = ({ repoFullName, onClose, onSelectFolder }) => {
    const [currentSha, setCurrentSha] = useState('main');
    const [pathHistory, setPathHistory] = useState<{name: string, sha: string}[]>([{name: 'Root', sha: 'main'}]);
    const [items, setItems] = useState<TreeItem[]>([]);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        fetchTree(currentSha);
    }, [currentSha]);

    const fetchTree = async (sha: string) => {
        setLoading(true);
        try {
            const res = await fetch(`http://localhost:3000/api/tree?repo=${repoFullName}&sha=${sha}`);
            const data = await res.json();
            setItems(data.tree || []);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    const handleNavigate = (item: TreeItem) => {
        if (item.type === 'tree') {
            setPathHistory([...pathHistory, { name: item.path, sha: item.sha }]);
            setCurrentSha(item.sha);
        }
    };

    const handleBreadcrumb = (index: number) => {
        const newHistory = pathHistory.slice(0, index + 1);
        setPathHistory(newHistory);
        setCurrentSha(newHistory[newHistory.length - 1].sha);
    };

    // Reconstituer le chemin complet (ex: icons/outline)
    const currentFullPath = pathHistory.slice(1).map(h => h.name).join('/');

    return (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
            <div className="bg-white w-full max-w-3xl h-[80vh] rounded-xl shadow-2xl flex flex-col overflow-hidden">
                
                {/* Header */}
                <div className="p-4 border-b border-slate-200 flex justify-between items-center bg-slate-50">
                    <div>
                        <h3 className="font-bold text-lg text-dark">Exploring {repoFullName}</h3>
                        <p className="text-xs text-secondary">Select the folder containing SVG icons</p>
                    </div>
                    <button onClick={onClose} className="text-slate-400 hover:text-dark">✕</button>
                </div>

                {/* Breadcrumb & Toolbar */}
                <div className="p-3 bg-white border-b border-slate-100 flex justify-between items-center">
                    <div className="flex items-center text-sm gap-1 overflow-x-auto whitespace-nowrap">
                        {pathHistory.map((h, idx) => (
                            <React.Fragment key={h.sha}>
                                {idx > 0 && <span className="text-slate-300">/</span>}
                                <button 
                                    onClick={() => handleBreadcrumb(idx)}
                                    className={`hover:underline ${idx === pathHistory.length - 1 ? 'font-bold text-dark' : 'text-primary'}`}
                                >
                                    {h.name}
                                </button>
                            </React.Fragment>
                        ))}
                    </div>
                    <button 
                        onClick={() => onSelectFolder(currentFullPath, currentSha)}
                        className="bg-green-600 text-white px-4 py-1.5 rounded text-sm font-medium hover:bg-green-700 shadow-sm"
                    >
                        Select This Folder
                    </button>
                </div>

                {/* File List */}
                <div className="flex-1 overflow-y-auto p-2">
                    {loading ? (
                        <div className="flex justify-center p-8 text-secondary animate-pulse">Loading tree...</div>
                    ) : (
                        <div className="grid grid-cols-1">
                            {items.map((item) => (
                                <div 
                                    key={item.sha}
                                    onClick={() => handleNavigate(item)}
                                    className={`flex items-center gap-3 p-2 rounded cursor-pointer ${
                                        item.type === 'tree' ? 'hover:bg-blue-50 text-dark' : 'text-slate-400 cursor-default'
                                    }`}
                                >
                                    <span className="text-xl w-6 text-center">
                                        {item.type === 'tree' ? '📁' : '📄'}
                                    </span>
                                    <span className="flex-1 text-sm font-medium truncate">{item.path}</span>
                                    {item.type === 'blob' && item.path.endsWith('.svg') && (
                                        <span className="text-[10px] bg-green-100 text-green-700 px-2 py-0.5 rounded">SVG</span>
                                    )}
                                </div>
                            ))}
                            {items.length === 0 && (
                                <div className="text-center p-8 text-secondary">Empty folder</div>
                            )}
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

