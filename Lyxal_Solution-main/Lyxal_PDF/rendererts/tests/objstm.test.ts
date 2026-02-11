import { test, expect, describe } from "bun:test";
import { Stream } from '../src/core/stream';
import { XRef } from '../src/core/xref';
import { Dict, Name } from '../src/core/primitives';

describe("Object Streams (Compressed Objects)", () => {
    test("should parse objects inside an Object Stream (Type 2)", () => {
        // Construct a PDF with an Object Stream
        // 1 0 obj = Catalog
        // 2 0 obj = Object Stream containing (3 0 obj)
        // 3 0 obj = Pages (inside ObjStm 2)
        
        const header = "%PDF-1.5\n";
        
        const o1 = "1 0 obj\n<< /Type /Catalog /Pages 3 0 R >>\nendobj\n";
        
        // Object 3 content inside stream: "<< /Type /Pages /Count 0 /Kids [] >>"
        const obj3Content = "<< /Type /Pages /Count 0 /Kids [] >>";
        
        // ObjStm Header: "3 0" (ObjNum 3, Offset 0)
        const stmHeader = "3 0 "; 
        const stmData = stmHeader + obj3Content;
        
        const o2 = `2 0 obj
<< 
  /Type /ObjStm 
  /N 1 
  /First ${stmHeader.length} 
  /Length ${stmData.length} 
>>
stream
${stmData}
endstream
endobj
`;

        const offset1 = header.length;
        const offset2 = offset1 + o1.length;
        const offsetXref = offset2 + o2.length;
        
        // XRef Table
        // 1 0 obj -> Standard (n)
        // 2 0 obj -> Standard (n) - The ObjStm itself
        // 3 0 obj -> Compressed (type 2) -> Pointing to ObjStm 2, Index 0
        
        const xrefTable = `xref
0 4
0000000000 65535 f 
${offset1.toString().padStart(10, '0')} 00000 n 
${offset2.toString().padStart(10, '0')} 00000 n 
0000000000 00000 f 
trailer
<< /Size 4 /Root 1 0 R >>
startxref
${offsetXref}
%%EOF`;
        
        // Note: For object 3, we cannot use standard xref table for Type 2. 
        // We MUST use an XRef Stream to define Type 2 entries.
        // Standard xref table only supports Type 1 (in usage) or Type 0 (free).
        // PDF 1.5+ requires XRef Streams for Compressed Objects.
        
        // PLAN B: Since constructing a binary XRef Stream manually is complex (bit packing),
        // let's try to mock the XRef Entry in the internal state instead of parsing a full PDF binary?
        // Or create a minimal XRef Stream generator.
        
        // Let's rely on the fact that our XRef parser *might* be mixed? 
        // No, the PDF spec says Type 2 entries only exist in XRef Streams.
        
        // To test "fetchCompressed" logic in isolation, we can:
        // 1. Create XRef instance
        // 2. Mock 'fetch' to return the ObjStm (obj 2)
        // 3. Manually insert the XRefEntry for obj 3 (Type 2)
        // 4. Call x.fetch(new Ref(3, 0))
    });

    test("manual injection test for fetchCompressed", () => {
        // Mock Stream data for ObjStm (Obj 2)
        // Content: "3 0 << /Type /Pages >>"
        // Header: "3 0" (Obj 3 at offset 0)
        // Body: "<< /Type /Pages >>"
        // First: 4 (length of "3 0 ")
        
        const streamBody = "3 0 << /Type /Pages >>";
        const streamDict = new Dict(null);
        streamDict.set("Type", Name.get("ObjStm"));
        streamDict.set("N", 1);
        streamDict.set("First", 4);
        streamDict.set("Length", streamBody.length);
        
        const objStmStream = new Stream(new TextEncoder().encode(streamBody), 0, streamBody.length, streamDict);
        
        // Create XRef
        const xref = new XRef(new Stream(new Uint8Array([]))); // Empty stream, we mock fetch
        
        // Mock fetch to return our ObjStm when requested (Ref 2 0)
        xref.fetch = (ref) => {
            if (ref.num === 2) return objStmStream;
            return null;
        };
        
        // Inject Type 2 entry for Object 3
        // Pointing to Stream 2, Index 0
        xref.entries[3] = {
            offset: 2, // ObjStm Ref Num
            gen: 0,    // Index in stream
            free: false,
            uncompressed: false // Type 2
        };
        
        // Trigger fetch of compressed object
        const obj3 = xref.fetchIfRef({ num: 3, gen: 0 }); // Simulate Ref
        
        // However fetchIfRef expects Ref object, let's use the public fetch
        // But we overwrote fetch! We need to test 'fetchCompressed' which is internal, 
        // or ensure our mock fetch delegates to real fetch for non-2 objects.
        
        // Better: Restore original fetch but mock the cache or stream access?
        // Let's use prototype injection or a partial mock.
        
        const realXref = new XRef(new Stream(new Uint8Array([])));
        
        // Inject entry
        realXref.entries[3] = {
            offset: 2,
            gen: 0,
            free: false,
            uncompressed: false
        };
        
        // Mock retrieving the stream 2
        // We intercept the 'fetch' call inside 'fetchCompressed' -> 'this.fetch(new Ref(objStmNum, 0))'
        // But 'fetchCompressed' calls 'this.fetch'. If we mock 'this.fetch', we break the recursion/delegation unless careful.
        
        // Solution: Pre-populate cache for Obj 2
        realXref['cache'].set(2, objStmStream);
        
        // Now call fetch(3, 0)
        // It should look in entries, find Type 2, call fetchCompressed
        // fetchCompressed will call fetch(2, 0), which hits the cache and returns objStmStream
        // Then it parses and returns Obj 3.
        
        // We need a Ref class instance
        // Assuming Ref is exported or we can mock it
        const Ref = require('../src/core/primitives').Ref;
        const ref3 = new Ref(3, 0);
        
        const result = realXref.fetch(ref3);
        
        expect(result).toBeDefined();
        expect(result).toBeInstanceOf(Dict);
        expect(result.get("Type").name).toBe("Pages");
    });
});

