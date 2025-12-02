import { PDFDocument } from './libs/lyxal-core.browser.js';

console.log("🚀 Lyxal Integration Loading...");

async function saveWithLyxal() {
    console.log("💾 Saving with Lyxal Core...");
    
    const app = window.PDFViewerApplication;
    if (!app || !app.pdfDocument) return;

    // 1. Get raw data from PDF.js (with annotations)
    const data = await app.pdfDocument.saveDocument(app.pdfDocument.annotationStorage);
    
    // 2. Load into Lyxal Core
    const pdfDoc = await PDFDocument.load(data);
    
    // 3. Apply Lyxal Stamp
    const pages = pdfDoc.getPages();
    const page = pages[0];
    const { height } = page.getSize();
    
    page.drawText('Signed with Lyxal Suite', { 
        x: 20, 
        y: 20, 
        size: 10,
        color: { type: 'RGB', red: 0, green: 0.4, blue: 0.8 } // Simple color object for browser build without imports
    });

    // 4. Save
    const pdfBytes = await pdfDoc.save();
    
    // 5. Download
    const blob = new Blob([pdfBytes], { type: "application/pdf" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "lyxal_signed.pdf";
    a.click();
    URL.revokeObjectURL(url);
}

// Wait for PDF.js to be ready
// The event is 'webviewerloaded' but sometimes it's too early for 'app' to be fully ready.
// We can overwrite the method when needed.

const hook = () => {
    const app = window.PDFViewerApplication;
    if (!app) {
        setTimeout(hook, 100);
        return;
    }
    
    console.log("✅ Viewer App Found. Hooking download...");
    
    // Override download
    app._lyxal_original_download = app.download;
    app.download = async function() {
        console.log("Intercepting download request!");
        try {
            await saveWithLyxal();
        } catch (e) {
            console.error("Lyxal Save Failed", e);
            app._lyxal_original_download.apply(this, arguments);
        }
    };
};

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', hook);
} else {
    hook();
}

