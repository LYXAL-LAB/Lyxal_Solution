import { Util } from '../shared/util';
import { OPS } from '../core/ops';
import { OperatorList } from '../core/operator_list';
import { ImageKind } from '../shared/util';
import { CanvasGradient } from './pattern_helper';

export class CanvasGraphics {
    canvasCtx: CanvasRenderingContext2D;
    current: any; // Current Graphics State
    stateStack: any[] = [];
    groupStack: any[] = [];
    
    // Cached objects
    commonObjs: any = null;
    objs: any = null;

    constructor(canvasCtx: CanvasRenderingContext2D, commonObjs: any, objs: any) {
        this.canvasCtx = canvasCtx;
        this.commonObjs = commonObjs;
        this.objs = objs;
        
        this.current = {
            lineWidth: 1,
            lineCap: 'butt',
            lineJoin: 'miter',
            miterLimit: 10,
            dashArray: [],
            dashPhase: 0,
            font: null,
            fontSize: 0,
            fillColor: '#000000',
            strokeColor: '#000000',
            globalAlpha: 1,
            ctm: [1, 0, 0, 1, 0, 0] // Canvas Transform
        };
    }

    save() {
        this.canvasCtx.save();
        const old = this.current;
        this.stateStack.push(old);
        this.current = Object.assign({}, old);
        this.current.ctm = old.ctm.slice();
    }

    restore() {
        if (this.stateStack.length > 0) {
            this.current = this.stateStack.pop();
            this.canvasCtx.restore();
        }
    }

    transform(a: number, b: number, c: number, d: number, e: number, f: number) {
        this.canvasCtx.transform(a, b, c, d, e, f);
        this.current.ctm = Util.transform([a, b, c, d, e, f], this.current.ctm);
    }

    // Path Construction
    moveTo(x: number, y: number) {
        this.canvasCtx.moveTo(x, y);
    }

    lineTo(x: number, y: number) {
        this.canvasCtx.lineTo(x, y);
    }

    curveTo(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number) {
        this.canvasCtx.bezierCurveTo(x1, y1, x2, y2, x3, y3);
    }

    rectangle(x: number, y: number, w: number, h: number) {
        this.canvasCtx.rect(x, y, w, h);
    }

    closePath() {
        this.canvasCtx.closePath();
    }

    // Painting
    stroke() {
        this.canvasCtx.stroke();
    }

    closeStroke() {
        this.closePath();
        this.stroke();
    }

    fill() {
        this.canvasCtx.fill();
    }

    eoFill() {
        this.canvasCtx.fill("evenodd");
    }

    fillStroke() {
        this.fill();
        this.stroke();
    }

    endPath() {
        this.canvasCtx.beginPath();
    }

    clip() {
        this.canvasCtx.clip();
    }

    eoClip() {
        this.canvasCtx.clip("evenodd");
    }

    // Text
    beginText() {
        // Text state handled in evaluator, but canvas context might need reset
    }

    endText() {
    }

    setFont(name: string, size: number, fontObj: any) {
        // Construct CSS font string
        // This is tricky without font loading in browser.
        // Assuming fonts are loaded with @font-face using loadedName
        let fontName = "sans-serif";
        if (fontObj && fontObj.loadedName) {
            fontName = `"${fontObj.loadedName}", sans-serif`;
        }
        
        // PDF size is in text space units. Canvas expects pixels/points.
        // We usually scale by CTM in text matrix, but for HTML5 Canvas font property:
        // ctx.font = "10px FontName"
        // The transform matrix handles the scaling of the coordinate system.
        
        this.current.fontSize = size;
        this.current.font = fontName;
        this.canvasCtx.font = `${size}px ${fontName}`;
    }

    showText(glyphs: { char: string, width: number }[]) {
        // glyphs is array of { char, width }
        // We need to draw them.
        // Note: spacing is already handled by Evaluator sending position adjustments?
        // Wait, OPS.showText in my evaluator sends [{char, width}] list.
        // Evaluator (PartialEvaluator) calculates positions?
        // No, PartialEvaluator.handleShowText just pushes glyphs with their widths.
        // Positioning is complex (Tj/TJ).
        // Standard PDF.js CanvasGraphics `showText` iterates and uses current point.
        
        // Simplified approach for standard horizontal text:
        for (const glyph of glyphs) {
            if (typeof glyph.char === 'string') {
                this.canvasCtx.fillText(glyph.char, 0, 0); // Draws at 0,0 of current transform
                // Advance
                this.canvasCtx.translate(glyph.width, 0); 
            } else {
                // Adjustment (number)
                // glyph.width contains adjustment
                this.canvasCtx.translate(-glyph.width, 0); // TJ numbers are negative
            }
        }
    }

    // Images
    paintImageXObject(objId: string) {
        // Resolve object asynchronously if needed?
        // CanvasGraphics is currently synchronous execution of opList.
        // In PDF.js, OperatorList execution can be async (e.g. for image decoding or font loading).
        // For now, assume object is pre-loaded in this.objs by PDFObjects logic.
        
        const img = this.objs.get(objId);
        if (img) {
             const width = img.width;
             const height = img.height;
             
             // Check if we have image data
             if (img.data) {
                 // ... (existing implementation) ...
                 const canvas = document.createElement('canvas');
                 canvas.width = width;
                 canvas.height = height;
                 const ctx = canvas.getContext('2d');
                 if (ctx) {
                     const imageData = ctx.createImageData(width, height);
                     if (img.data.length === width * height * 4) {
                         imageData.data.set(img.data);
                     } else if (img.data.length === width * height * 3) {
                         let j = 0;
                         for (let i = 0; i < img.data.length; i += 3) {
                             imageData.data[j++] = img.data[i];
                             imageData.data[j++] = img.data[i+1];
                             imageData.data[j++] = img.data[i+2];
                             imageData.data[j++] = 255;
                         }
                     }
                     ctx.putImageData(imageData, 0, 0);
                     
                     this.canvasCtx.save();
                     this.canvasCtx.scale(1, -1);
                     this.canvasCtx.drawImage(canvas, 0, -1, 1, 1);
                     this.canvasCtx.restore();
                 }
             } else if (img instanceof ImageBitmap || (typeof HTMLImageElement !== 'undefined' && img instanceof HTMLImageElement)) {
                 // Native image support (if transferred from worker as Bitmap)
                 this.canvasCtx.save();
                 this.canvasCtx.scale(1, -1);
                 this.canvasCtx.drawImage(img, 0, -1, 1, 1);
                 this.canvasCtx.restore();
             }
        } else {
            console.warn(`Image ${objId} not found in objs cache`);
        }
    }

    // Shading
    shadingFill(shading: any) {
        // shading: { type, coords, domain, extend, colorSpace, ... }
        // We need to create a gradient and fill the current clipping path (or the whole page if no clip)
        
        // Save state (mostly for clipping)
        this.save();
        
        let style;
        const type = shading.type || shading.shadingType; // Compat check
        if (type === 2) { // Axial
             style = CanvasGradient.createLinearGradient(this.canvasCtx, shading);
        } else if (type === 3) { // Radial
             style = CanvasGradient.createRadialGradient(this.canvasCtx, shading);
        } else if (type >= 4 && type <= 7) {
            // Mesh Shading
            const figures = shading.getFigures(shading.stream, null);
            for (const fig of figures) {
                if (fig.type === 'tri') {
                    const [p0, p1, p2] = fig.coords;
                    const [c0, c1, c2] = fig.colors;
                    
                    // Average color approximation (Standard Canvas 2D doesn't support barycentric interpolation)
                    // Ideally we should create a gradient or subdivide.
                    // Taking average for "flat shading" of the mesh.
                    
                    // c0, c1, c2 are arrays of components. Average them.
                    const avgColor: number[] = [];
                    for(let k=0; k<c0.length; k++) {
                        avgColor[k] = (c0[k] + c1[k] + c2[k]) / 3;
                    }
                    
                    // Convert to RGB
                    const rgb = shading.colorSpace.getRgb(avgColor, 0);
                    const color = Util.makeHexColor(rgb[0], rgb[1], rgb[2]);
                    
                    this.canvasCtx.fillStyle = color;
                    this.canvasCtx.beginPath();
                    this.canvasCtx.moveTo(p0[0], p0[1]);
                    this.canvasCtx.lineTo(p1[0], p1[1]);
                    this.canvasCtx.lineTo(p2[0], p2[1]);
                    this.canvasCtx.fill();
                }
            }
            this.restore();
            return;
        } else {
            console.warn(`Unsupported shading type for display: ${type}`);
            this.restore();
            return;
        }
        
        this.canvasCtx.fillStyle = style;
        
        // Fill a large rect to cover everything (relying on clip if present)
        const huge = 100000;
        this.canvasCtx.fillRect(-huge, -huge, 2 * huge, 2 * huge);
        
        this.restore();
    }

    // Graphics State
    setGState(states: any[]) {
        for (const [key, value] of states) {
            switch (key) {
                case "LW": 
                    this.canvasCtx.lineWidth = value; 
                    this.current.lineWidth = value; 
                    break;
                case "LC": 
                    this.canvasCtx.lineCap = ['butt', 'round', 'square'][value] as CanvasLineCap;
                    break;
                case "LJ": 
                    this.canvasCtx.lineJoin = ['miter', 'round', 'bevel'][value] as CanvasLineJoin;
                    break;
                case "ML": 
                    this.canvasCtx.miterLimit = value; 
                    break;
                case "Font": 
                    // value is [name, size, fontObj] ?? No, usually just font dict or name
                    // In evaluator setGState, Font is special case not usually in map
                    break;
                case "BM":
                    // PDF Blend Modes need mapping to Canvas globalCompositeOperation
                    // Simple ones map directly: Multiply, Screen, Overlay, Darken, Lighten, ColorDodge, ColorBurn, HardLight, SoftLight, Difference, Exclusion
                    // Normal -> source-over
                    if (typeof value === 'string') {
                         this.canvasCtx.globalCompositeOperation = value.toLowerCase() as GlobalCompositeOperation;
                    }
                    break;
                case "SMask":
                    if (value === "None") {
                        this.current.smask = null;
                    } else {
                        this.current.smask = value;
                        // Ideally we should begin a new layer/group here with the mask applied
                    }
                    break;
                case "ca": // Non-stroking alpha
                    this.current.fillAlpha = value;
                    this.canvasCtx.globalAlpha = value; // Canvas only has one global alpha
                    break;
                case "CA": // Stroking alpha
                    this.current.strokeAlpha = value;
                     // Canvas globalAlpha applies to everything. 
                     // Handling separate fill/stroke alpha requires saving/restoring or setting globalAlpha before each op.
                    break;
            }
        }
    }

    // Groups
    beginGroup(group: any) {
        this.save();
        
        const width = this.canvasCtx.canvas.width;
        const height = this.canvasCtx.canvas.height;
        
        const layerCanvas = document.createElement('canvas');
        layerCanvas.width = width;
        layerCanvas.height = height;
        const layerCtx = layerCanvas.getContext('2d');
        
        if (layerCtx) {
            this.groupStack.push({
                ctx: this.canvasCtx,
                layer: layerCanvas,
                groupObj: group
            });
            
            this.canvasCtx = layerCtx;
            
            // Sync CTM from current state to new context
            const ctm = this.current.ctm;
            this.canvasCtx.setTransform(ctm[0], ctm[1], ctm[2], ctm[3], ctm[4], ctm[5]);
            
            // Reset alpha/composite for inside the group
            this.canvasCtx.globalAlpha = 1;
            this.canvasCtx.globalCompositeOperation = 'source-over';
        }
    }

    endGroup() {
        if (this.groupStack.length === 0) {
            this.restore();
            return;
        }
        
        const groupInfo = this.groupStack.pop();
        const layerCanvas = groupInfo.layer;
        const parentCtx = groupInfo.ctx;
        
        // Restore parent context
        this.canvasCtx = parentCtx;
        this.restore(); // Restore state (including CTM of parent)
        
        // Composite layerCanvas onto parentCtx
        parentCtx.save();
        parentCtx.setTransform(1, 0, 0, 1, 0, 0); // Identity to draw pixel-to-pixel
        
        // TODO: Handle SMask application here if the group defines one
        // or if an SMask was active when the group started.
        
        parentCtx.drawImage(layerCanvas, 0, 0);
        parentCtx.restore();
    }

    // Marked Content (Stubs)
    beginMarkedContent(tag: string) { }
    beginMarkedContentProps(tag: string, properties: any) { }
    endMarkedContent() { }

    executeOperatorList(operatorList: OperatorList) {
        const fnArray = operatorList.fnArray;
        const argsArray = operatorList.argsArray;

        for (let i = 0; i < fnArray.length; i++) {
            const fnId = fnArray[i];
            const args = argsArray[i];

            switch (fnId) {
                case OPS.save: this.save(); break;
                case OPS.restore: this.restore(); break;
                case OPS.transform: this.transform(args[0], args[1], args[2], args[3], args[4], args[5]); break;
                
                case OPS.setLineWidth: 
                    this.canvasCtx.lineWidth = args[0]; 
                    this.current.lineWidth = args[0];
                    break;
                case OPS.setLineCap: 
                    this.canvasCtx.lineCap = ['butt', 'round', 'square'][args[0]] as CanvasLineCap;
                    break;
                case OPS.setLineJoin: 
                    this.canvasCtx.lineJoin = ['miter', 'round', 'bevel'][args[0]] as CanvasLineJoin;
                    break;
                case OPS.setMiterLimit: 
                    this.canvasCtx.miterLimit = args[0];
                    break;
                
                case OPS.setFillRGBColor: 
                    this.canvasCtx.fillStyle = Util.makeHexColor(args[0], args[1], args[2]);
                    break;
                case OPS.setStrokeRGBColor: 
                    this.canvasCtx.strokeStyle = Util.makeHexColor(args[0], args[1], args[2]);
                    break;
                
                case OPS.moveTo: this.moveTo(args[0], args[1]); break;
                case OPS.lineTo: this.lineTo(args[0], args[1]); break;
                case OPS.curveTo: this.curveTo(args[0], args[1], args[2], args[3], args[4], args[5]); break;
                case OPS.rectangle: this.rectangle(args[0], args[1], args[2], args[3]); break;
                case OPS.closePath: this.closePath(); break;
                
                case OPS.stroke: this.stroke(); break;
                case OPS.fill: this.fill(); break;
                case OPS.eoFill: this.eoFill(); break;
                case OPS.fillStroke: this.fillStroke(); break;
                
                case OPS.beginText: this.beginText(); break;
                case OPS.endText: this.endText(); break;
                case OPS.setFont: this.setFont(args[0], args[1], args[2]); break;
                case OPS.showText: this.showText(args[0]); break;
                
                case OPS.paintImageXObject: this.paintImageXObject(args[0]); break;
                case OPS.shadingFill: this.shadingFill(args[0]); break;
                case OPS.setGState: this.setGState(args[0]); break;
                case OPS.beginGroup: this.beginGroup(args[0]); break;
                case OPS.endGroup: this.endGroup(); break;
                case OPS.beginMarkedContent: this.beginMarkedContent(args[0]); break;
                case OPS.beginMarkedContentProps: this.beginMarkedContentProps(args[0], args[1]); break;
                case OPS.endMarkedContent: this.endMarkedContent(); break;
                case OPS.dependency: 
                    // Should have been handled before execution or during async loop
                    // args[0] is list of objs needed.
                    break;
                
                // ... Add other ops
            }
        }
    }
}
