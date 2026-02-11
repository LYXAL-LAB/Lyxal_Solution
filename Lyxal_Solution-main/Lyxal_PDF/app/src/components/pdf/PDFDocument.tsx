import React, { useEffect, useRef, useCallback } from 'react';
import { useViewer } from '../../context/ViewerContext';
import { Toolbar } from '../layout/Toolbar';
import { Sidebar } from '../layout/Sidebar';
import { PDFPage } from './PDFPage';
import { useOnScreen } from '../../hooks/useOnScreen';
// @ts-ignore
import * as pdfjsLib from '/renderer/build/pdf.mjs';

// Init worker once
if (typeof window !== 'undefined' && !pdfjsLib.GlobalWorkerOptions.workerSrc) {
  pdfjsLib.GlobalWorkerOptions.workerSrc = '/renderer/build/pdf.worker.mjs';
}

const PagePlaceholder = ({ pageNumber, scale, rotation, onRegister }: any) => {
    const ref = useRef<HTMLDivElement>(null);
    const isVisible = useOnScreen(ref, '400px'); // Preload margin

    useEffect(() => {
        if (ref.current && onRegister) {
            onRegister(pageNumber, ref.current);
        }
    }, [pageNumber, onRegister]);

    // Estimation simple A4 (points)
    const width = 595 * scale; 
    const height = 842 * scale;

    return (
        <div ref={ref} className="pdf-page-container" data-page-number={pageNumber} style={{ 
            minHeight: height, 
            minWidth: width, 
            margin: '20px 0',
            display: 'flex',
            justifyContent: 'center',
            position: 'relative'
        }}>
            {isVisible ? (
                <PDFPage pageNumber={pageNumber} />
            ) : (
                <div style={{ 
                    height: height, width: width, 
                    background: 'white', display: 'flex', 
                    alignItems: 'center', justifyContent: 'center',
                    boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
                    color: '#999'
                }}>
                    Page {pageNumber}
                </div>
            )}
        </div>
    );
};

export const PDFDocument = ({ url }: { url: string }) => {
  const { state, dispatch } = useViewer();
  const containerRef = useRef<HTMLDivElement>(null);
  const pagesMap = useRef<Map<number, HTMLElement>>(new Map());
  const observerRef = useRef<IntersectionObserver | null>(null);
  const lastScrollPageRef = useRef<number>(-1);

  // Register page elements
  const handlePageRegister = useCallback((pageNum: number, el: HTMLElement) => {
      pagesMap.current.set(pageNum, el);
      if (observerRef.current) {
          observerRef.current.observe(el);
      }
  }, []);

  // Load PDF
  useEffect(() => {
    const load = async () => {
      try {
        const loadingTask = pdfjsLib.getDocument(url);
        const doc = await loadingTask.promise;
        dispatch({ type: 'SET_DOC', payload: doc });
        
        const outline = await doc.getOutline();
        if (outline) {
            dispatch({ type: 'SET_OUTLINE', payload: outline });
        }
      } catch (e) {
        console.error("Failed to load PDF:", e);
      }
    };
    load();
  }, [url, dispatch]);

  // Search Logic (Multi-segment support)
  useEffect(() => {
      if (!state.search.query || !state.pdfDoc) {
          if (state.search.matches.length > 0) {
             dispatch({ type: 'SET_SEARCH_MATCHES', payload: [] });
          }
          return;
      }
      
      const performSearch = async () => {
          const query = state.search.query.toLowerCase();
          const matches: any[] = [];
          
          console.log(`Searching for "${query}"...`);

          for (let i = 1; i <= state.totalPages; i++) {
              try {
                const page = await state.pdfDoc.getPage(i);
                const textContent = await page.getTextContent();
                
                let fullText = "";
                const textMap: { length: number, itemIdx: number }[] = [];

                // Build full text and map
                textContent.items.forEach((item: any, idx: number) => {
                    fullText += item.str;
                    // Note: PDF.js sometimes splits words across items without spaces.
                    // Ideally we should check spacing, but concatenation is good for split words.
                    // If it's separate words, usually there is a space in item.str or a separate empty item?
                    // Let's assume concatenation is what we want for "multi-line split search".
                    textMap.push({ length: item.str.length, itemIdx: idx });
                });

                const fullTextLower = fullText.toLowerCase();
                let searchIndex = 0;

                while (true) {
                    const foundIndex = fullTextLower.indexOf(query, searchIndex);
                    if (foundIndex === -1) break;
                    
                    // Map back to items
                    let currentPos = 0;
                    const segments: any[] = [];
                    
                    for (const mapItem of textMap) {
                        const itemStart = currentPos;
                        const itemEnd = currentPos + mapItem.length;
                        
                        const matchStart = foundIndex;
                        const matchEnd = foundIndex + query.length;
                        
                        const intersectStart = Math.max(itemStart, matchStart);
                        const intersectEnd = Math.min(itemEnd, matchEnd);
                        
                        if (intersectStart < intersectEnd) {
                            segments.push({
                                itemIdx: mapItem.itemIdx,
                                start: intersectStart - itemStart,
                                end: intersectEnd - itemStart,
                                textLen: mapItem.length // Needed for highlight ratio
                            });
                        }
                        currentPos += mapItem.length;
                    }
                    
                    if (segments.length > 0) {
                        matches.push({ pageNum: i, segments: segments });
                    }
                    
                    searchIndex = foundIndex + 1;
                }

              } catch (e) {
                  console.warn("Search error on page " + i, e);
              }
          }
          
          console.log(`Found ${matches.length} matches.`);
          dispatch({ type: 'SET_SEARCH_MATCHES', payload: matches });
      };
      
      // Debounce search
      const t = setTimeout(performSearch, 500);
      return () => clearTimeout(t);
  }, [state.search.query, state.pdfDoc, state.totalPages]);

  // Search Navigation
  useEffect(() => {
      if (state.search.currentMatch >= 0 && state.search.matches.length > 0) {
          const match = state.search.matches[state.search.currentMatch];
          if (match.pageNum !== state.currentPage) {
             dispatch({ type: 'SET_PAGE', payload: match.pageNum });
          }
      }
  }, [state.search.currentMatch, state.search.matches]);

  // Auto-Scale Logic
  useEffect(() => {
    if (state.scaleMode === 'custom' || !state.pdfDoc) return;
    
    let debounceTimer: any;

    const calculateScale = async () => {
        try {
            const page = await state.pdfDoc.getPage(state.currentPage);
            const viewport = page.getViewport({ scale: 1.0, rotation: state.rotation });
            
            const container = containerRef.current;
            if (!container) return;
            
            const containerWidth = container.clientWidth - 40; 
            const containerHeight = container.clientHeight - 40;
            
            let newScale = 1.0;
            
            if (state.scaleMode === 'page-width') {
                 newScale = (containerWidth - 20) / viewport.width; 
            } else if (state.scaleMode === 'page-height') {
                 const scaleW = (containerWidth - 20) / viewport.width;
                 const scaleH = (containerHeight - 20) / viewport.height;
                 newScale = Math.min(scaleW, scaleH);
            }
            
            if (Math.abs(newScale - state.scale) > 0.05) { 
                dispatch({ type: 'AUTO_SCALE', payload: newScale });
            }
        } catch (e) {
            console.error("Auto scale error:", e);
        }
    };
    
    const onResize = () => {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(calculateScale, 200); 
    };
    
    calculateScale();
    
    const resizeObserver = new ResizeObserver(onResize);
    
    if (containerRef.current) {
        resizeObserver.observe(containerRef.current);
    }
    
    return () => {
        resizeObserver.disconnect();
        clearTimeout(debounceTimer);
    };
    
  }, [state.scaleMode, state.currentPage, state.rotation, state.pdfDoc]);

  // Setup Intersection Observer for Scroll -> Page Sync
  useEffect(() => {
      if (!state.pdfDoc) return;

      const options = {
          root: containerRef.current,
          rootMargin: '-50% 0px -50% 0px', 
          threshold: 0
      };

      const callback = (entries: IntersectionObserverEntry[]) => {
          entries.forEach(entry => {
              if (entry.isIntersecting) {
                  const pageNum = parseInt(entry.target.getAttribute('data-page-number') || '1');
                  lastScrollPageRef.current = pageNum;
                  dispatch({ type: 'SET_PAGE', payload: pageNum });
              }
          });
      };

      const observer = new IntersectionObserver(callback, options);
      observerRef.current = observer;

      pagesMap.current.forEach(el => observer.observe(el));

      return () => observer.disconnect();
  }, [state.pdfDoc, dispatch]);

  // Page (Toolbar) -> Scroll Sync
  useEffect(() => {
      if (state.currentPage === lastScrollPageRef.current) {
          return;
      }

      const el = pagesMap.current.get(state.currentPage);
      if (el && containerRef.current) {
          el.scrollIntoView({ behavior: 'auto', block: 'start' });
          lastScrollPageRef.current = state.currentPage;
      }
  }, [state.currentPage]);


  if (!state.pdfDoc) return <div style={{padding: 20, color: 'white'}}>Loading Engine...</div>;

  const pages = Array.from({ length: state.totalPages }, (_, i) => i + 1);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <Toolbar />
      <div style={{ flex: 1, display: 'flex', overflow: 'hidden' }}>
        {state.isSidebarOpen && <Sidebar />}
        <div 
            ref={containerRef}
            className="pdf-scroll-container" 
            style={{ 
            flex: 1, 
            overflow: 'auto', 
            background: '#525659', 
            display: 'flex', 
            flexDirection: 'column', 
            alignItems: 'center',
            padding: '20px'
        }}>
            {pages.map(pageNum => (
                <PagePlaceholder 
                    key={pageNum} 
                    pageNumber={pageNum} 
                    scale={state.scale} 
                    rotation={state.rotation} 
                    onRegister={handlePageRegister}
                />
            ))}
        </div>
      </div>
    </div>
  );
};
