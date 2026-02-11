import { test, expect, describe } from "bun:test";
import { Stream } from '../src/core/stream';
import { PDFDocument } from '../src/core/document';
import { LinkAnnotation } from '../src/core/annotation';

describe("Annotations", () => {
    test("should parse link annotations", async () => {
        const header = "%PDF-1.7\n";
        const o1 = "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n";
        const o2 = "2 0 obj\n<< /Type /Pages /Count 1 /Kids [ 3 0 R ] >>\nendobj\n";
        const o3 = "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 600 800] /Annots [ 4 0 R ] >>\nendobj\n";
        const o4 = "4 0 obj\n<< /Type /Annot /Subtype /Link /Rect [100 100 200 200] /A << /S /URI /URI (http://example.com) >> >>\nendobj\n";
        
        const offset1 = header.length;
        const offset2 = offset1 + o1.length;
        const offset3 = offset2 + o2.length;
        const offset4 = offset3 + o3.length;
        const offsetXref = offset4 + o4.length;
        
        const xrefTable = `xref
0 5
0000000000 65535 f 
${offset1.toString().padStart(10, '0')} 00000 n 
${offset2.toString().padStart(10, '0')} 00000 n 
${offset3.toString().padStart(10, '0')} 00000 n 
${offset4.toString().padStart(10, '0')} 00000 n 
trailer
<< /Size 5 /Root 1 0 R >>
startxref
${offsetXref}
%%EOF`;

        const fullPdf = header + o1 + o2 + o3 + o4 + xrefTable;
        
        const stream = new Stream(new TextEncoder().encode(fullPdf));
        const doc = new PDFDocument(stream);
        
        doc.parse();
        const page = await doc.getPage(0);
        const annots = await page.getAnnotations();
        
        expect(annots.length).toBe(1);
        const a = annots[0];
        
        expect(a.rect).toEqual([100, 100, 200, 200]);
        expect(a).toBeInstanceOf(LinkAnnotation);
        if (a instanceof LinkAnnotation) {
            expect(a.url).toBe("http://example.com");
        }
    });
});

