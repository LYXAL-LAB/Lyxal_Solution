import { Dict, Name, Ref } from './primitives';

export enum AnnotationType {
    TEXT = 1,
    LINK = 2,
    FREETEXT = 3,
    LINE = 4,
    SQUARE = 5,
    CIRCLE = 6,
    POLYGON = 7,
    POLYLINE = 8,
    HIGHLIGHT = 9,
    UNDERLINE = 10,
    SQUIGGLY = 11,
    STRIKEOUT = 12,
    STAMP = 13,
    CARET = 14,
    INK = 15,
    POPUP = 16,
    FILEATTACHMENT = 17,
    SOUND = 18,
    MOVIE = 19,
    WIDGET = 20,
    SCREEN = 21,
    PRINTERMARK = 22,
    TRAPNET = 23,
    WATERMARK = 24,
    THREED = 25,
    REDACT = 26
}

export class AnnotationFactory {
    static async create(xref: any, ref: Ref, annotationGlobals: any, idFactory: any): Promise<Annotation | null> {
        // We use fetchIfRef because we might receive a Dict directly or a Ref
        const dict = xref.fetchIfRef(ref); 
        // Note: fetchIfRef is synchronous in my XRef implementation for now, but should be async in full version.
        // Assuming sync for simplicity or using await if I upgrade XRef.
        
        if (!(dict instanceof Dict)) return null;

        const subtype = dict.get("Subtype");
        const subtypeName = subtype instanceof Name ? subtype.name : null;

        const params = { xref, ref, dict, subtype: subtypeName, annotationGlobals };

        switch (subtypeName) {
            case "Link": return new LinkAnnotation(params);
            case "Widget": return new WidgetAnnotation(params);
            case "Text": return new TextAnnotation(params);
            case "Popup": return new PopupAnnotation(params);
            case "FreeText": return new FreeTextAnnotation(params);
            case "Line": return new LineAnnotation(params);
            case "Square": return new SquareAnnotation(params);
            case "Circle": return new CircleAnnotation(params);
            case "PolyLine": return new PolylineAnnotation(params);
            case "Polygon": return new PolygonAnnotation(params);
            case "Ink": return new InkAnnotation(params);
            case "Highlight": return new HighlightAnnotation(params);
            case "Underline": return new UnderlineAnnotation(params);
            case "Squiggly": return new SquigglyAnnotation(params);
            case "StrikeOut": return new StrikeOutAnnotation(params);
            case "Stamp": return new StampAnnotation(params);
            case "FileAttachment": return new FileAttachmentAnnotation(params);
            default: return new Annotation(params);
        }
    }
}

export class Annotation {
    rect: number[] | null = null;
    contents: string = "";
    color: number[] | null = null; // RGB
    flags: number = 0;
    
    constructor(params: any) {
        const dict = params.dict;
        this.rect = dict.get("Rect") || [0, 0, 0, 0];
        this.contents = dict.get("Contents") || "";
        this.flags = dict.get("F") || 0;
        
        const c = dict.get("C");
        if (Array.isArray(c)) this.color = c;
    }
    
    hasFlag(flag: number): boolean {
        return (this.flags & flag) > 0;
    }
}

export class LinkAnnotation extends Annotation {
    url: string | null = null;
    dest: any = null;

    constructor(params: any) {
        super(params);
        const dict = params.dict;
        
        const action = dict.get("A");
        if (action instanceof Dict) {
            const type = action.get("S");
            const typeName = type instanceof Name ? type.name : null;
            
            if (typeName === "URI") {
                this.url = action.get("URI");
            } else if (typeName === "GoTo") {
                this.dest = action.get("D");
            }
        } else if (dict.has("Dest")) {
            this.dest = dict.get("Dest");
        }
    }
}

export class WidgetAnnotation extends Annotation {
    fieldName: string | null = null;
    fieldValue: string | null = null;
    fieldType: string | null = null;
    
    constructor(params: any) {
        super(params);
        const dict = params.dict;
        this.fieldType = dict.get("FT")?.name;
        this.fieldName = dict.get("T");
        this.fieldValue = dict.get("V");
        // TODO: Parent inheritance for fields
    }
}

export class TextAnnotation extends Annotation {}
export class PopupAnnotation extends Annotation {}
export class FreeTextAnnotation extends Annotation {}
export class LineAnnotation extends Annotation {}
export class SquareAnnotation extends Annotation {}
export class CircleAnnotation extends Annotation {}
export class PolylineAnnotation extends Annotation {}
export class PolygonAnnotation extends Annotation {}
export class InkAnnotation extends Annotation {}
export class HighlightAnnotation extends Annotation {}
export class UnderlineAnnotation extends Annotation {}
export class SquigglyAnnotation extends Annotation {}
export class StrikeOutAnnotation extends Annotation {}
export class StampAnnotation extends Annotation {}
export class FileAttachmentAnnotation extends Annotation {}

