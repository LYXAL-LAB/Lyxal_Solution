import { test, expect, describe } from "bun:test";
import { MockWorker } from '../src/core/mock_worker';
import { OPS } from '../src/core/ops';

// Helper to create a minimal valid PDF dynamically
export function createMinimalPDF(): Uint8Array {
    let offset = 0;
    const offsets: number[] = [0]; // Dummy for index 0

    let content = "%PDF-1.7\n";
    offset = content.length;

    // Helper to add object
    function addObject(num: number, data: string) {
        const header = `${num} 0 obj\n`;
        const footer = `\nendobj\n`;
        offsets[num] = offset;
        const fullObj = header + data + footer;
        content += fullObj;
        offset += fullObj.length;
    }

    // Obj 1: Catalog
    addObject(1, "<< /Type /Catalog /Pages 2 0 R >>");

    // Obj 2: Pages
    addObject(2, "<< /Type /Pages /Kids [3 0 R] /Count 1 >>");

    // Obj 3: Page
    // Added Fonts resource for text test with Widths for ASCII
    // Helvetica widths are roughly proportional. Let's assume 500 for simplicity in test.
    // Need FirstChar, LastChar, Widths array.
    // 'H' is 72, 'e' is 101, ...
    // Let's define widths for 32-126 (ASCII) as 500.
    const widths = Array(95).fill(500).join(" ");
    addObject(3, `<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica /FirstChar 32 /LastChar 126 /Widths [${widths}] >> >> >> >>`);

    // Obj 4: Content Stream
    // BT /F1 24 Tf 100 100 Td (Hello World) Tj ET
    const streamData = "BT /F1 24 Tf 100 100 Td (Hello World) Tj ET";
    const streamLen = streamData.length;
    addObject(4, `<< /Length ${streamLen} >>\nstream\n${streamData}\nendstream`);

    const xrefOffset = offset;
    content += "xref\n";
    content += `0 5\n`;
    content += "0000000000 65535 f \n";
    
    for (let i = 1; i <= 4; i++) {
        const off = offsets[i].toString().padStart(10, "0");
        content += `${off} 00000 n \n`;
    }
    
    content += "trailer\n";
    content += `<< /Size 5 /Root 1 0 R >>\n`;
    content += "startxref\n";
    content += `${xrefOffset}\n`;
    content += "%%EOF";

    const buffer = new Uint8Array(content.length);
    for (let i = 0; i < content.length; i++) {
        buffer[i] = content.charCodeAt(i);
    }
    return buffer;
}

describe("Architecture Integration", () => {
    test("Full flow: Client -> Worker -> PDFManager -> Document", async () => {
        const worker = new MockWorker();
        const pdfData = createMinimalPDF();
        
        // 1. Load Document
        const loadResult = await worker.loadDocument("doc1", pdfData);
        expect(loadResult).toBeDefined();
        expect(loadResult.numPages).toBe(1);

        // 2. Get Page
        const pageInfo = await worker.getPage("doc1", 0);
        expect(pageInfo).toBeDefined();
        expect(pageInfo.pageIndex).toBe(0);
        // Updated to standard letter size
        expect(pageInfo.view).toEqual([0, 0, 612, 792]);

        // 3. Get Operator List (Rendering)
        const opList = await worker.getOperatorList("doc1", 0);
        expect(opList).toBeDefined();
        expect(opList.fnArray.length).toBeGreaterThan(0);
        
        // Verify we have text ops now
        expect(opList.fnArray).toContain(OPS.beginText);
        expect(opList.fnArray).toContain(OPS.showText);
    });
});
