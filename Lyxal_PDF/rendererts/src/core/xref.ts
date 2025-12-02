import { Dict, Ref, XRef as IXRef, isCmd } from './primitives';
import { BaseStream, Stream } from './stream';
import { Parser, Lexer } from './parser';

interface XRefEntry {
    offset: number;
    gen: number;
    free: boolean;
    uncompressed: boolean;
}

export class XRef implements IXRef {
    stream: Stream;
    entries: XRefEntry[] = [];
    private cache = new Map<number, any>();
    trailer: Dict | null = null;
    root: Dict | null = null;
    startXRefQueue: number[] = [];
    topDict: Dict | null = null;

    constructor(stream: Stream) {
        this.stream = stream;
    }

    parse() {
        try {
            const startXRef = this.findStartXRef();
            this.startXRefQueue.push(startXRef);
            this.readXRef();
            
            this.trailer = this.topDict;
            if (!this.trailer) throw new Error("No trailer found");
            
            const root = this.trailer.get("Root");
            if (root instanceof Dict) {
                this.root = root;
            } else {
                // If Root is a Ref, fetch it (Dict.get handles fetch if xref is set?)
                // Dict.get calls this.fetch which returns the object.
                // But this.trailer needs to have this.xref assigned to it for get() to fetch!
                this.trailer.assignXref(this);
                const fetchedRoot = this.trailer.get("Root");
                if (fetchedRoot instanceof Dict) {
                    this.root = fetchedRoot;
                } else {
                    throw new Error("Invalid Root object");
                }
            }
        } catch (e) {
            console.error("XRef Parse Error:", e);
            throw e;
        }
    }

    findStartXRef(): number {
        const stream = this.stream;
        const scanLength = 1024;
        const startPos = Math.max(0, stream.length - scanLength);
        stream.pos = startPos;
        
        const bytes = stream.getBytes(Math.min(scanLength, stream.length));
        const text = new TextDecoder().decode(bytes);
        
        const index = text.lastIndexOf("startxref");
        if (index === -1) throw new Error("startxref not found in last 1024 bytes");
        
        // Use Lexer to read the number after startxref
        stream.pos = startPos + index + "startxref".length;
        const lexer = new Lexer(stream);
        return lexer.getNumber();
    }

    readXRef() {
        const stream = this.stream;
        
        while (this.startXRefQueue.length > 0) {
            const startXRef = this.startXRefQueue.shift()!;
            stream.pos = startXRef;
            
            const parser = new Parser(new Lexer(stream), this, true);
            let obj = parser.getObj();
            let dict: Dict | null = null;

            // 1. Classic XRef Table
            if (isCmd(obj, "xref")) {
                dict = this.processXRefTable(parser);
            } 
            // 2. XRef Stream (PDF 1.5+)
            else if (Number.isInteger(obj)) {
                 // Expect: num gen obj ... stream
                 const num = obj;
                 const gen = parser.getObj();
                 const cmd = parser.getObj();
                 
                 if (!isCmd(cmd, "obj")) throw new Error("Invalid XRef stream header");
                 
                 const xrefStream = parser.getObj(); 
                 if (!(xrefStream instanceof Stream)) throw new Error("XRef is not a stream");
                 
                 dict = this.processXRefStream(xrefStream);
            } else {
                throw new Error("Invalid XRef start");
            }

            if (dict) {
                if (!this.topDict) this.topDict = dict;
                
                // Chain Prev
                const prev = dict.get("Prev");
                if (Number.isInteger(prev)) {
                    this.startXRefQueue.push(prev);
                }
            }
        }
    }

    processXRefTable(parser: Parser): Dict {
        while (true) {
            const obj = parser.getObj();
            if (isCmd(obj, "trailer")) {
                break;
            }
            
            if (!Number.isInteger(obj)) throw new Error(`Invalid XRef table: expected subsection start, got ${obj}`);
            const first = obj;
            const count = parser.getObj();
            
            for (let i = 0; i < count; i++) {
                const offset = parser.getObj();
                const gen = parser.getObj();
                const type = parser.getObj(); // 'n' or 'f'
                
                if (!isCmd(type)) throw new Error("Invalid XRef entry type");
                
                const entry: XRefEntry = {
                    offset: offset,
                    gen: gen,
                    free: type.cmd === 'f',
                    uncompressed: true
                };
                
                this.entries[first + i] = entry;
            }
        }
        
        const dict = parser.getObj();
        if (!(dict instanceof Dict)) throw new Error("Invalid trailer dictionary");
        return dict;
    }

    processXRefStream(stream: Stream): Dict {
        stream.dict!.assignXref(this);
        const w = stream.dict!.get("W");
        const size = stream.dict!.get("Size");
        const index = stream.dict!.get("Index") || [0, size];
        
        if (!Array.isArray(w) || w.length !== 3) throw new Error("Invalid W array in XRef stream");
        
        // Read bytes (decompressed via FlateStream if applicable)
        const bytes = stream.getBytes(null);
        const streamReader = new Stream(bytes);
        
        for (let i = 0; i < index.length; i += 2) {
            const start = index[i];
            const count = index[i+1];
            
            for (let j = 0; j < count; j++) {
                let type = 0, offset = 0, gen = 0;
                
                // Read Type
                for (let k = 0; k < w[0]; k++) type = (type << 8) | streamReader.getByte();
                if (w[0] === 0) type = 1;
                
                // Read Offset
                for (let k = 0; k < w[1]; k++) offset = (offset << 8) | streamReader.getByte();
                
                // Read Gen/Index
                for (let k = 0; k < w[2]; k++) gen = (gen << 8) | streamReader.getByte();
                
                const entry: XRefEntry = { offset: 0, gen: 0, free: false, uncompressed: true };
                
                switch (type) {
                    case 0: // Free
                        entry.free = true;
                        entry.gen = gen;
                        entry.offset = offset;
                        break;
                    case 1: // Uncompressed
                        entry.uncompressed = true;
                        entry.offset = offset;
                        entry.gen = gen;
                        break;
                    case 2: // Compressed
                        entry.uncompressed = false;
                        entry.offset = offset; // ObjStm Ref Num
                        entry.gen = gen; // Index
                        break;
                    default:
                        // throw new Error(`Invalid XRef type: ${type}`);
                        break;
                }
                
                if (!this.entries[start + j]) {
                    this.entries[start + j] = entry;
                }
            }
        }

        return stream.dict!;
    }

    fetchIfRef(obj: any): any {
        if (obj instanceof Ref) {
            return this.fetch(obj);
        }
        return obj;
    }

    fetch(ref: Ref, suppressEncryption: boolean = false): any {
        if (this.cache.has(ref.num)) {
            return this.cache.get(ref.num);
        }

        const entry = this.entries[ref.num];
        if (!entry) {
            return null;
        }
        if (entry.free) {
            return null;
        }

        if (entry.uncompressed) {
            const subStream = this.stream.makeSubStream(this.stream.start + entry.offset, 0);
            const parser = new Parser(new Lexer(subStream), this);
            
            const num = parser.getObj();
            const gen = parser.getObj();
            const cmd = parser.getObj();

            if (num !== ref.num || gen !== ref.gen || !isCmd(cmd, 'obj')) {
                throw new Error(`Bad XRef entry for ${ref}: found ${num} ${gen} ${cmd}`);
            }

            const obj = parser.getObj();
            
            if (obj instanceof Dict) {
                obj.objId = ref.toString();
                obj.assignXref(this);
            } else if (obj instanceof Stream) {
                if (obj.dict) {
                    obj.dict.objId = ref.toString();
                    obj.dict.assignXref(this);
                }
            }

            this.cache.set(ref.num, obj);
            return obj;
        }

        throw new Error(`Compressed object streams (Type 2) not implemented yet for ${ref}`);
    }

    async fetchAsync(ref: Ref, suppressEncryption?: boolean): Promise<any> {
        return this.fetch(ref, suppressEncryption);
    }
}
