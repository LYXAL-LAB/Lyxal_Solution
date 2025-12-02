import { Stream } from './stream';

// CFF Data Types
// Card8: 1 byte unsigned
// Card16: 2 byte unsigned
// OffSize: 1 byte unsigned (1-4)
// SID: 2 byte unsigned

export class CFFIndex {
    count: number;
    offSize: number;
    offsets: number[];
    dataStart: number;
    stream: Stream;
    endPos: number;

    constructor(stream: Stream) {
        this.stream = stream;
        const startPos = stream.pos;

        this.count = (stream.getByte() << 8) | stream.getByte();
        this.offsets = [];
        
        if (this.count === 0) {
            this.offSize = 0;
            this.dataStart = startPos + 2;
            this.endPos = this.dataStart;
            return;
        }

        this.offSize = stream.getByte();
        if (this.offSize < 1 || this.offSize > 4) {
             throw new Error("Invalid CFF Index OffSize");
        }

        // Read offsets
        // count + 1 offsets
        for (let i = 0; i <= this.count; i++) {
            let offset = 0;
            for (let j = 0; j < this.offSize; j++) {
                offset = (offset << 8) | stream.getByte();
            }
            this.offsets.push(offset);
        }

        this.dataStart = stream.pos;
        // The last offset tells us the total size of data
        this.endPos = this.dataStart + this.offsets[this.count];
        
        // Skip data to get ready for next read
        stream.pos = this.endPos; 
    }

    get(index: number): Uint8Array {
        if (index < 0 || index >= this.count) return new Uint8Array(0);
        
        const start = this.offsets[index];
        const end = this.offsets[index + 1];
        const len = end - start;
        
        const savedPos = this.stream.pos;
        this.stream.pos = this.dataStart + start;
        const data = this.stream.getBytes(len);
        this.stream.pos = savedPos;
        return data;
    }
}

export class CFFParser {
    stream: Stream;
    
    // Header
    major: number = 0;
    minor: number = 0;
    hdrSize: number = 0;
    offSize: number = 0;

    // Indices
    nameIndex: CFFIndex | null = null;
    topDictIndex: CFFIndex | null = null;
    stringIndex: CFFIndex | null = null;
    globalSubrIndex: CFFIndex | null = null;
    cffStart: number;

    constructor(stream: Stream) {
        this.stream = stream;
        this.cffStart = stream.pos;
    }

    parse() {
        this.parseHeader();
        this.nameIndex = new CFFIndex(this.stream);
        this.topDictIndex = new CFFIndex(this.stream);
        this.stringIndex = new CFFIndex(this.stream);
        this.globalSubrIndex = new CFFIndex(this.stream);
        
        // After this comes Encodings, Charsets, FDSelect, CharStrings...
        // which are pointed to by Top Dict.
        // We need to parse Top Dict first.
    }

    parseHeader() {
        this.major = this.stream.getByte();
        this.minor = this.stream.getByte();
        this.hdrSize = this.stream.getByte();
        this.offSize = this.stream.getByte();
        
        // Skip remaining header bytes if any
        if (this.hdrSize > 4) {
            this.stream.skip(this.hdrSize - 4);
        }
    }

    // Parse DICT data (sequence of operands and operators)
    parseDict(data: Uint8Array) {
        const dict: any = {};
        const stream = new Stream(data);
        const operands: number[] = [];

        while (stream.pos < stream.length) {
            let b0 = stream.getByte();
            
            if (b0 <= 21) {
                // Operator
                let op = b0;
                if (b0 === 12) {
                    op = (b0 << 8) | stream.getByte();
                }
                
                this.handleOperator(dict, op, operands);
                operands.length = 0; // Clear operands
            } else if (b0 === 28 || b0 === 29) {
                // Number
                 operands.push(this.readNumber(b0, stream));
            } else if (b0 === 30) {
                // Real Number
                 operands.push(this.readRealNumber(stream));
            } else if (b0 >= 32 && b0 <= 246) {
                 operands.push(b0 - 139);
            } else if (b0 >= 247 && b0 <= 250) {
                 const b1 = stream.getByte();
                 operands.push((b0 - 247) * 256 + b1 + 108);
            } else if (b0 >= 251 && b0 <= 254) {
                 const b1 = stream.getByte();
                 operands.push(-(b0 - 251) * 256 - b1 - 108);
            } else {
                 // Reserved
            }
        }
        return dict;
    }

    readNumber(b0: number, stream: Stream): number {
        if (b0 === 28) {
            let val = (stream.getByte() << 8) | stream.getByte();
            if (val >= 32768) {
                val -= 65536;
            }
            return val;
        } else {
            return (stream.getByte() << 24) | (stream.getByte() << 16) | (stream.getByte() << 8) | stream.getByte();
        }
    }

    readRealNumber(stream: Stream): number {
        let str = "";
        let done = false;
        while (!done) {
            const b = stream.getByte();
            const nibbles = [b >> 4, b & 0x0f];
            for (let i = 0; i < 2; i++) {
                const nibble = nibbles[i];
                switch (nibble) {
                    case 0x0: str += "0"; break;
                    case 0x1: str += "1"; break;
                    case 0x2: str += "2"; break;
                    case 0x3: str += "3"; break;
                    case 0x4: str += "4"; break;
                    case 0x5: str += "5"; break;
                    case 0x6: str += "6"; break;
                    case 0x7: str += "7"; break;
                    case 0x8: str += "8"; break;
                    case 0x9: str += "9"; break;
                    case 0xa: str += "."; break;
                    case 0xb: str += "E"; break;
                    case 0xc: str += "E-"; break;
                    case 0xd: break; // reserved
                    case 0xe: str += "-"; break;
                    case 0xf: done = true; break;
                }
                if (done) break;
            }
        }
        return parseFloat(str);
    }

    handleOperator(dict: any, op: number, operands: number[]) {
        // Mapping of ops to dict keys
        // e.g. 1 -> version, 2 -> Notice, ... 17 -> CharStrings
        
        const val = operands.length === 1 ? operands[0] : [...operands];
        
        switch(op) {
            case 17: dict.CharStrings = val; break;
            case 18: dict.Private = val; break; // [size, offset]
            case 19: dict.Subrs = val; break; // Local Subrs offset relative to Private Dict
            default: dict[op] = val; 
        }
    }

    getCharStringsIndex(offset: number): CFFIndex {
        const savedPos = this.stream.pos;
        this.stream.pos = this.cffStart + offset;
        const index = new CFFIndex(this.stream);
        this.stream.pos = savedPos;
        return index;
    }

    getPrivateDict(size: number, offset: number): any {
        const savedPos = this.stream.pos;
        this.stream.pos = this.cffStart + offset;
        const data = this.stream.getBytes(size);
        const dict = this.parseDict(data);
        this.stream.pos = savedPos;
        return dict;
    }

    getLocalSubrsIndex(privateOffset: number, subrsOffset: number): CFFIndex {
        const savedPos = this.stream.pos;
        this.stream.pos = this.cffStart + privateOffset + subrsOffset;
        const index = new CFFIndex(this.stream);
        this.stream.pos = savedPos;
        return index;
    }
}

