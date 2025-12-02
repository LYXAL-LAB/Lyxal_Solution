import { Stream } from './src/core/stream';
import { XRef } from './src/core/xref';

function testXRef() {
    console.log("--- Testing XRef ---");

    const pdfData = `
%PDF-1.7
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Count 0 /Kids [] >>
endobj
xref
0 3
0000000000 65535 f 
0000000010 00000 n 
0000000060 00000 n 
trailer
<< /Size 3 /Root 1 0 R >>
startxref
115
%%EOF
`.trim();

    // Adjust offsets manually because trim() and newlines might shift things
    // Easier: generate precise buffer or trust rough parser
    
    // Let's manually correct offsets for this string
    // "1 0 obj" starts at index 10 (after %PDF-1.7\n)
    // "2 0 obj" starts at index 60?
    
    // I will use a helper to find offsets dynamically for the test to be robust
    const buffer = new TextEncoder().encode(pdfData);
    
    // Fix offsets in the buffer
    const str = new TextDecoder().decode(buffer);
    const obj1 = str.indexOf("1 0 obj");
    const obj2 = str.indexOf("2 0 obj");
    const xref = str.indexOf("xref");
    const startxref = str.indexOf("startxref");
    
    console.log(`Offsets: obj1=${obj1}, obj2=${obj2}, xref=${xref}, startxref=${startxref}`);
    
    // Patch the buffer with correct offsets
    // We assume 10-digit zero padded in table, but here I used compact for readability.
    // My table in string uses "0000000010".
    // I need to find these strings and replace them with formatted offsets.
    
    // Simplification: I will manually update the offsets in the string based on what I see in the log
    // obj1=9, obj2=58, xref=110.
    
    // Re-create buffer with correct values if needed, or better:
    // Let's rely on the parser being robust enough for small shifts? No, xref must be exact byte offset.
    
    // I'll reconstruct the string perfectly.
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
    console.log("Generated PDF:\n", fullPdf);
    
    // We recreate stream with new buffer
    const bufferNew = new TextEncoder().encode(fullPdf);
    const stream = new Stream(bufferNew);
    const x = new XRef(stream);
    
    try {
        x.parse();
        console.log("XRef parsed successfully.");
        console.log("Trailer:", x.trailer);
        
        if (x.root) {
            console.log("Root found.");
            console.log("Root Type:", x.root.get("Type"));
            
            const pages = x.root.get("Pages");
            console.log("Pages fetched via Ref:", pages);
            console.log("Pages Type:", pages.get("Type"));
        } else {
            console.error("Root NOT found");
        }

    } catch (e) {
        console.error("XRef Test Failed:", e);
    }
}

testXRef();

