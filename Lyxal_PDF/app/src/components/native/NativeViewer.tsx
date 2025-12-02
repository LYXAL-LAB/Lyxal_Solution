import React, { useEffect, useState, useRef } from 'react';
// @ts-ignore
import * as pdfjsLib from '/renderer/build/pdf.mjs';

// Set worker src (using our server mapping)
pdfjsLib.GlobalWorkerOptions.workerSrc = '/renderer/build/pdf.worker.mjs';

export const NativeViewer = () => {
  const [doc, setDoc] = useState<any>(null);
  const [page, setPage] = useState<any>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [error, setError] = useState<string>('');

  useEffect(() => {
    const load = async () => {
      try {
        console.log('🚀 NativeViewer: Loading Document...');
        const loadingTask = pdfjsLib.getDocument('/renderer/web/compressed.tracemonkey-pldi-09.pdf');
        const d = await loadingTask.promise;
        setDoc(d);
        console.log(`✅ Document Loaded. Pages: ${d.numPages}`);
        
        const p = await d.getPage(1);
        setPage(p);
      } catch (e: any) {
          console.error(e);
          setError(e.message);
      }
    };
    load();
  }, []);

  useEffect(() => {
    if (page && canvasRef.current) {
      const viewport = page.getViewport({ scale: 1.5 });
      const canvas = canvasRef.current;
      const context = canvas.getContext('2d');

      if (context) {
        canvas.height = viewport.height;
        canvas.width = viewport.width;

        const renderContext = {
            canvasContext: context,
            viewport: viewport,
        };
        page.render(renderContext);
      }
    }
  }, [page]);

  return (
    <div style={{ border: '2px solid #0066CC', margin: '20px', padding: '10px', background: '#fff', color: '#000' }}>
      <h3 style={{margin: 0, borderBottom: '1px solid #eee', paddingBottom: '10px'}}>Native React Renderer (Phase 1 POC)</h3>
      {error && <p style={{color: 'red'}}>Error: {error}</p>}
      {!doc && !error && <p>Loading Engine & Document...</p>}
      {doc && <p><strong>Status:</strong> Document Loaded ({doc.numPages} pages)</p>}
      
      <div style={{ overflow: 'auto', border: '1px solid #ccc', background: '#eee', padding: '20px', display: 'flex', justifyContent: 'center' }}>
         <canvas ref={canvasRef} style={{boxShadow: '0 2px 5px rgba(0,0,0,0.2)'}} />
      </div>
    </div>
  );
};

