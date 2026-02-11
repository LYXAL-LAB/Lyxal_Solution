import { test, expect, describe } from "bun:test";
import { Lexer, Parser } from '../src/core/parser';
import { Stream } from '../src/core/stream';
import { Dict, Name } from '../src/core/primitives';

describe("Parser Core", () => {
    test("should parse a basic dictionary with stream", () => {
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
    
        const data = new TextEncoder().encode(input);
        const stream = new Stream(data);
        const lexer = new Lexer(stream);
        const parser = new Parser(lexer);

        // 1. Catalog Dict
        const obj1 = parser.getObj();
        expect(obj1).toBeInstanceOf(Dict);
        expect(obj1.get("Type")).toEqual(Name.get("Catalog"));
        
        const array = obj1.get("Array");
        expect(Array.isArray(array)).toBe(true);
        expect(array[0]).toBe(1);
        expect(array[3]).toBe(true);

        // 2. Stream Object
        const obj2 = parser.getObj();
        expect(obj2).toBeInstanceOf(Stream);
        expect(obj2.length).toBe(5);
        expect(new TextDecoder().decode(obj2.getBytes())).toBe("Hello");
    });
});
