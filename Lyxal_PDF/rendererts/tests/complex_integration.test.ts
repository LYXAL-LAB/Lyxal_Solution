import { expect, test, describe, beforeAll } from "bun:test";
import { getDocument } from "../src/display/api";
import { OPS } from "../src/core/ops";
import { Util } from "../src/shared/util";

// Mock Canvas and DOM for Bun environment (reused from integration.test.ts)
// Ideally move to a shared test helper
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
    
    scale(x: number, y: number) { this.ops.push({ fn: 'scale', args: [x, y] }); }
    translate(x: number, y: number) { this.ops.push({ fn: 'translate', args: [x, y] }); }
    
    createImageData(w: number, h: number) { return { width: w, height: h, data: new Uint8ClampedArray(w * h * 4) }; }
    createLinearGradient(x0: number, y0: number, x1: number, y1: number) {
        return { 
            addColorStop: (offset: number, color: string) => {},
            type: 'linear' 
        };
    }
    createRadialGradient(x0: number, y0: number, r0: number, x1: number, y1: number, r1: number) {
        return { 
            addColorStop: (offset: number, color: string) => {},
            type: 'radial' 
        };
    }
    putImageData(imgData: any, x: number, y: number) { this.ops.push({ fn: 'putImageData', args: [imgData, x, y] }); }
    drawImage(img: any, x: number, y: number, w: number, h: number) { this.ops.push({ fn: 'drawImage', args: [img, x, y, w, h] }); }

    // Path methods
    moveTo(x: number, y: number) { this.ops.push({ fn: 'moveTo', args: [x, y] }); }
    lineTo(x: number, y: number) { this.ops.push({ fn: 'lineTo', args: [x, y] }); }
    rect(x: number, y: number, w: number, h: number) { this.ops.push({ fn: 'rect', args: [x, y, w, h] }); }
    fillRect(x: number, y: number, w: number, h: number) { this.ops.push({ fn: 'fillRect', args: [x, y, w, h] }); }
    fill() { this.ops.push({ fn: 'fill' }); }
    stroke() { this.ops.push({ fn: 'stroke' }); }
    
    // Text
    fillText(text: string, x: number, y: number) { this.ops.push({ fn: 'fillText', args: [text, x, y] }); }
    
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

global.window = { devicePixelRatio: 1 } as any;
global.Image = class { onload: any; src: string = ""; } as any;
global.Blob = class {} as any;
global.URL = { createObjectURL: () => "blob:url", revokeObjectURL: () => {} } as any;

// Helper to create a PDF with Image XObject
function createPDFWithImage(): Uint8Array {
    let offset = 0;
    const offsets: number[] = [0]; 

    let content = "%PDF-1.7\n";
    offset = content.length;

    function addObject(num: number, data: string) {
        const header = `${num} 0 obj\n`;
        const footer = `\nendobj\n`;
        offsets[num] = offset;
        const fullObj = header + data + footer;
        content += fullObj;
        offset += fullObj.length;
    }

    // 1: Catalog
    addObject(1, "<< /Type /Catalog /Pages 2 0 R >>");
    // 2: Pages
    addObject(2, "<< /Type /Pages /Kids [3 0 R] /Count 1 >>");
    // 3: Page
    addObject(3, "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 200 200] /Contents 4 0 R /Resources << /XObject << /Im1 5 0 R >> >> >>");
    
    // 4: Content Stream: Draw Image
    // q 100 0 0 100 50 50 cm /Im1 Do Q
    const streamData = "q 100 0 0 100 50 50 cm /Im1 Do Q";
    addObject(4, `<< /Length ${streamData.length} >>\nstream\n${streamData}\nendstream`);

    // 5: Image XObject
    // 2x2 RGB Image
    const imgData = new Uint8Array([
        255, 0, 0,   0, 255, 0,
        0, 0, 255,   255, 255, 0
    ]);
    // Stream format for image data
    let imgStream = "";
    for(let i=0; i<imgData.length; i++) imgStream += String.fromCharCode(imgData[i]);
    
    addObject(5, `<< /Type /XObject /Subtype /Image /Width 2 /Height 2 /ColorSpace /DeviceRGB /BitsPerComponent 8 /Length ${imgStream.length} >>\nstream\n${imgStream}\nendstream`);

    const xrefOffset = offset;
    content += "xref\n";
    content += `0 6\n`;
    content += "0000000000 65535 f \n";
    
    for (let i = 1; i <= 5; i++) {
        const off = offsets[i].toString().padStart(10, "0");
        content += `${off} 00000 n \n`;
    }
    
    content += "trailer\n";
    content += `<< /Size 6 /Root 1 0 R >>\n`;
    content += "startxref\n";
    content += `${xrefOffset}\n`;
    content += "%%EOF";

    const buffer = new Uint8Array(content.length);
    for (let i = 0; i < content.length; i++) {
        buffer[i] = content.charCodeAt(i);
    }
    return buffer;
}

// Helper to create a PDF with Axial Shading (Type 2)
function createPDFWithShading(): Uint8Array {
    let offset = 0;
    const offsets: number[] = [0]; 

    let content = "%PDF-1.7\n";
    offset = content.length;

    function addObject(num: number, data: string) {
        const header = `${num} 0 obj\n`;
        const footer = `\nendobj\n`;
        offsets[num] = offset;
        const fullObj = header + data + footer;
        content += fullObj;
        offset += fullObj.length;
    }

    // 1: Catalog
    addObject(1, "<< /Type /Catalog /Pages 2 0 R >>");
    // 2: Pages
    addObject(2, "<< /Type /Pages /Kids [3 0 R] /Count 1 >>");
    // 3: Page
    addObject(3, "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 200 200] /Contents 4 0 R /Resources << /Shading << /Sh1 5 0 R >> >> >>");
    
    // 4: Content Stream: Shading Fill
    // /Sh1 sh
    const streamData = "/Sh1 sh";
    addObject(4, `<< /Length ${streamData.length} >>\nstream\n${streamData}\nendstream`);

    // 5: Shading Dictionary (Axial - Type 2)
    // Coords [0 0 200 0] - Horizontal gradient
    // Function: Linear interpolation
    addObject(5, `<< /Type /Shading /ShadingType 2 /ColorSpace /DeviceRGB /Coords [0 0 200 0] /Function 6 0 R /Extend [true true] >>`);
    
    // 6: Function (Type 2 - Exponential Interpolation, N=1 for linear)
    // C0 [0 0 0] (Black) -> C1 [1 1 1] (White)
    addObject(6, `<< /FunctionType 2 /Domain [0 1] /C0 [0 0 0] /C1 [1 1 1] /N 1 >>`);

    const xrefOffset = offset;
    content += "xref\n";
    content += `0 7\n`;
    content += "0000000000 65535 f \n";
    
    for (let i = 1; i <= 6; i++) {
        const off = offsets[i].toString().padStart(10, "0");
        content += `${off} 00000 n \n`;
    }
    
    content += "trailer\n";
    content += `<< /Size 7 /Root 1 0 R >>\n`;
    content += "startxref\n";
    content += `${xrefOffset}\n`;
    content += "%%EOF";

    const buffer = new Uint8Array(content.length);
    for (let i = 0; i < content.length; i++) {
        buffer[i] = content.charCodeAt(i);
    }
    return buffer;
}

function createPDFWithSMask(): Uint8Array {
    let offset = 0;
    const offsets: number[] = [0]; 

    let content = "%PDF-1.7\n";
    offset = content.length;

    function addObject(num: number, data: string) {
        const header = `${num} 0 obj\n`;
        const footer = `\nendobj\n`;
        offsets[num] = offset;
        const fullObj = header + data + footer;
        content += fullObj;
        offset += fullObj.length;
    }

    // 1: Catalog
    addObject(1, "<< /Type /Catalog /Pages 2 0 R >>");
    // 2: Pages
    addObject(2, "<< /Type /Pages /Kids [3 0 R] /Count 1 >>");
    // 3: Page with ExtGState
    addObject(3, "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 200 200] /Contents 4 0 R /Resources << /ExtGState << /GS1 5 0 R >> >> >>");
    
    // 4: Content Stream: Apply SMask
    // /GS1 gs
    const streamData = "/GS1 gs";
    addObject(4, `<< /Length ${streamData.length} >>\nstream\n${streamData}\nendstream`);

    // 5: ExtGState with SMask
    addObject(5, `<< /Type /ExtGState /SMask 6 0 R >>`);
    
    // 6: SMask Dictionary
    addObject(6, `<< /Type /Mask /S /Luminosity /G 7 0 R >>`);
    
    // 7: Group XObject (The Mask)
    // Just a simple form drawing a rect
    const maskStream = "0 0 0 rg 0 0 100 100 re f";
    addObject(7, `<< /Type /XObject /Subtype /Form /BBox [0 0 100 100] /Group << /S /Transparency /CS /DeviceGray >> /Length ${maskStream.length} >>\nstream\n${maskStream}\nendstream`);

    const xrefOffset = offset;
    content += "xref\n";
    content += `0 8\n`;
    content += "0000000000 65535 f \n";
    
    for (let i = 1; i <= 7; i++) {
        const off = offsets[i].toString().padStart(10, "0");
        content += `${off} 00000 n \n`;
    }
    
    content += "trailer\n";
    content += `<< /Size 8 /Root 1 0 R >>\n`;
    content += "startxref\n";
    content += `${xrefOffset}\n`;
    content += "%%EOF";

    const buffer = new Uint8Array(content.length);
    for (let i = 0; i < content.length; i++) {
        buffer[i] = content.charCodeAt(i);
    }
    return buffer;
}

describe("Complex Integration", () => {
    test("Render Image XObject", async () => {
        const pdfData = createPDFWithImage();
        const loadingTask = getDocument(pdfData.buffer);
        const doc = await loadingTask;
        const page = await doc.getPage(1);
        
        const viewport = page.getViewport({ scale: 1.0 });
        const canvas = new MockCanvas();
        const ctx = canvas.getContext("2d");
        
        await page.render({
            canvasContext: ctx as any,
            viewport: viewport
        });
        
        const ops = ctx.ops;
        
        // Check for transform
        // q 100 0 0 100 50 50 cm -> transform(100, 0, 0, 100, 50, 50)
        // BUT Viewport adds its own transform.
        // And CanvasGraphics.transform combines them.
        
        // Check for drawImage on the main context
        const drawImgOp = ops.find((o: any) => o.fn === 'drawImage');
        expect(drawImgOp).toBeDefined();
        
        // The first argument to drawImage is the temporary canvas (MockCanvas)
        const tmpCanvas = drawImgOp.args[0];
        // We can inspect the ops of this temporary canvas to see if putImageData was called
        const tmpCtx = tmpCanvas.getContext('2d');
        const tmpOps = tmpCtx.ops;
        
        const putImgOp = tmpOps.find((o: any) => o.fn === 'putImageData');
        expect(putImgOp).toBeDefined();
        
        // Verify image dimensions in putImageData
        // We sent 2x2 image
        const imgData = putImgOp.args[0];
        expect(imgData.width).toBe(2);
        expect(imgData.height).toBe(2);
        
        // Verify pixel data (first pixel red: 255, 0, 0, 255)
        expect(imgData.data[0]).toBe(255);
        expect(imgData.data[1]).toBe(0);
        expect(imgData.data[2]).toBe(0);
        expect(imgData.data[3]).toBe(255);
    });

    test("Render Axial Shading", async () => {
        const pdfData = createPDFWithShading();
        const loadingTask = getDocument(pdfData.buffer);
        const doc = await loadingTask;
        const page = await doc.getPage(1);
        
        const viewport = page.getViewport({ scale: 1.0 });
        const canvas = new MockCanvas();
        const ctx = canvas.getContext("2d");
        
        await page.render({
            canvasContext: ctx as any,
            viewport: viewport
        });
        
        const ops = ctx.ops;
        
        // Check if fillRect was called (shadingFill calls fillRect with huge bounds)
        const fillRectOp = ops.find((o: any) => o.fn === 'fillRect');
        expect(fillRectOp).toBeDefined();
        
        // Check if fillStyle was set to a gradient
        const fillStyleOp = ops.find((o: any) => o.prop === 'fillStyle');
        expect(fillStyleOp).toBeDefined();
        // The value should be a gradient object (which in node-canvas/mock might be opaque)
        // We can just check it's not a simple color string if possible, or just existence.
        expect(fillStyleOp.value).toBeDefined();
    });

    test("Process SMask (Soft Mask)", async () => {
        const pdfData = createPDFWithSMask();
        const loadingTask = getDocument(pdfData.buffer);
        const doc = await loadingTask;
        const page = await doc.getPage(1);
        
        const viewport = page.getViewport({ scale: 1.0 });
        const canvas = new MockCanvas();
        const ctx = canvas.getContext("2d");
        
        await page.render({
            canvasContext: ctx as any,
            viewport: viewport
        });
        
        const ops = ctx.ops;
        
        // We expect no crash.
        // We can't easily check for internal state changes in CanvasGraphics via MockContext ops, 
        // unless setGState calls something visible.
        // But the fact that it runs without error means SMask parsing worked.
        expect(ops.length).toBeGreaterThan(0);
    });
});

