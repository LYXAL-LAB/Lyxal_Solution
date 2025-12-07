import { test, expect, describe } from "bun:test";
import { Stream } from '../src/core/stream';
import { PDFDocument } from '../src/core/document';
import { Evaluator } from '../src/core/evaluator';
import { OPS } from '../src/core/ops';

describe("Evaluator", () => {
    test("should evaluate content stream and generate operator list", async () => {
        const header = "%PDF-1.7\n";
        const o1 = "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n";
        const o2 = "2 0 obj\n<< /Type /Pages /Count 1 /Kids [ 3 0 R ] >>\nendobj\n";
        const o3 = "3 0 obj\n<< /Type /Page /Parent 2 0 R /Resources 4 0 R /MediaBox [0 0 600 800] /Contents 6 0 R >>\nendobj\n";
        const o4 = "4 0 obj\n<< /Font << /F1 5 0 R >> /XObject << /Im1 7 0 R >> >>\nendobj\n";
        const o5 = "5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>\nendobj\n";
        
        const contentData = "BT /F1 24 Tf (Hello World) Tj ET q 100 0 0 100 50 50 cm /Im1 Do Q";
        const o6 = `6 0 obj\n<< /Length ${contentData.length} >>\nstream\n${contentData}\nendstream\nendobj\n`;
        
        const imgData = "DATA"; 
        const o7 = `7 0 obj\n<< /Type /XObject /Subtype /Image /Width 2 /Height 2 /ColorSpace /DeviceGray /BitsPerComponent 8 /Length ${imgData.length} >>\nstream\n${imgData}\nendstream\nendobj\n`;

        const offset1 = header.length;
        const offset2 = offset1 + o1.length;
        const offset3 = offset2 + o2.length;
        const offset4 = offset3 + o3.length;
        const offset5 = offset4 + o4.length;
        const offset6 = offset5 + o5.length;
        const offset7 = offset6 + o6.length;
        const offsetXref = offset7 + o7.length;
        
        const xrefTable = `xref
0 8
0000000000 65535 f 
${offset1.toString().padStart(10, '0')} 00000 n 
${offset2.toString().padStart(10, '0')} 00000 n 
${offset3.toString().padStart(10, '0')} 00000 n 
${offset4.toString().padStart(10, '0')} 00000 n 
${offset5.toString().padStart(10, '0')} 00000 n 
${offset6.toString().padStart(10, '0')} 00000 n 
${offset7.toString().padStart(10, '0')} 00000 n 
trailer
<< /Size 8 /Root 1 0 R >>
startxref
${offsetXref}
%%EOF`;

        const fullPdf = header + o1 + o2 + o3 + o4 + o5 + o6 + o7 + xrefTable;
        
        const stream = new Stream(new TextEncoder().encode(fullPdf));
        const doc = new PDFDocument(stream);
        
        doc.parse();
        const page = await doc.getPage(0);
        
        const contentStream = page.pageDict.get("Contents");
        expect(contentStream).toBeDefined();

        const evaluator = new Evaluator(page.resources);
        const opList = await evaluator.getOperatorList(contentStream);
        
        expect(opList.length).toBeGreaterThan(0);
        
        // Check for some expected operators
        expect(opList.fnArray).toContain(OPS.beginText);
        expect(opList.fnArray).toContain(OPS.setFont);
        expect(opList.fnArray).toContain(OPS.showText);
        expect(opList.fnArray).toContain(OPS.endText);
        expect(opList.fnArray).toContain(OPS.paintImageXObject);
    });
});
