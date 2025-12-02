import React, { useEffect, useRef, useState } from 'react';
import { useViewer } from '../../context/ViewerContext';
import { PDFUtils } from '../../utils/pdfUtils';
import './text_layer.css';

interface PDFPageProps {
  pageNumber: number;
}

export const PDFPage = ({ pageNumber }: PDFPageProps) => {
  const { state } = useViewer();
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const renderTaskRef = useRef<any>(null);
  
  const [textItems, setTextItems] = useState<any[]>([]);
  const [viewport, setViewport] = useState<any>(null);

  useEffect(() => {
    let isMounted = true;

    const renderPage = async () => {
      if (!state.pdfDoc || !canvasRef.current) return;

      try {
        if (renderTaskRef.current) {
            renderTaskRef.current.cancel();
        }

        const page = await state.pdfDoc.getPage(pageNumber);
        const currentViewport = page.getViewport({ scale: state.scale, rotation: state.rotation });
        
        if (!isMounted) return;
        setViewport(currentViewport);

        const canvas = canvasRef.current;
        const context = canvas.getContext('2d');
        if (!context) return;

        canvas.height = currentViewport.height;
        canvas.width = currentViewport.width;

        const renderContext = {
          canvasContext: context,
          viewport: currentViewport,
        };
        
        const renderTask = page.render(renderContext);
        renderTaskRef.current = renderTask;
        
        await renderTask.promise;
        
        if (!isMounted) return;

        const textContent = await page.getTextContent();
        if (!isMounted) return;
        setTextItems(textContent.items);

      } catch (e: any) {
          if (e?.name !== 'RenderingCancelled') {
              console.error('Page Render Error:', e);
          }
      }
    };

    renderPage();

    return () => {
        isMounted = false;
        if (renderTaskRef.current) {
            renderTaskRef.current.cancel();
        }
    };
  }, [state.pdfDoc, pageNumber, state.scale, state.rotation]);

  return (
    <div className="pdf-page" style={{ 
        width: viewport ? viewport.width : 'auto',
        height: viewport ? viewport.height : 'auto',
        position: 'relative',
        boxShadow: '0 4px 6px rgba(0,0,0,0.1)' 
    }}>
      <canvas ref={canvasRef} style={{ display: 'block' }} />
      
      {/* Text Layer */}
      {viewport && textItems.length > 0 && (
          <div className="textLayer" style={{ width: viewport.width, height: viewport.height }}>
              {textItems.map((item: any, index: number) => {
                  if (!item.str.trim()) return null;

                  const tx = PDFUtils.transform(viewport.transform, item.transform);
                  const scale = state.scale;
                  let finalWidth = (item.width || 0) * scale;
                  
                  if (finalWidth === 0 && item.str.length > 0) {
                      const estimatedScale = Math.hypot(tx[0], tx[1]);
                      finalWidth = item.str.length * estimatedScale * 0.5;
                  }
                  
                  const fontHeight = Math.hypot(tx[2], tx[3]);

                  // Highlight logic (Multi-segment)
                  const itemHighlights: React.JSX.Element[] = [];
                  if (state.search.matches.length > 0) {
                      // Filter matches that touch this page and this item
                      const relevantMatches = state.search.matches.filter((m: any) => 
                          m.pageNum === pageNumber && m.segments && m.segments.some((s: any) => s.itemIdx === index)
                      );

                      if (relevantMatches.length > 0) {
                          relevantMatches.forEach((match: any, i: number) => {
                              const segment = match.segments.find((s: any) => s.itemIdx === index);
                              if (!segment) return;

                              const isCurrent = state.search.matches[state.search.currentMatch] === match;
                              const bg = isCurrent ? 'rgba(255, 150, 50, 0.6)' : 'rgba(255, 255, 0, 0.6)';
                              
                              // Calcul précis
                              const ratioStart = segment.start / segment.textLen;
                              const ratioWidth = (segment.end - segment.start) / segment.textLen;
                              
                              const left = finalWidth * ratioStart;
                              const width = finalWidth * ratioWidth;

                              itemHighlights.push(
                                  <span key={i} style={{
                                      position: 'absolute',
                                      left: left,
                                      top: '10%', // Esthétique : centrage vertical
                                      height: '80%', 
                                      width: width,
                                      backgroundColor: bg,
                                      zIndex: 1, 
                                      pointerEvents: 'none',
                                      mixBlendMode: 'multiply',
                                      borderRadius: '2px'
                                  }} />
                              );
                          });
                      }
                  }

                  const angle = Math.atan2(tx[1], tx[0]);
                  
                  const style: React.CSSProperties = {
                      left: `${tx[4]}px`,
                      top: `${tx[5] - fontHeight}px`,
                      fontSize: `${fontHeight}px`,
                      fontFamily: item.fontName ? `"${item.fontName}", sans-serif` : 'sans-serif',
                      transform: angle !== 0 ? `rotate(${angle}rad)` : undefined,
                      width: `${finalWidth}px`, 
                      height: `${fontHeight}px`,
                      color: 'transparent',
                      position: 'absolute',
                      whiteSpace: 'pre',
                      cursor: 'text',
                      transformOrigin: '0% 0%',
                      pointerEvents: 'all'
                  };

                  return (
                      <span key={index} style={style}>
                          {itemHighlights}
                          {item.str}
                      </span>
                  );
              })}
          </div>
      )}
    </div>
  );
};
