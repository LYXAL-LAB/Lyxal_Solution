import { Stream } from './src/core/stream';
import { PDFDocument } from './src/core/document';
import { Evaluator } from './src/core/evaluator';
import { OPS } from './src/core/ops';

function testPattern() {
    console.log("--- Testing Pattern ---");

    const header = "%PDF-1.7\n";
    const o1 = "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n";
    const o2 = "2 0 obj\n<< /Type /Pages /Count 1 /Kids [ 3 0 R ] >>\nendobj\n";
    const o3 = "3 0 obj\n<< /Type /Page /Parent 2 0 R /Resources 4 0 R /MediaBox [0 0 600 800] /Contents 6 0 R >>\nendobj\n";
    const o4 = "4 0 obj\n<< /Pattern << /P1 5 0 R >> >>\nendobj\n";
    const o5 = "5 0 obj\n<< /Type /Pattern /PatternType 1 /PaintType 1 /TilingType 1 /BBox [0 0 10 10] /XStep 10 /YStep 10 /Resources << >> >>\nstream\n0 0 m 10 10 l S\nendstream\nendobj\n";
    
    const contentData = "/Pattern cs /P1 scn 0 0 100 100 re f";
    const o6 = `6 0 obj\n<< /Length ${contentData.length} >>\nstream\n${contentData}\nendstream\nendobj\n`;
    
    const offset1 = header.length;
    const offset2 = offset1 + o1.length;
    const offset3 = offset2 + o2.length;
    const offset4 = offset3 + o3.length;
    const offset5 = offset4 + o4.length;
    const offset6 = offset5 + o5.length;
    const offsetXref = offset6 + o6.length;
    
    const xrefTable = `xref
0 7
0000000000 65535 f 
${offset1.toString().padStart(10, '0')} 00000 n 
${offset2.toString().padStart(10, '0')} 00000 n 
${offset3.toString().padStart(10, '0')} 00000 n 
${offset4.toString().padStart(10, '0')} 00000 n 
${offset5.toString().padStart(10, '0')} 00000 n 
${offset6.toString().padStart(10, '0')} 00000 n 
trailer
<< /Size 7 /Root 1 0 R >>
startxref
${offsetXref}
%%EOF`;

    const fullPdf = header + o1 + o2 + o3 + o4 + o5 + o6 + xrefTable;
    
    const stream = new Stream(new TextEncoder().encode(fullPdf));
    const doc = new PDFDocument(stream);
    
    try {
        doc.parse();
        doc.getPage(0).then(async page => {
            const contentStream = page.pageDict.get("Contents");
            const evaluator = new Evaluator(page.resources);
            const opList = await evaluator.getOperatorList(contentStream);
            
            console.log(`Generated ${opList.totalLength} operators:`);
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
        });
    } catch (e) {
        console.error(e);
    }
}

testPattern();

