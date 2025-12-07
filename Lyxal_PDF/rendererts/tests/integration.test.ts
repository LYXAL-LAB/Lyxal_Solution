import { expect, test, describe, beforeAll } from "bun:test";
import { getDocument } from "../src/display/api";
import { createMinimalPDF } from "./architecture.test";
import { Util } from "../src/shared/util";

// Mock Canvas and DOM for Bun environment
class MockCanvas {
    width: number = 0;
    height: number = 0;
    _ctx: any;

    getContext(type: string) {
        if (!this._ctx) {
            this._ctx = new MockContext(this);
        }
        return this._ctx;
    }
}

class MockContext {
    canvas: MockCanvas;
    ops: any[] = [];
    _transform = [1, 0, 0, 1, 0, 0];

    constructor(canvas: MockCanvas) {
        this.canvas = canvas;
    }

    save() { this.ops.push({ fn: 'save' }); }
    restore() { this.ops.push({ fn: 'restore' }); }
    transform(a: number, b: number, c: number, d: number, e: number, f: number) { 
        this.ops.push({ fn: 'transform', args: [a, b, c, d, e, f] }); 
        this._transform = Util.transform([a,b,c,d,e,f], this._transform);
    }
    setTransform(a: number, b: number, c: number, d: number, e: number, f: number) {
        this.ops.push({ fn: 'setTransform', args: [a,b,c,d,e,f] });
        this._transform = [a,b,c,d,e,f];
    }
    
    // Path methods
    moveTo(x: number, y: number) { this.ops.push({ fn: 'moveTo', args: [x, y] }); }
    lineTo(x: number, y: number) { this.ops.push({ fn: 'lineTo', args: [x, y] }); }
    rect(x: number, y: number, w: number, h: number) { this.ops.push({ fn: 'rect', args: [x, y, w, h] }); }
    fill() { this.ops.push({ fn: 'fill' }); }
    stroke() { this.ops.push({ fn: 'stroke' }); }
    
    // Text
    fillText(text: string, x: number, y: number) { this.ops.push({ fn: 'fillText', args: [text, x, y] }); }
    translate(x: number, y: number) { this.ops.push({ fn: 'translate', args: [x, y] }); }
    
    // Props
    set fillStyle(v: any) { this.ops.push({ prop: 'fillStyle', value: v }); }
    set strokeStyle(v: any) { this.ops.push({ prop: 'strokeStyle', value: v }); }
    set lineWidth(v: number) { this.ops.push({ prop: 'lineWidth', value: v }); }
    set font(v: string) { this.ops.push({ prop: 'font', value: v }); }
}

// Global mocks
global.document = {
    createElement: (tag: string) => {
        if (tag === 'canvas') return new MockCanvas();
        return { style: {} };
    }
} as any;

global.window = {
    devicePixelRatio: 1
} as any;

global.Image = class {
    onload: any;
    src: string = "";
} as any;

global.Blob = class {} as any;
global.URL = { createObjectURL: () => "blob:url", revokeObjectURL: () => {} } as any;


describe("Integration: PDF Rendering Pipeline", () => {
    let pdfData: Uint8Array;

    beforeAll(() => {
        pdfData = createMinimalPDF();
    });

    test("Full Pipeline: Load, Parse, Render Page 1", async () => {
        // 1. Load Document
        const loadingTask = getDocument(pdfData.buffer as ArrayBuffer);
        const doc = await loadingTask;
        
        expect(doc.numPages).toBe(1);

        // 2. Get Page
        const page = await doc.getPage(1);
        expect(page.pageNumber).toBe(1);
        
        // 3. Get Viewport
        const viewport = page.getViewport({ scale: 1.0 });
        expect(viewport.width).toBe(612);
        expect(viewport.height).toBe(792);

        // 4. Render
        const canvas = new MockCanvas();
        const ctx = canvas.getContext("2d");
        
        await page.render({
            canvasContext: ctx as any,
            viewport: viewport
        });

        // 5. Verify Canvas Operations
        const ops = ctx.ops;
        expect(ops.length).toBeGreaterThan(0);
        
        // Check for transform setup
        const setTransformOp = ops.find((o: any) => o.fn === 'setTransform');
        expect(setTransformOp).toBeDefined();
        // [1, 0, 0, -1, 0, 792] -> Scale 1, Flip Y, Translate Y
        // Handle -0 issue
        const args = setTransformOp.args.map((n: number) => n === 0 ? 0 : n);
        expect(args).toEqual([1, 0, 0, -1, 0, 792]);

        // Check for content operations (from createMinimalPDF stream)
        // BT /F1 24 Tf 100 100 Td (Hello World) Tj ET
        
        // fillText should be present multiple times (glyph by glyph rendering in canvas.ts)
        const textOps = ops.filter((o: any) => o.fn === 'fillText');
        expect(textOps.length).toBeGreaterThan(0);
        
        const fullText = textOps.map((o: any) => o.args[0]).join("");
        expect(fullText).toBe("Hello World");
    });

    test("Text Extraction (Bidi + Unicode)", async () => {
        const loadingTask = getDocument(pdfData.buffer as ArrayBuffer);
        const doc = await loadingTask;
        const page = await doc.getPage(1);
        
        const textContent = await page.getTextContent();
        
        expect(textContent.items.length).toBeGreaterThan(0);
        const item = textContent.items[0];
        
        expect(item.str).toBe("Hello World");
        expect(item.width).toBeGreaterThan(0);
        expect(item.transform.length).toBe(6);
    });
});
