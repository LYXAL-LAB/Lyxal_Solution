import { Stream } from './stream';
import { XRef } from './xref';
import { Dict, Ref, Name } from './primitives';
import { AnnotationFactory, Annotation } from './annotation';

export class Page {
    pageIndex: number;
    pageDict: Dict;
    xref: XRef;

    constructor(pageIndex: number, pageDict: Dict, xref: XRef) {
        this.pageIndex = pageIndex;
        this.pageDict = pageDict;
        this.xref = xref;
    }

    get content() {
        return this.pageDict.getArray("Contents");
    }

    get resources() {
        return this.pageDict.get("Resources") || new Dict();
    }

    async getAnnotations(): Promise<Annotation[]> {
        const annots = this.pageDict.get("Annots");
        if (!Array.isArray(annots)) return [];
        
        const results: Annotation[] = [];
        for (const ref of annots) {
            try {
                const annot = await AnnotationFactory.create(this.xref, ref, null, null);
                if (annot) results.push(annot);
            } catch (e) {
                console.warn("Failed to parse annotation", e);
            }
        }
        return results;
    }
}

export class PDFDocument {
    stream: Stream;
    xref: XRef;
    catalog: Dict | null = null;
    version: string | null = null;

    constructor(stream: Stream) {
        this.stream = stream;
        this.xref = new XRef(stream);
    }

    parse() {
        this.checkHeader();
        this.xref.parse();
        this.catalog = this.xref.root;
    }

    checkHeader() {
        this.stream.reset();
        // Check %PDF-
        const header = [0x25, 0x50, 0x44, 0x46, 0x2d]; // %PDF-
        for (let i = 0; i < header.length; i++) {
            if (this.stream.getByte() !== header[i]) {
                // Warning or loose check?
                // console.warn("Invalid PDF header signature");
            }
        }
        // Read version
        // ...
    }

    get numPages(): number {
        if (!this.catalog) return 0;
        const pages = this.catalog.get("Pages");
        return pages?.get("Count") || 0;
    }

    async getPage(pageIndex: number): Promise<Page> {
        if (!this.catalog) throw new Error("Catalog not parsed");
        const pagesRoot = this.catalog.get("Pages");
        
        return this.traversePages(pagesRoot, pageIndex);
    }

    private async traversePages(pagesNode: Dict, targetIndex: number): Promise<Page> {
        // Simplified recursive traversal
        // Real implementation handles caching and balanced trees
        
        const kids = pagesNode.get("Kids");
        if (!Array.isArray(kids)) {
             throw new Error("Pages tree missing Kids");
        }

        let currentCount = 0;
        
        for (let kidRef of kids) {
            let kid = kidRef;
            if (kid instanceof Ref) {
                kid = await this.xref.fetchAsync(kid);
            }
            
            const type = kid.get("Type");
            if (type.name === "Page") {
                if (currentCount === targetIndex) {
                    return new Page(targetIndex, kid, this.xref);
                }
                currentCount++;
            } else if (type.name === "Pages") {
                const count = kid.get("Count");
                if (targetIndex < currentCount + count) {
                    return this.traversePages(kid, targetIndex - currentCount);
                }
                currentCount += count;
            }
        }
        throw new Error(`Page ${targetIndex} not found`);
    }
}

