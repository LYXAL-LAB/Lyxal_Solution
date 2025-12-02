import { Dict, Ref } from './primitives';
import { Stream } from './stream';

export type PDFFunction = (src: Float32Array, srcOffset: number, dest: Float32Array, destOffset: number) => void;

export class PDFFunctionFactory {
    xref: any;
    
    constructor(xref: any) {
        this.xref = xref;
    }

    create(fn: any): PDFFunction {
        const fnObj = this.xref.fetchIfRef(fn);
        return PDFFunctionParser.parse(this, fnObj);
    }
}

class PDFFunctionParser {
    static parse(factory: PDFFunctionFactory, fnObj: any): PDFFunction {
        const dict = (fnObj instanceof Stream) ? fnObj.dict! : fnObj;
        const type = dict.get("FunctionType");

        switch (type) {
            case 0: return this.constructSampled(fnObj, dict);
            case 2: return this.constructInterpolated(dict);
            case 3: return this.constructStitched(factory, dict);
            case 4: return this.constructPostScript(fnObj, dict);
            default: throw new Error("Unknown function type " + type);
        }
    }

    static constructSampled(stream: any, dict: Dict): PDFFunction {
        // TODO: Type 0 (Sampled)
        console.warn("Function Type 0 (Sampled) not fully implemented, returning identity");
        return (src, srcOffset, dest, destOffset) => {
             dest[destOffset] = src[srcOffset];
        };
    }

    static constructInterpolated(dict: Dict): PDFFunction {
        const c0 = dict.get("C0") || [0];
        const c1 = dict.get("C1") || [1];
        const n = dict.get("N");
        
        // Normalize arrays
        const c0Arr = Array.isArray(c0) ? c0 : [c0];
        const c1Arr = Array.isArray(c1) ? c1 : [c1];
        
        const diff = c0Arr.map((val: number, i: number) => (c1Arr[i] || 0) - val);
        const length = diff.length;

        return function(src, srcOffset, dest, destOffset) {
            const x = Math.pow(src[srcOffset], n);
            for (let j = 0; j < length; j++) {
                dest[destOffset + j] = c0Arr[j] + x * diff[j];
            }
        };
    }

    static constructStitched(factory: PDFFunctionFactory, dict: Dict): PDFFunction {
        const domain = dict.get("Domain");
        const encode = dict.get("Encode");
        const bounds = dict.get("Bounds");
        const fnsRef = dict.get("Functions");
        
        const fns: PDFFunction[] = [];
        for (const fnRef of fnsRef) {
            fns.push(factory.create(fnRef));
        }
        
        return function(src, srcOffset, dest, destOffset) {
            const x = src[srcOffset];
            // Find sub-function
            let i = 0;
            for (; i < bounds.length; i++) {
                if (x < bounds[i]) break;
            }
            // Simple dispatch
            // TODO: Map domain/encode
            fns[i](src, srcOffset, dest, destOffset);
        };
    }

    static constructPostScript(stream: any, dict: Dict): PDFFunction {
        // TODO: Type 4 (PostScript Calculator)
        console.warn("Function Type 4 (PostScript) not implemented");
        return (src, srcOffset, dest, destOffset) => {
             dest[destOffset] = 0; // Default black?
        };
    }
}

