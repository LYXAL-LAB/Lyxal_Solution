import React, { useEffect, useRef } from 'react';

export const PDFViewer = () => {
  const iframeRef = useRef<HTMLIFrameElement>(null);

  useEffect(() => {
    if (iframeRef.current) {
        // Point to our served renderer
        iframeRef.current.src = '/renderer/web/viewer.html'; 
    }
  }, []);

  return (
    <iframe 
      ref={iframeRef}
      style={{ width: '100%', height: '100%', border: 'none' }} 
      title="PDF Viewer"
    />
  );
};

