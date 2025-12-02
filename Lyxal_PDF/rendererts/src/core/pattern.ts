import { Dict } from './primitives';
import { Stream } from './stream';
import { PDFFunctionFactory, PDFFunction } from './function';

export enum PatternType {
    TILING = 1,
    SHADING = 2
}

export class Pattern {
    static parse(obj: any, xref: any = null): Pattern | null {
        if (!obj) return null;
        
        let dict: Dict;
        if (obj instanceof Stream) {
            dict = obj.dict!;
        } else if (obj instanceof Dict) {
            dict = obj;
        } else {
            return null;
        }

        // Try to get xref from dict if not provided
        if (!xref) xref = dict.xref;

        const type = dict.get("PatternType");
        if (type === 1) return new TilingPattern(obj);
        if (type === 2) return new ShadingPattern(obj, xref);
        
        return null;
    }
}

export class TilingPattern {
    bbox: number[];
    xStep: number;
    yStep: number;
    paintType: number;
    tilingType: number;
    matrix: number[];
    stream: Stream | null;

    constructor(obj: Dict | Stream) {
         const dict = (obj instanceof Stream) ? obj.dict! : obj;
         this.stream = (obj instanceof Stream) ? obj : null;
         
         this.bbox = dict.get("BBox") || [0, 0, 0, 0];
         this.xStep = dict.get("XStep") || 0;
         this.yStep = dict.get("YStep") || 0;
         this.paintType = dict.get("PaintType");
         this.tilingType = dict.get("TilingType");
         this.matrix = dict.get("Matrix") || [1, 0, 0, 1, 0, 0];
    }
}

export class ShadingPattern {
    shadingType: number;
    coords: number[] = [];
    colorFn: PDFFunction | null = null;

    constructor(obj: Dict | Stream, xref: any) {
         const dict = (obj instanceof Stream) ? obj.dict! : obj;
         
         const shadingObj = dict.get("Shading");
         
         let shadingDict: Dict;
         if (shadingObj instanceof Stream) shadingDict = shadingObj.dict!;
         else if (shadingObj instanceof Dict) shadingDict = shadingObj;
         else shadingDict = dict;
         
         this.shadingType = shadingDict.get("ShadingType");
         this.coords = shadingDict.get("Coords") || [];
         
         const fnObj = shadingDict.get("Function");
         if (fnObj && xref) {
             const factory = new PDFFunctionFactory(xref);
             this.colorFn = factory.create(fnObj);
         }
    }
}
