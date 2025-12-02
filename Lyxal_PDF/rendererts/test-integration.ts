import { PDFDocument } from './src/core/document';
import { Stream } from './src/core/stream';
import { Evaluator } from './src/core/evaluator';
import { CanvasGraphics } from './src/display/canvas';
import { OPS } from './src/core/ops';

// Mock Canvas
class MockContext {
    calls: string[] = [];
    save() { this.calls.push("save"); }
    restore() { this.calls.push("restore"); }
    transform() {}
    beginPath() {}
    moveTo() {}
    lineTo() {}
    stroke() {}
    fill() {}
    set fillStyle(v: any) {}
    set strokeStyle(v: any) {}
    fillText(text: string, x: number, y: number) { this.calls.push(`fillText('${text}',${x},${y})`); }
    translate() {}
    scale() {}
    drawImage() { this.calls.push("drawImage"); }
}

async function run() {
    // 1. Create Synthetic PDF
    // Minimal PDF with 1 page, 1 font, 1 image, and some content stream
    // This is hard to construct manually as a binary stream.
    // Instead, we will construct the object graph directly if possible, or use a known simple PDF buffer.
    
    // For this test, I'll mock the internal components to skip the Parser for now, 
    // and test Evaluator -> CanvasGraphics directly with complex objects.
    
    const mockImage = {
        width: 100,
        height: 100,
        getImageData: async () => new Uint8ClampedArray(100*100*4)
    };
    
    const evaluator = new Evaluator(null);
    evaluator.xobjectCache.set("Img1", mockImage);
    
    // Create an OperatorList manually or use Evaluator to parse a stream?
    // Let's use Evaluator to parse a stream of commands.
    
    const content = "BT /F1 12 Tf (Hello) Tj ET q 100 0 0 100 0 0 cm /Img1 Do Q";
    const stream = new Stream(new TextEncoder().encode(content));
    
    // Mock loadFont
    evaluator.loadFont = async (name) => {
        return {
            name,
            getChar: (c) => String.fromCharCode(c),
            getWidth: () => 500 // 0.5 width
        } as any;
    };
    
    const opList = await evaluator.getOperatorList(stream);
    
    console.log("Operator List generated with", opList.fnArray.length, "ops");
    
    const ctx = new MockContext();
    const graphics = new CanvasGraphics(ctx as any, {}, {});
    
    // Inject mock DOM for image test (Node environment hack)
    global.ImageData = class { constructor(data, w, h) {} } as any;
    global.document = {
        createElement: () => ({
            width: 0, height: 0,
            getContext: () => ({
                putImageData: () => {},
            })
        })
    } as any;

    await graphics.executeOperatorList(opList);
    
    console.log("Canvas Calls:", ctx.calls);
    
    if (ctx.calls.some(c => c.includes("fillText")) && ctx.calls.includes("drawImage")) {
        console.log("Integration Test Passed");
    } else {
        console.error("Integration Test Failed");
    }
}

run();

