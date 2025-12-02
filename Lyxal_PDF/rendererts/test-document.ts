import { Stream } from './src/core/stream';
import { PDFDocument } from './src/core/document';

function testDocument() {
    console.log("--- Testing Document ---");

    const header = "%PDF-1.7\n";
    const o1 = "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n";
    const o2 = "2 0 obj\n<< /Type /Pages /Count 1 /Kids [ 3 0 R ] >>\nendobj\n";
    const o3 = "3 0 obj\n<< /Type /Page /Parent 2 0 R /Resources << /Font << >> >> /MediaBox [0 0 600 800] >>\nendobj\n";
    
    const offset1 = header.length;
    const offset2 = header.length + o1.length;
    const offset3 = header.length + o1.length + o2.length;
    const offsetXref = offset3 + o3.length;
    
    const xrefTable = `xref
0 4
0000000000 65535 f 
${offset1.toString().padStart(10, '0')} 00000 n 
${offset2.toString().padStart(10, '0')} 00000 n 
${offset3.toString().padStart(10, '0')} 00000 n 
trailer
<< /Size 4 /Root 1 0 R >>
startxref
${offsetXref}
%%EOF`;

    const fullPdf = header + o1 + o2 + o3 + xrefTable;
    
    const stream = new Stream(new TextEncoder().encode(fullPdf));
    const doc = new PDFDocument(stream);
    
    try {
        doc.parse();
        console.log("Document parsed.");
        console.log("Num Pages:", doc.numPages);
        
        doc.getPage(0).then(page => {
            console.log("Page 0 found.");
            console.log("MediaBox:", page.pageDict.get("MediaBox"));
            console.log("Resources:", page.resources);
        }).catch(e => console.error("GetPage Error:", e));

    } catch (e) {
        console.error("Document Parse Error:", e);
    }
}

testDocument();

