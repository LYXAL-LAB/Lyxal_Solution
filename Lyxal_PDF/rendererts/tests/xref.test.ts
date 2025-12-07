import { test, expect, describe } from "bun:test";
import { Stream } from '../src/core/stream';
import { XRef } from '../src/core/xref';

describe("XRef", () => {
    test("should parse XRef table correctly", () => {
        const header = "%PDF-1.7\n";
        const o1 = "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n";
        const o2 = "2 0 obj\n<< /Type /Pages /Count 0 /Kids [] >>\nendobj\n";
        
        const offset1 = header.length;
        const offset2 = header.length + o1.length;
        const offsetXref = header.length + o1.length + o2.length;
        
        const xrefTable = `xref
0 3
0000000000 65535 f 
${offset1.toString().padStart(10, '0')} 00000 n 
${offset2.toString().padStart(10, '0')} 00000 n 
trailer
<< /Size 3 /Root 1 0 R >>
startxref
${offsetXref}
%%EOF`;

        const fullPdf = header + o1 + o2 + xrefTable;
        
        const bufferNew = new TextEncoder().encode(fullPdf);
        const stream = new Stream(bufferNew);
        const x = new XRef(stream);
        
        x.parse();
        
        expect(x.trailer).toBeDefined();
        expect(x.trailer.get("Size")).toBe(3);
        
        expect(x.root).toBeDefined();
        const type = x.root.get("Type");
        // Check if name string matches "Catalog"
        expect(type.name).toBe("Catalog");
        
        const pages = x.root.get("Pages");
        expect(pages).toBeDefined();
        expect(pages.get("Type").name).toBe("Pages");
    });
});

