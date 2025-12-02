import { OPS } from './ops';
import { OperatorList } from './operator_list';
import { Stream } from './stream';
import { Parser, Lexer } from './parser';
import { Cmd, isCmd, EOF, Dict, Name } from './primitives';
import { GraphicsState } from './state';
import { Util } from '../shared/util';
import { Font } from './fonts';
import { PDFImage } from './image';
import { Pattern } from './pattern';

export class Evaluator {
    state: GraphicsState = new GraphicsState();
    stateStack: GraphicsState[] = [];
    resources: Dict | null = null;
    fontCache = new Map<string, Font>();
    xobjectCache = new Map<string, any>();
    patternCache = new Map<string, any>();

    constructor(resources: Dict | null = null) {
        this.resources = resources;
    }

    async loadFont(name: string): Promise<Font> {
        if (this.fontCache.has(name)) return this.fontCache.get(name)!;
        if (!this.resources) throw new Error("No resources dict");

        const fonts = this.resources.get("Font");
        if (!fonts) throw new Error("No Font dictionary in resources");

        const fontDict = fonts.get(name);
        if (!fontDict) throw new Error(`Font ${name} not found`);

        const font = await Font.create(null, fontDict, null);
        this.fontCache.set(name, font);
        return font;
    }

    async loadXObject(name: string): Promise<any> {
        if (this.xobjectCache.has(name)) return this.xobjectCache.get(name);
        if (!this.resources) throw new Error("No resources dict");

        const xobjects = this.resources.get("XObject");
        if (!xobjects) throw new Error("No XObject dictionary in resources");

        const xobjStream = xobjects.get(name); // Should be a Stream
        if (!xobjStream) throw new Error(`XObject ${name} not found`);

        const subtype = xobjStream.dict?.get("Subtype");
        if (subtype instanceof Name) {
            if (subtype.name === "Image") {
                const image = new PDFImage(xobjStream);
                this.xobjectCache.set(name, image);
                return image;
            } else if (subtype.name === "Form") {
                this.xobjectCache.set(name, xobjStream);
                return xobjStream;
            }
        }
        return null;
    }

    async loadPattern(name: string): Promise<any | null> {
        if (this.patternCache.has(name)) return this.patternCache.get(name)!;
        
        const patterns = this.resources?.get("Pattern");
        if (!patterns) return null;
        
        const patternObj = patterns.get(name);
        const pattern = Pattern.parse(patternObj);
        if (pattern) this.patternCache.set(name, pattern);
        return pattern;
    }

    async getOperatorList(stream: Stream): Promise<OperatorList> {
        const opList = new OperatorList();
        const parser = new Parser(new Lexer(stream), null, false);
        const args: any[] = [];

        while (true) {
            const obj = parser.getObj();
            if (obj === EOF) break;

            if (isCmd(obj)) {
                const cmd = obj.cmd;
                console.log("Cmd:", cmd, "Args:", args); // DEBUG
                
                // Graphics State
                if (cmd === 'q') {
                    this.stateStack.push(this.state.clone());
                    opList.addOp(OPS.save);
                }
                else if (cmd === 'Q') {
                    if (this.stateStack.length > 0) {
                        this.state = this.stateStack.pop()!;
                    }
                    opList.addOp(OPS.restore);
                }
                else if (cmd === 'cm') {
                    const matrix = args.splice(0);
                    this.state.ctm = Util.transform(matrix, this.state.ctm);
                    opList.addOp(OPS.transform, matrix);
                }
                else if (cmd === 'w') {
                    const width = args.splice(0)[0];
                    this.state.lineWidth = width;
                    opList.addOp(OPS.setLineWidth, [width]);
                }
                
                // Path Construction
                else if (cmd === 'm') opList.addOp(OPS.moveTo, args.splice(0));
                else if (cmd === 'l') opList.addOp(OPS.lineTo, args.splice(0));
                else if (cmd === 'c') opList.addOp(OPS.curveTo, args.splice(0));
                else if (cmd === 're') opList.addOp(OPS.rectangle, args.splice(0));
                else if (cmd === 'h') opList.addOp(OPS.closePath);
                
                // Path Painting
                else if (cmd === 'S') opList.addOp(OPS.stroke);
                else if (cmd === 's') opList.addOp(OPS.closeStroke);
                else if (cmd === 'f' || cmd === 'F') opList.addOp(OPS.fill);
                
                // Text Objects
                else if (cmd === 'BT') opList.addOp(OPS.beginText);
                else if (cmd === 'ET') opList.addOp(OPS.endText);
                
                // Text State
                else if (cmd === 'Tf') {
                    const size = args.pop();
                    const nameObj = args.pop();
                    if (nameObj instanceof Name) {
                        const font = await this.loadFont(nameObj.name);
                        this.state.textState.font = font; 
                        this.state.textState.fontSize = size;
                        opList.addOp(OPS.setFont, [nameObj.name, size, font]);
                    }
                }
                
                // Text Showing
                else if (cmd === 'Tj') {
                    const text = args.pop();
                    const font = this.state.textState.font;
                    
                    if (font && typeof text === 'string') {
                        let decoded = "";
                        for (let i = 0; i < text.length; i++) {
                            decoded += font.getChar(text.charCodeAt(i));
                        }
                        opList.addOp(OPS.showText, [decoded]);
                    } else {
                        opList.addOp(OPS.showText, [text]);
                    }
                }

                // Color Space
                else if (cmd === 'cs') {
                    const nameObj = args.pop();
                    const name = nameObj instanceof Name ? nameObj.name : nameObj; 
                    this.state.fillColorSpace = name;
                    opList.addOp(OPS.setFillColorSpace, [name]);
                }
                else if (cmd === 'CS') {
                    const nameObj = args.pop();
                    const name = nameObj instanceof Name ? nameObj.name : nameObj;
                    this.state.strokeColorSpace = name;
                    opList.addOp(OPS.setStrokeColorSpace, [name]);
                }

                // Set Color
                else if (cmd === 'scn') { // Non-stroking
                    if (this.state.fillColorSpace === 'Pattern') {
                         const nameObj = args.pop();
                         if (nameObj instanceof Name) {
                             const pattern = await this.loadPattern(nameObj.name);
                             const comps = args.splice(0); 
                             opList.addOp(OPS.setFillColorN, ["Pattern", pattern, comps]);
                         }
                    } else {
                         opList.addOp(OPS.setFillColorN, args.splice(0));
                    }
                }
                else if (cmd === 'SCN') { // Stroking
                    if (this.state.strokeColorSpace === 'Pattern') {
                         const nameObj = args.pop();
                         if (nameObj instanceof Name) {
                             const pattern = await this.loadPattern(nameObj.name);
                             const comps = args.splice(0); 
                             opList.addOp(OPS.setStrokeColorN, ["Pattern", pattern, comps]);
                         }
                    } else {
                         opList.addOp(OPS.setStrokeColorN, args.splice(0));
                    }
                }
                else if (cmd === 'g') { this.state.fillColorSpace = "DeviceGray"; opList.addOp(OPS.setFillGray, args.splice(0)); }
                else if (cmd === 'G') { this.state.strokeColorSpace = "DeviceGray"; opList.addOp(OPS.setStrokeGray, args.splice(0)); }
                else if (cmd === 'rg') { this.state.fillColorSpace = "DeviceRGB"; opList.addOp(OPS.setFillRGBColor, args.splice(0)); }
                else if (cmd === 'RG') { this.state.strokeColorSpace = "DeviceRGB"; opList.addOp(OPS.setStrokeRGBColor, args.splice(0)); }
                else if (cmd === 'k') { this.state.fillColorSpace = "DeviceCMYK"; opList.addOp(OPS.setFillCMYKColor, args.splice(0)); }
                else if (cmd === 'K') { this.state.strokeColorSpace = "DeviceCMYK"; opList.addOp(OPS.setStrokeCMYKColor, args.splice(0)); }

                // XObject (Images / Forms)
                else if (cmd === 'Do') {
                    const nameObj = args.pop();
                    if (nameObj instanceof Name) {
                        const xobj = await this.loadXObject(nameObj.name);
                        if (xobj instanceof PDFImage) {
                            opList.addOp(OPS.paintImageXObject, [xobj]);
                        } else {
                            // Form or Unknown
                            // console.warn("Unsupported XObject", xobj);
                        }
                    }
                }
                
                else {
                    args.length = 0;
                }
            } else {
                // Operand
                args.push(obj);
            }
        }
        return opList;
    }
}

