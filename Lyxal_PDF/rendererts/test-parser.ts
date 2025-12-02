import { ByteStream } from './src/io/ByteStream';
import { Lexer, Parser } from './src/core/parser';
import { Dict, Name, Ref, Cmd } from './src/core/primitives';
import { Stream } from './src/core/stream';

function testParser() {
    console.log("--- Testing Parser ---");

    const input = `
        << 
            /Type /Catalog 
            /Pages 1 0 R 
            /Array [ 1 2 3 true false null ]
            /Dict << /A 10 >>
        >>
        << /Length 5 >>
stream
Hello
endstream
    `;
    
    console.log("Input:", input);

    const data = new TextEncoder().encode(input);
    const stream = new Stream(data);
    const lexer = new Lexer(stream);
    const parser = new Parser(lexer);

    try {
        // 1. Catalog Dict
        let obj = parser.getObj();
        console.log("Obj 1 (Catalog):", obj);

        // 2. Stream Object
        obj = parser.getObj();
        console.log("Obj 2 (Stream):", obj);
        
        if (obj instanceof Stream) {
            console.log("Stream Length:", obj.length);
            console.log("Stream Content:", new TextDecoder().decode(obj.getBytes()));
        } else {
            console.log("Expected Stream, got:", obj);
        }

    } catch (e) {
        console.error("Parsing Error:", e);
    }
}

testParser();
