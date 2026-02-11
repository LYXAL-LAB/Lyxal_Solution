import React from 'react';
import { useViewer } from '../../context/ViewerContext';
import { ZoomIn, ZoomOut, ChevronLeft, ChevronRight, RotateCw, PanelLeft, ArrowLeftRight, FileText, Search, X, ChevronUp, ChevronDown } from 'lucide-react';

const Btn = ({ children, onClick, disabled, active, title }: any) => (
    <button 
        onClick={onClick} 
        disabled={disabled}
        title={title}
        style={{ 
            padding: '5px', cursor: disabled ? 'not-allowed' : 'pointer', 
            background: active ? '#e8f0fe' : 'none', // Active state style
            border: active ? '1px solid #007bff' : '1px solid transparent',
            borderRadius: '4px',
            display: 'flex', alignItems: 'center',
            opacity: disabled ? 0.5 : 1,
            color: active ? '#007bff' : 'inherit'
        }}
    >
        {children}
    </button>
);

const SearchBar = () => {
    const { state, dispatch } = useViewer();
    const [localQuery, setLocalQuery] = React.useState('');

    // Trigger search on Enter
    const handleSearch = () => {
        if (!localQuery.trim()) return;
        dispatch({ type: 'SET_SEARCH_QUERY', payload: localQuery });
    };

    if (!state.search.isOpen) return null;

    return (
        <div style={{
            display: 'flex', alignItems: 'center', gap: '5px',
            padding: '5px 10px', background: '#fff', borderBottom: '1px solid #ddd',
            boxShadow: '0 2px 5px rgba(0,0,0,0.1)',
            position: 'absolute', top: '100%', right: '20px', zIndex: 100,
            borderRadius: '0 0 4px 4px'
        }}>
            <input 
                type="text" 
                placeholder="Rechercher..." 
                value={localQuery}
                onChange={(e) => setLocalQuery(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
                style={{ padding: '4px 8px', borderRadius: '4px', border: '1px solid #ccc', outline: 'none' }}
                autoFocus
            />
            <span style={{ fontSize: '12px', color: '#666', minWidth: '60px', textAlign: 'center' }}>
                {state.search.matches.length > 0 ? `${state.search.currentMatch + 1} / ${state.search.matches.length}` : '0 / 0'}
            </span>
            <Btn onClick={() => dispatch({ type: 'PREV_MATCH' })} disabled={state.search.matches.length === 0} title="Précédent">
                <ChevronUp size={16} />
            </Btn>
            <Btn onClick={() => dispatch({ type: 'NEXT_MATCH' })} disabled={state.search.matches.length === 0} title="Suivant">
                <ChevronDown size={16} />
            </Btn>
            <div style={{ width: 1, height: 16, background: '#eee', margin: '0 5px' }} />
            <Btn onClick={() => dispatch({ type: 'TOGGLE_SEARCH' })} title="Fermer">
                <X size={16} />
            </Btn>
        </div>
    );
};

export const Toolbar = () => {
  const { state, dispatch } = useViewer();

  return (
    <div style={{ position: 'relative' }}>
        <div style={{ 
            display: 'flex', alignItems: 'center', gap: '15px', 
            padding: '8px 15px', background: '#f5f5f5', borderBottom: '1px solid #ddd',
            color: '#333'
        }}>
        {/* Sidebar Toggle */}
        <Btn onClick={() => dispatch({ type: 'TOGGLE_SIDEBAR' })} active={state.isSidebarOpen} title="Barre latérale">
            <PanelLeft size={20} />
        </Btn>

        <div style={{ width: 1, height: 24, background: '#e0e0e0' }} />

        {/* Pagination */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
            <Btn disabled={state.currentPage <= 1} onClick={() => dispatch({ type: 'SET_PAGE', payload: state.currentPage - 1 })} title="Page précédente">
                <ChevronLeft size={20} />
            </Btn>
            <span style={{minWidth: '80px', textAlign: 'center'}}>
                {state.currentPage} / {state.totalPages || '--'}
            </span>
            <Btn disabled={state.currentPage >= state.totalPages} onClick={() => dispatch({ type: 'SET_PAGE', payload: state.currentPage + 1 })} title="Page suivante">
                <ChevronRight size={20} />
            </Btn>
        </div>

        <div style={{flex: 1}}></div>

        {/* Zoom Modes */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
            <Btn 
                onClick={() => dispatch({ type: 'SET_SCALE_MODE', payload: 'page-width' })} 
                active={state.scaleMode === 'page-width'}
                title="Ajuster à la largeur"
            >
                <ArrowLeftRight size={18} />
            </Btn>
            <Btn 
                onClick={() => dispatch({ type: 'SET_SCALE_MODE', payload: 'page-height' })} 
                active={state.scaleMode === 'page-height'}
                title="Page entière"
            >
                <FileText size={18} />
            </Btn>
        </div>

        <div style={{ width: 1, height: 24, background: '#e0e0e0', margin: '0 10px' }} />

        {/* Search Toggle */}
        <Btn onClick={() => dispatch({ type: 'TOGGLE_SEARCH' })} active={state.search.isOpen} title="Rechercher (Ctrl+F)">
            <Search size={20} />
        </Btn>

        <div style={{ width: 1, height: 24, background: '#e0e0e0', margin: '0 10px' }} />

        {/* Rotation */}
        <Btn onClick={() => dispatch({ type: 'ROTATE_CW' })} title="Rotation">
            <RotateCw size={20} />
        </Btn>

        {/* Zoom */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
            <Btn onClick={() => {
                const ZOOM_LEVELS = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0];
                const levels = [...ZOOM_LEVELS].reverse();
                const prev = levels.find(z => z < state.scale - 0.01) || 0.25;
                dispatch({ type: 'SET_SCALE', payload: prev });
            }} title="Zoom arrière">
                <ZoomOut size={20} />
            </Btn>
            <span style={{minWidth: '50px', textAlign: 'center'}}>{Math.round(state.scale * 100)}%</span>
            <Btn onClick={() => {
                const ZOOM_LEVELS = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0];
                const next = ZOOM_LEVELS.find(z => z > state.scale + 0.01) || 3.0;
                dispatch({ type: 'SET_SCALE', payload: next });
            }} title="Zoom avant">
                <ZoomIn size={20} />
            </Btn>
        </div>
        </div>
        <SearchBar />
    </div>
  );
};
