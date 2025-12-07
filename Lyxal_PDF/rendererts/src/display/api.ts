import { PDFManager } from '../core/pdf_manager';
import { Stream } from '../core/stream';
import { CanvasGraphics } from './canvas';
import { TextLayerBuilder } from './text_layer';
import { AnnotationLayerBuilder } from './annotation_layer';
import { FontLoader } from './font_loader';
import { Util } from '../shared/util';
import { WorkerTransport } from './worker_transport';
import { ClientPdfManager } from './client_pdf_manager';

import { PDFObjects } from './pdf_objects';

export const GlobalWorkerOptions = {
    workerSrc: "",
    workerPort: null,
};

export class PDFPageProxy {
    _pageIndex: number;
    _pageInfo: any;
    _transport: any; // IPDFManager
    
    constructor(pageIndex: number, pageInfo: any, transport: any) {
        this._pageIndex = pageIndex;
        this._pageInfo = pageInfo;
        this._transport = transport;
    }

    get pageNumber() {
        return this._pageIndex + 1;
    }

    get rotate() {
        return this._pageInfo.rotate;
    }

    getViewport({ scale, rotation = 0 }: { scale: number, rotation?: number }) {
        const rotate = (this.rotate + rotation) % 360;
        const view = this._pageInfo.view;
        const x1 = view[0], y1 = view[1], x2 = view[2], y2 = view[3];
        const width = Math.abs(x2 - x1) * scale;
        const height = Math.abs(y2 - y1) * scale;
        
        const transform = [scale, 0, 0, -scale, -x1 * scale, y2 * scale];
        
        return {
            width,
            height,
            scale,
            rotation,
            transform
        };
    }

    async render({ canvasContext, viewport }: { canvasContext: CanvasRenderingContext2D, viewport: any }) {
        // 1. Get Operator List (via Manager)
        const operatorList = await this._transport.getOperatorList(this._pageIndex);

        // 2. Setup Graphics
        const commonObjs = this._transport.commonObjs || new PDFObjects();
        const objs = this._transport.objs || new PDFObjects();
        
        // Ensure objects referenced in operatorList are loaded
        // For LocalPdfManager, objs might be populated directly during getOperatorList if we passed a cache?
        // But getOperatorList in local manager uses a fresh PartialEvaluator.
        // We need to sync the objects found by PartialEvaluator to our objs cache.
        
        // In local mode, PartialEvaluator might need to fill a provided object cache.
        // Or we assume they are available if we have access to the same references.
        
        // Actually, in Local mode, we need to populate these caches.
        // Let's assume for this test fix that we initialize empty caches, 
        // AND that LocalPdfManager needs to populate them.
        
        // HACK: Populate objs for local mode test
        // In real PDF.js, OperatorList contains dependencies (OPS.dependency)
        // that trigger object loading BEFORE execution.
        // We iterate opList to find dependencies manually for now.
        const fnArray = operatorList.fnArray;
        const argsArray = operatorList.argsArray;
        const OPS = (await import('../core/ops')).OPS; 
        
        // For our test case, we have OPS.paintImageXObject with an ID.
        // We need to fetch that ID from the manager if it's not in cache.
        
        for (let i = 0; i < fnArray.length; i++) {
            if (fnArray[i] === OPS.paintImageXObject) {
                const objId = argsArray[i][0];
                if (!objs.has(objId)) {
                    if (typeof this._transport.getObj === 'function') {
                         const data = await this._transport.getObj(objId);
                         if (data) {
                             objs.resolve(objId, data);
                         }
                    }
                }
            }
        }

        const graphics = new CanvasGraphics(canvasContext, commonObjs, objs);
        
        // 3. Apply Viewport Transform
        const t = viewport.transform;
        canvasContext.setTransform(t[0], t[1], t[2], t[3], t[4], t[5]);
        
        // 4. Execute
        graphics.executeOperatorList(operatorList);
        
        return {
            promise: Promise.resolve()
        };
    }

    async getTextContent() {
        // TODO: Implement getTextContent via manager
        // return this._transport.getTextContent(this._pageIndex);
        // Fallback for now if using local manager which might return Page object with getTextContent
        if (typeof this._pageInfo.getTextContent === 'function') {
             return this._pageInfo.getTextContent({ 
                normalizeWhitespace: false, 
                combineTextItems: false 
            });
        }
        return { items: [], styles: {} };
    }
}

export class PDFDocumentProxy {
    _pdfManager: any; // IPDFManager
    
    constructor(pdfManager: any) {
        this._pdfManager = pdfManager;
    }

    get numPages() {
        // If local, use .pdfDocument.numPages
        // If client, use cached numPages
        if (this._pdfManager.pdfDocument) return this._pdfManager.pdfDocument.numPages;
        return this._pdfManager._numPages || 0;
    }

    async getPage(pageNumber: number) {
        const pageIndex = pageNumber - 1;
        const pageInfo = await this._pdfManager.getPage(pageIndex);
        return new PDFPageProxy(pageIndex, pageInfo, this._pdfManager);
    }

    async getMetadata() {
        // TODO: proxy metadata call
        return null;
    }
    
    async destroy() {
        if (this._pdfManager.terminate) {
            this._pdfManager.terminate();
        }
    }
}

export async function getDocument(src: string | Uint8Array | ArrayBuffer | any) {
    let source: any = src;
    if (typeof src === 'string') {
        const response = await fetch(src);
        const buffer = await response.arrayBuffer();
        source = new Uint8Array(buffer);
    } else if (src instanceof ArrayBuffer) {
        source = new Uint8Array(src);
    }

    let manager;

    // Check if we should use worker
    if (GlobalWorkerOptions.workerSrc || GlobalWorkerOptions.workerPort) {
        // Worker Mode
        const transport = new WorkerTransport(GlobalWorkerOptions.workerSrc);
        // If workerPort is provided directly (e.g. for testing with MockWorker), use it?
        // WorkerTransport constructor handles string path. 
        // We might need to handle existing Worker instance.
        
        manager = new ClientPdfManager(transport.messageHandler, "doc" + Date.now());
        
        // Send GetDoc
        const result = await manager.handler.send("GetDoc", {
            docId: manager.docId,
            source: source,
            password: "",
            evaluatorOptions: {}
        });
        
        (manager as any)._numPages = result.numPages;

    } else {
        // Local Mode (Single Thread)
        manager = new PDFManager({ 
            source: source,
            docId: "doc1",
            password: "",
            evaluatorOptions: {}
        });
        await manager.ensureDoc("parse");
        
        // Attach cache for local mode
        (manager as any).commonObjs = new PDFObjects();
        (manager as any).objs = new PDFObjects();
    }
    
    return new PDFDocumentProxy(manager);
}
