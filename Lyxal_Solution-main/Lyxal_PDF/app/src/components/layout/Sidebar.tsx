import React, { useEffect, useRef, useState } from 'react';
import { useViewer } from '../../context/ViewerContext';
import { useOnScreen } from '../../hooks/useOnScreen';
import { Grid, List, ChevronRight, ChevronDown } from 'lucide-react';

const Thumbnail = ({ pageNumber, isActive, onClick }: { pageNumber: number, isActive: boolean, onClick: () => void }) => {
    const { state } = useViewer();
    const canvasRef = useRef<HTMLCanvasElement>(null);
    const containerRef = useRef<HTMLDivElement>(null);
    const isVisible = useOnScreen(containerRef, '100px');
    const [rendered, setRendered] = useState(false);

    // Auto-scroll sidebar to keep active thumbnail in view
    useEffect(() => {
        if (isActive && containerRef.current) {
            containerRef.current.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }, [isActive]);

    useEffect(() => {
        if (!isVisible || !state.pdfDoc || rendered) return;

        let isMounted = true;
        const renderThumb = async () => {
            try {
                const page = await state.pdfDoc.getPage(pageNumber);
                if (!isMounted) return;

                // Calculer l'échelle pour faire tenir dans 100px de large
                const viewportRaw = page.getViewport({ scale: 1.0 });
                const desiredWidth = 100;
                const scale = desiredWidth / viewportRaw.width;
                const viewport = page.getViewport({ scale });

                const canvas = canvasRef.current;
                if (!canvas) return;

                canvas.height = viewport.height;
                canvas.width = viewport.width;

                const context = canvas.getContext('2d');
                if (!context) return;

                await page.render({
                    canvasContext: context,
                    viewport: viewport
                }).promise;
                
                if (isMounted) setRendered(true);
            } catch (e) {
                console.error("Thumb render error", e);
            }
        };

        renderThumb();
        return () => { isMounted = false; };
    }, [isVisible, state.pdfDoc, pageNumber, rendered]);

    return (
        <div 
            ref={containerRef}
            onClick={onClick}
            style={{
                margin: '10px 0',
                cursor: 'pointer',
                border: isActive ? '2px solid #007bff' : '2px solid transparent',
                borderRadius: '4px',
                padding: '4px',
                background: isActive ? '#e8f0fe' : 'transparent',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center'
            }}
        >
            <div style={{ 
                width: '100px', 
                minHeight: '140px', 
                background: 'white', 
                boxShadow: '0 1px 3px rgba(0,0,0,0.2)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
            }}>
                <canvas ref={canvasRef} style={{ display: 'block', maxWidth: '100%' }} />
            </div>
            <span style={{ fontSize: '11px', color: '#333', marginTop: '4px' }}>{pageNumber}</span>
        </div>
    );
};

const OutlineItem = ({ item, level = 0, onNavigate }: any) => {
    const [expanded, setExpanded] = useState(false);
    const hasChildren = item.items && item.items.length > 0;

    return (
        <div>
            <div 
                style={{ 
                    paddingLeft: `${level * 15 + 10}px`, 
                    paddingRight: '10px',
                    paddingTop: '6px',
                    paddingBottom: '6px',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    fontSize: '13px',
                    color: '#333',
                }}
                className="outline-item"
                onClick={() => onNavigate(item.dest)}
                onMouseEnter={(e) => e.currentTarget.style.background = '#e9ecef'}
                onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
            >
                {hasChildren && (
                    <div 
                        onClick={(e) => { e.stopPropagation(); setExpanded(!expanded); }}
                        style={{ marginRight: '5px', display: 'flex', alignItems: 'center', width: '20px', justifyContent: 'center' }}
                    >
                        {expanded ? <ChevronDown size={14} /> : <ChevronRight size={14} />}
                    </div>
                )}
                {!hasChildren && <div style={{ width: 25 }} />}
                <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }} title={item.title}>
                    {item.title}
                </span>
            </div>
            {hasChildren && expanded && (
                <div>
                    {item.items.map((child: any, i: number) => (
                        <OutlineItem key={i} item={child} level={level + 1} onNavigate={onNavigate} />
                    ))}
                </div>
            )}
        </div>
    );
};

export const Sidebar = () => {
  const { state, dispatch } = useViewer();
  const [activeTab, setActiveTab] = useState<'thumbs' | 'outline'>('thumbs');
  const pages = Array.from({ length: state.totalPages }, (_, i) => i + 1);

  const handleNavigate = async (dest: any) => {
      try {
          if (!dest) return;
          
          if (typeof dest === 'string') {
               dest = await state.pdfDoc.getDestination(dest);
          }
          
          if (dest && Array.isArray(dest)) {
              // dest[0] is the page reference
              const index = await state.pdfDoc.getPageIndex(dest[0]);
              dispatch({ type: 'SET_PAGE', payload: index + 1 });
          }
      } catch (err) {
          console.error("Navigation error:", err);
      }
  };

  return (
    <div style={{
        width: '240px',
        background: '#f8f9fa',
        borderRight: '1px solid #dee2e6',
        display: 'flex',
        flexDirection: 'column',
        flexShrink: 0,
        height: '100%'
    }}>
      {/* Tabs */}
      <div style={{ display: 'flex', borderBottom: '1px solid #ddd', background: '#fff' }}>
          <button 
            onClick={() => setActiveTab('thumbs')}
            style={{ 
                flex: 1, padding: '10px', border: 'none', background: 'none', 
                borderBottom: activeTab === 'thumbs' ? '2px solid #007bff' : '2px solid transparent',
                cursor: 'pointer', color: activeTab === 'thumbs' ? '#007bff' : '#666',
                display: 'flex', alignItems: 'center', justifyContent: 'center'
            }}
            title="Miniatures"
          >
              <Grid size={18} />
          </button>
          <button 
            onClick={() => setActiveTab('outline')}
            style={{ 
                flex: 1, padding: '10px', border: 'none', background: 'none',
                borderBottom: activeTab === 'outline' ? '2px solid #007bff' : '2px solid transparent',
                cursor: 'pointer', color: activeTab === 'outline' ? '#007bff' : '#666',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                opacity: state.outline ? 1 : 0.5
            }}
            disabled={!state.outline}
            title={!state.outline ? "Aucun sommaire" : "Sommaire"}
          >
              <List size={18} />
          </button>
      </div>

      {/* Content */}
      <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden' }}>
          {activeTab === 'thumbs' ? (
             <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '10px 0' }}>
                {pages.map(pageNum => (
                    <Thumbnail 
                        key={pageNum} 
                        pageNumber={pageNum} 
                        isActive={state.currentPage === pageNum}
                        onClick={() => dispatch({ type: 'SET_PAGE', payload: pageNum })}
                    />
                ))}
             </div>
          ) : (
             <div style={{ padding: '10px 0' }}>
                 {state.outline && state.outline.length > 0 ? (
                     state.outline.map((item: any, i: number) => (
                         <OutlineItem key={i} item={item} onNavigate={handleNavigate} />
                     ))
                 ) : (
                     <div style={{ padding: 20, textAlign: 'center', color: '#999', fontSize: '13px' }}>
                         Aucun sommaire disponible.
                     </div>
                 )}
             </div>
          )}
      </div>
    </div>
  );
};
