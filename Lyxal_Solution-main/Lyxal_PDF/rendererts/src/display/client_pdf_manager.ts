import { BasePdfManager } from '../core/pdf_manager';
import { MessageHandler } from '../shared/message_handler';
import { PDFDocument } from '../core/document'; // We might need a Proxy version of Document?
import { PDFDocumentProxy } from './api'; // Circular dependency? 
// ClientPdfManager acts as the "Manager" for the API but internally uses the worker.

export class ClientPdfManager {
    handler: MessageHandler;
    docId: string;
    
    // We don't inherit from BasePdfManager because that's for Core (internal logic)
    // But API expects something with ensureDoc...
    // Actually API uses PDFDocumentProxy which wraps the manager.
    
    constructor(handler: MessageHandler, docId: string) {
        this.handler = handler;
        this.docId = docId;
    }

    async ensureDoc(prop: string, args: any[] = []): Promise<any> {
        // Proxy to worker
        // The worker expects "GetDoc" or specific actions?
        // In worker.ts: WorkerMessageHandler.createDocumentHandler returns result of loadDocument.
        // But subsequent calls?
        
        // pdf.js architecture:
        // Main thread has a "PDFManager" that mirrors the one in Worker.
        // It sends "GetData", "GetPage", etc.
        
        // For "ensureDoc", we map it to an action in worker?
        // My WorkerMessageHandler currently only handles "GetDoc", "GetPage", "GetOperatorList".
        // It doesn't expose a generic "ensureDoc" RPC.
        
        // If prop is "numPages", we can return it from cache or ask worker.
        // But "checkHeader", "parse" are done during "GetDoc".
        
        if (prop === "numPages") {
            // This should have been returned by GetDoc initially?
            // Yes, loadResult in worker returns { numPages }.
            // So ClientPdfManager should store it.
            return (this as any)._numPages;
        }
        
        // For other props, we might not need them on client side if they are internal core logic.
        return null; 
    }

    async getPage(pageIndex: number) {
        // Call worker "GetPage"
        return this.handler.send("GetPage", {
            docId: this.docId,
            pageIndex: pageIndex
        });
    }

    async getOperatorList(pageIndex: number) {
        return this.handler.send("GetOperatorList", {
            docId: this.docId,
            pageIndex: pageIndex
        });
    }
}

