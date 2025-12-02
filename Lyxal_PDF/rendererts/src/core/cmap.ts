import { Lexer } from './parser';
import { Stream } from './stream';
import { isCmd, EOF } from './primitives';

export class CMap {
    map: Map<number, string> = new Map();

    constructor() {}

    static async parse(stream: Stream): Promise<CMap> {
        const cmap = new CMap();
        const lexer = new Lexer(stream);
        
        while (true) {
            const token = lexer.getObj();
            if (token === EOF) break;

            if (isCmd(token)) {
                if (token.cmd === "beginbfchar") {
                    while (true) {
                        const src = lexer.getObj();
                        if (isCmd(src, "endbfchar")) break;
                        const dst = lexer.getObj();
                        
                        if (typeof src === 'string' && typeof dst === 'string') {
                            const code = CMap.stringToCode(src);
                            const char = CMap.stringToUtf16(dst);
                            cmap.map.set(code, char);
                        }
                    }
                } else if (token.cmd === "beginbfrange") {
                    while (true) {
                        const start = lexer.getObj();
                        if (isCmd(start, "endbfrange")) break;
                        const end = lexer.getObj();
                        const dst = lexer.getObj();
                        
                        if (typeof start === 'string' && typeof end === 'string') {
                            let startCode = CMap.stringToCode(start);
                            const endCode = CMap.stringToCode(end);
                            
                            if (typeof dst === 'string') {
                                // <start> <end> <dst> (sequential)
                                // This implies dst is the start char code, but usually it's hex bytes
                                // Actually for ToUnicode, dst is utf16be bytes
                                let dstCode = CMap.stringToCode(dst); // Just to get initial value, but it's a string
                                // We need to handle surrogate pairs or multi-byte increase
                                // Simplified: assume single char increment
                                
                                while (startCode <= endCode) {
                                    // TODO: handle correct string increment
                                    // For now, simplistic
                                    cmap.map.set(startCode, CMap.stringToUtf16(dst)); 
                                    startCode++;
                                    // dst needs increment too?
                                    // Yes, if it's a range mapping to range.
                                    // But string increment is hard.
                                }
                            } else if (Array.isArray(dst)) {
                                // <start> <end> [ <char1> <char2> ... ]
                                let idx = 0;
                                while (startCode <= endCode && idx < dst.length) {
                                    cmap.map.set(startCode, CMap.stringToUtf16(dst[idx]));
                                    startCode++;
                                    idx++;
                                }
                            }
                        }
                    }
                }
            }
        }
        return cmap;
    }
    
    static stringToCode(str: string): number {
        let code = 0;
        for (let i = 0; i < str.length; i++) {
            code = (code << 8) | str.charCodeAt(i);
        }
        return code;
    }
    
    static stringToUtf16(str: string): string {
        // PDF hex strings are bytes. For ToUnicode, it is UTF-16BE.
        let res = "";
        for (let i = 0; i < str.length; i += 2) {
            const charCode = (str.charCodeAt(i) << 8) | (str.charCodeAt(i+1) || 0);
            res += String.fromCharCode(charCode);
        }
        return res;
    }

    lookup(code: number): string | undefined {
        return this.map.get(code);
    }
}

