import { OPS } from '../core/ops';
import { OperatorList } from '../core/operator_list';
import { Util } from '../shared/util';

export class CanvasGraphics {
    ctx: CanvasRenderingContext2D; // Or compatible interface
    commonObjs: any;
    objs: any;
    currentStack: any[] = [];
    current: any = {
        fillColor: '#000000',
        strokeColor: '#000000',
        lineWidth: 1,
        lineCap: 'butt',
        lineJoin: 'miter',
        miterLimit: 10,
        dashArray: [],
        dashPhase: 0,
        alpha: 1,
        font: null,
        fontSize: 0,
        textMatrix: Util.IDENTITY_MATRIX
    };

    constructor(ctx: CanvasRenderingContext2D, commonObjs: any, objs: any) {
        this.ctx = ctx;
        this.commonObjs = commonObjs;
        this.objs = objs;
    }

    async executeOperatorList(operatorList: OperatorList) {
        const fnArray = operatorList.fnArray;
        const argsArray = operatorList.argsArray;

        for (let i = 0; i < fnArray.length; i++) {
            const fn = fnArray[i];
            const args = argsArray[i];

            switch (fn) {
                case OPS.save: this.save(); break;
                case OPS.restore: this.restore(); break;
                case OPS.transform: this.transform(args[0], args[1], args[2], args[3], args[4], args[5]); break;
                
                // Path
                case OPS.constructPath: this.constructPath(args[0], args[1]); break;
                case OPS.stroke: this.stroke(args[0]); break;
                case OPS.fill: this.fill(args[0]); break;
                case OPS.eoFill: this.fill(args[0]); break; // EvenOdd fill logic needed
                
                // Text
                case OPS.setTextMatrix: this.setTextMatrix(args[0], args[1], args[2], args[3], args[4], args[5]); break;
                case OPS.setFont: this.setFont(args[0], args[1]); break;
                case OPS.showText: this.showText(args[0]); break;
                case OPS.setCharSpacing: this.setCharSpacing(args[0]); break;
                case OPS.setWordSpacing: this.setWordSpacing(args[0]); break;
                
                // Color
                case OPS.setFillColorN: this.setFillColorN(args); break;
                case OPS.setStrokeColorN: this.setStrokeColorN(args); break;
                
                // State
                case OPS.setLineWidth: this.setLineWidth(args[0]); break;
                case OPS.setLineCap: this.setLineCap(args[0]); break;
                case OPS.setLineJoin: this.setLineJoin(args[0]); break;
                case OPS.setMiterLimit: this.setMiterLimit(args[0]); break;
                case OPS.setDash: this.setDash(args[0], args[1]); break;
                
                // Image
                case OPS.paintImageXObject: await this.paintImageXObject(args[0]); break;
                
                default: 
                    // console.warn("Unimplemented Operator:", fn);
            }
        }
    }

    save() {
        this.ctx.save();
        this.currentStack.push(JSON.parse(JSON.stringify(this.current)));
    }

    restore() {
        this.ctx.restore();
        if (this.currentStack.length > 0) {
            this.current = this.currentStack.pop();
        }
    }

    transform(a: number, b: number, c: number, d: number, e: number, f: number) {
        this.ctx.transform(a, b, c, d, e, f);
    }

    constructPath(ops: number[], args: number[]) {
        this.ctx.beginPath();
        let i = 0;
        let j = 0;
        
        while (i < ops.length) {
            switch (ops[i]) {
                case OPS.moveTo:
                    this.ctx.moveTo(args[j], args[j+1]);
                    j += 2;
                    break;
                case OPS.lineTo:
                    this.ctx.lineTo(args[j], args[j+1]);
                    j += 2;
                    break;
                case OPS.curveTo:
                    this.ctx.bezierCurveTo(args[j], args[j+1], args[j+2], args[j+3], args[j+4], args[j+5]);
                    j += 6;
                    break;
                case OPS.rectangle:
                    this.ctx.rect(args[j], args[j+1], args[j+2], args[j+3]);
                    j += 4;
                    break;
                case OPS.closePath:
                    this.ctx.closePath();
                    break;
            }
            i++;
        }
    }

    stroke(consume: boolean) {
        this.ctx.stroke();
    }

    fill(consume: boolean) {
        this.ctx.fill();
    }

    // Text Methods
    setTextMatrix(a: number, b: number, c: number, d: number, e: number, f: number) {
        this.current.textMatrix = [a, b, c, d, e, f];
    }
    
    setFont(name: string, size: number) {
        this.current.fontName = name;
        this.current.fontSize = size;
        // In a real browser environment, we might need to map 'name' (PDF internal name)
        // to a loaded @font-face family name.
        // For now, fallback to generic.
        this.ctx.font = `${size}px sans-serif`;
    }

    setCharSpacing(spacing: number) {
        // Canvas doesn't support char spacing natively easily, usually done by manually positioning glyphs
    }

    setWordSpacing(spacing: number) {
        // Same
    }

    showText(glyphs: { char: string, width: number }[]) {
        const ctx = this.ctx;
        const currentFont = this.current.font; // Need to set font on ctx
        
        // This is a simplified text rendering.
        // PDF.js calculates exact positions.
        
        // We need to apply Text Matrix to CTM
        ctx.save();
        const tm = this.current.textMatrix;
        // transform(tm...) 
        // But ctx.transform multiplies CTM. 
        // We usually want to use current point from previous text operation if not specified?
        // showText implies we are at a position.
        
        // Actually, we should iterate glyphs and place them.
        for (const glyph of glyphs) {
            ctx.fillText(glyph.char, 0, 0); // At current origin
            ctx.translate(glyph.width, 0); // Advance
        }
        
        ctx.restore();
    }

    // Color
    setFillColorN(args: any[]) {
        if (args[0] === "TilingPattern") {
             // Handle pattern
        } else {
             const rgb = args; // Assuming RGB for now, usually args are color components
             const color = `rgb(${Math.floor(rgb[0]*255)}, ${Math.floor(rgb[1]*255)}, ${Math.floor(rgb[2]*255)})`;
             this.ctx.fillStyle = color;
             this.current.fillColor = color;
        }
    }

    setStrokeColorN(args: any[]) {
        const rgb = args;
        const color = `rgb(${Math.floor(rgb[0]*255)}, ${Math.floor(rgb[1]*255)}, ${Math.floor(rgb[2]*255)})`;
        this.ctx.strokeStyle = color;
        this.current.strokeColor = color;
    }

    // State
    setLineWidth(width: number) {
        this.ctx.lineWidth = width;
        this.current.lineWidth = width;
    }

    setLineCap(style: number) {
        const map = ['butt', 'round', 'square'];
        this.ctx.lineCap = map[style] as CanvasLineCap;
    }

    setLineJoin(style: number) {
        const map = ['miter', 'round', 'bevel'];
        this.ctx.lineJoin = map[style] as CanvasLineJoin;
    }

    setMiterLimit(limit: number) {
        this.ctx.miterLimit = limit;
    }

    setDash(array: number[], phase: number) {
        this.ctx.setLineDash(array);
        this.ctx.lineDashOffset = phase;
    }

    // Images
    async paintImageXObject(obj: any) {
        // obj is PDFImage instance
        if (obj && typeof obj.getImageData === 'function') {
             try {
                 const width = obj.width;
                 const height = obj.height;
                 const rgbaData = await obj.getImageData(); // Uint8ClampedArray
                 
                 // Browser environment assumption
                 if (typeof ImageData !== 'undefined' && typeof document !== 'undefined') {
                     const imageData = new ImageData(rgbaData, width, height);
                     
                     // Use a temporary canvas to draw the image so it can be transformed
                     const tempCanvas = document.createElement('canvas');
                     tempCanvas.width = width;
                     tempCanvas.height = height;
                     const tempCtx = tempCanvas.getContext('2d');
                     if (tempCtx) {
                         tempCtx.putImageData(imageData, 0, 0);
                         
                         // PDF images are drawn at 1x1 unit square by default, 
                         // mapped to actual size by CTM (which we already applied via transform ops?)
                         // No, usually PDF 'Do' operator draws image in the unit square (0,0) to (1,1)
                         // BUT the CTM is usually set up before 'Do' to scale this unit square to the desired size.
                         // So we draw the image at (0,0) with size (1,1).
                         // Wait, drawImage(img, 0, 0, 1, 1) ?
                         // Yes, if the CTM scales it up.
                         
                         this.ctx.save();
                         // We need to scale the image from its pixel size to 1x1 PDF unit?
                         // Or does the CTM handle the mapping from 1x1 to pixel size?
                         // In PDF, an image is a 1x1 square.
                         // So we must draw it into that 1x1 square.
                         this.ctx.scale(1 / width, -1 / height); // PDF y-axis is flipped relative to Canvas usually?
                         // Actually PDF coordinates: (0,0) is bottom-left (usually). Canvas: top-left.
                         // The initial transform usually handles the flip.
                         
                         // If we assume we are in a 1x1 space:
                         this.ctx.drawImage(tempCanvas, 0, 0, 1, 1);
                         this.ctx.restore();
                     }
                 } else {
                     // console.warn("Canvas/DOM not available for image rendering");
                 }
             } catch (e) {
                 console.error("Error painting image", e);
             }
        }
    }
}

