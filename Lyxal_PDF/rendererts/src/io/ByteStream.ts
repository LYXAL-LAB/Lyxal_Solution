export class ByteStream {
    private buffer: Uint8Array;
    private pos: number = 0;

    constructor(buffer: ArrayBuffer | Uint8Array) {
        this.buffer = buffer instanceof Uint8Array ? buffer : new Uint8Array(buffer);
    }

    get position() { return this.pos; }
    get length() { return this.buffer.length; }

    seek(pos: number) {
        if (pos < 0) pos = 0;
        if (pos > this.buffer.length) pos = this.buffer.length;
        this.pos = pos;
    }

    readByte(): number {
        if (this.pos >= this.buffer.length) return -1;
        return this.buffer[this.pos++];
    }

    peekByte(): number {
        if (this.pos >= this.buffer.length) return -1;
        return this.buffer[this.pos];
    }

    readBytes(length: number): Uint8Array {
        if (this.pos + length > this.buffer.length) {
            throw new Error(`EOF: Try to read ${length} bytes at ${this.pos} (len: ${this.buffer.length})`);
        }
        const bytes = this.buffer.slice(this.pos, this.pos + length);
        this.pos += length;
        return bytes;
    }
    
    skip(n: number) {
        this.seek(this.pos + n);
    }

    // Helper for debugging
    peekString(length: number): string {
        const bytes = this.buffer.slice(this.pos, Math.min(this.pos + length, this.buffer.length));
        return new TextDecoder().decode(bytes);
    }
}

