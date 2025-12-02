import { Stream } from './src/core/stream';
import { PDFDocument } from './src/core/document';
import { Evaluator } from './src/core/evaluator';
import { OPS } from './src/core/ops';

function testEvaluator() {
    console.log("--- Testing Evaluator ---");

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
    
    try {
        doc.parse();
        
        doc.getPage(0).then(async page => {
            console.log("Page Resource Dict:", page.resources);
            
            // page.pageDict.get("Contents") automatically fetches the Ref if xref is attached to dict
            // So contentStream should be the Stream object directly
            const contentStream = page.pageDict.get("Contents");
            console.log("Content Object:", contentStream ? contentStream.constructor.name : "NULL");
            
            if (!contentStream) {
                console.error("Failed to get content stream!");
                return;
            }

            const evaluator = new Evaluator(page.resources);
            console.log("Evaluating content stream...");
            const opList = await evaluator.getOperatorList(contentStream);
            
            console.log(`\nGenerated ${opList.totalLength} operators:`);
            
            const fnNames: any = {};
            for (const [k, v] of Object.entries(OPS)) {
                fnNames[v as number] = k;
            }
            
            for (let i = 0; i < opList.length; i++) {
                const fn = opList.fnArray[i];
                const args = opList.argsArray[i];
                
                const argsStr = args.map((a: any) => {
                    if (a && a.constructor && a.constructor.name && a.constructor.name !== "Number" && a.constructor.name !== "String") return a.constructor.name;
                    return a;
                }).join(", ");
                
                console.log(`[${i}] ${fnNames[fn]} (${argsStr})`);
            }

        }).catch(e => console.error("Page Error:", e));

    } catch (e) {
        console.error("Doc Error:", e);
    }
}

testEvaluator();
