import { Dict } from './primitives';

export abstract class BaseStream {
    pos: number = 0;

    abstract get length(): number;
    abstract get isEmpty(): boolean;

    abstract getByte(): number;
    abstract getBytes(length: number | null): Uint8Array;
    
    peekByte(): number {
        const val = this.getByte();
        if (val !== -1) {
            this.pos--;
        }
        return val;
    }

    peekBytes(length: number): Uint8Array {
        const bytes = this.getBytes(length);
        this.pos -= bytes.length;
        return bytes;
    }

    skip(n: number = 1) {
        this.pos += n;
    }

    abstract reset(): void;
    abstract moveStart(): void;
    abstract makeSubStream(start: number, length: number, dict?: Dict | null): BaseStream;
}

export class Stream extends BaseStream {
    private bytes: Uint8Array;
    public start: number;
    public end: number;
    public dict: Dict | null;

    constructor(buffer: ArrayBuffer | Uint8Array, start: number = 0, length: number = 0, dict: Dict | null = null) {
        super();
        this.bytes = buffer instanceof Uint8Array ? buffer : new Uint8Array(buffer);
        this.start = start;
        this.pos = start;
        this.end = length ? start + length : this.bytes.length;
        this.dict = dict;
    }

    get length(): number {
        return this.end - this.start;
    }

    get isEmpty(): boolean {
        return this.length === 0;
    }

    getByte(): number {
        if (this.pos >= this.end) {
            return -1;
        }
        return this.bytes[this.pos++];
    }

    getBytes(length: number | null = null): Uint8Array {
        const pos = this.pos;
        const strEnd = this.end;

        if (!length) {
            return this.bytes.slice(pos, strEnd);
        }
        
        let end = pos + length;
        if (end > strEnd) {
            end = strEnd;
        }
        this.pos = end;
        return this.bytes.slice(pos, end);
    }

    reset() {
        this.pos = this.start;
    }

    moveStart() {
        this.start = this.pos;
    }

    makeSubStream(start: number, length: number, dict: Dict | null = null): Stream {
        return new Stream(this.bytes.buffer as ArrayBuffer, start, length, dict);
    }
}

