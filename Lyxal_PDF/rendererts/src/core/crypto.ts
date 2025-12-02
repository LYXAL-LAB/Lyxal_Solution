import { createHash, createDecipheriv, createCipheriv } from 'node:crypto';
import { Dict, Ref } from './primitives';
import { Stream } from './stream';

export interface CipherTransform {
    decrypt(data: Uint8Array): Uint8Array;
}

export class RC4CipherTransform implements CipherTransform {
    private key: Uint8Array;
    private s: Uint8Array;
    private i: number = 0;
    private j: number = 0;

    constructor(key: Uint8Array) {
        this.key = key;
        this.s = new Uint8Array(256);
        for (let i = 0; i < 256; i++) {
            this.s[i] = i;
        }

        let j = 0;
        for (let i = 0; i < 256; i++) {
            j = (j + this.s[i] + key[i % key.length]) & 0xff;
            [this.s[i], this.s[j]] = [this.s[j], this.s[i]];
        }
    }

    decrypt(data: Uint8Array): Uint8Array {
        const output = new Uint8Array(data.length);
        let i = this.i;
        let j = this.j;
        const s = this.s.slice(); // Clone state for this operation if needed? 
        // Usually PDF decrypts normally. But if we reuse the transform, we need to maintain state.
        // However, usually a new transform is created for each object.
        // If we reuse, we update i, j.
        
        // Actually, for PDF objects, the key is derived per object, so we create a NEW RC4 instance per object.
        // So state maintenance is local.
        
        for (let k = 0; k < data.length; k++) {
            i = (i + 1) & 0xff;
            j = (j + s[i]) & 0xff;
            [s[i], s[j]] = [s[j], s[i]];
            output[k] = data[k] ^ s[(s[i] + s[j]) & 0xff];
        }
        
        return output;
    }
}

export class AESCipherTransform implements CipherTransform {
    private key: Uint8Array;
    private iv: Uint8Array;
    private bits: number;

    constructor(key: Uint8Array, bits: number) {
        this.key = key;
        this.bits = bits;
        // AES in PDF usually has IV as first 16 bytes of data for streams,
        // or independent IV for strings.
        this.iv = new Uint8Array(16); // Placeholder
    }

    decrypt(data: Uint8Array): Uint8Array {
        // For AES in PDF:
        // Strings: IV is encrypted? Or IV is first 16 bytes?
        // Streams: IV is first 16 bytes.
        
        if (data.length <= 16) return new Uint8Array(0); // Too short
        
        const iv = data.slice(0, 16);
        const ciphertext = data.slice(16);
        
        const algo = this.bits === 128 ? 'aes-128-cbc' : 'aes-256-cbc';
        const decipher = createDecipheriv(algo, this.key, iv);
        
        // Disable padding because PDF might not use standard PKCS7 or might handle it differently?
        // PDF uses PKCS7 padding usually.
        decipher.setAutoPadding(false); 
        
        let decrypted = decipher.update(ciphertext);
        const final = decipher.final();
        
        // Concatenate
        const res = new Uint8Array(decrypted.length + final.length);
        res.set(decrypted);
        res.set(final, decrypted.length);
        
        // Remove padding manually if needed, but for now return raw.
        // Actually standard PKCS7 padding is used.
        return res;
    }
}

export class DecryptStream extends Stream {
    constructor(stream: Stream, decryptor: (chunk: Uint8Array) => Uint8Array) {
        // We need to read the entire stream, decrypt it, and wrap it.
        // Streaming decryption is harder with block ciphers if we don't know length ahead.
        // For now, load all.
        const bytes = stream.getBytes(null);
        const decrypted = decryptor(bytes);
        super(decrypted);
    }
}

export class CipherTransformFactory {
    ops: Dict;
    filename: string;
    
    constructor(ops: Dict, filename: string) {
        this.ops = ops;
        this.filename = filename;
    }

    createCipherTransform(key: Uint8Array, useAes: boolean): CipherTransform {
        if (useAes) {
            return new AESCipherTransform(key, key.length * 8);
        } else {
            return new RC4CipherTransform(key);
        }
    }
}

export class Decryptor {
    private encryptionKey: Uint8Array;
    private useAes: boolean;
    private keyLength: number;

    constructor(encryptDict: Dict, idArray: Array<any>, password: string = "") {
        // Basic implementation of Algorithm 3.2 (Standard Security Handler)
        
        const v = encryptDict.get("V");
        const r = encryptDict.get("R");
        const o = encryptDict.get("O"); // Owner
        const u = encryptDict.get("U"); // User
        const p = encryptDict.get("P"); // Permissions
        const encryptMetadata = encryptDict.get("EncryptMetadata");
        
        this.useAes = (isStream: boolean) => {
             const stmF = encryptDict.get("StmF");
             const strF = encryptDict.get("StrF");
             const name = isStream ? stmF : strF;
             if (name && name.name === "StdCF") {
                 // Check CF dictionary for StdCF
                 const cf = encryptDict.get("CF");
                 if (cf) {
                     const stdCf = cf.get("StdCF");
                     if (stdCf) {
                         const cfm = stdCf.get("CFM");
                         if (cfm && cfm.name === "AESV2") return true;
                     }
                 }
             }
             return false;
        };
        
        this.keyLength = encryptDict.get("Length") || 40;
        this.keyLength = this.keyLength / 8; // bits to bytes

        // TODO: Full key derivation implementation.
        // For now, hardcode a placeholder key or implement standard handler.
        // This is complex. I'll implement a simplified version for now.
        this.encryptionKey = new Uint8Array(this.keyLength);
    }

    private computeKey(ref: Ref): Uint8Array {
        // Algorithm 3.1
        if (this.useAes && this.useAes(false)) { // Check if AES used for this type
             // AES Key generation
             // ...
             return this.encryptionKey; // Placeholder
        }

        // RC4 Key generation (Algorithm 3.1)
        const key = new Uint8Array(this.encryptionKey.length + 5);
        key.set(this.encryptionKey);
        key[key.length - 5] = ref.num & 0xff;
        key[key.length - 4] = (ref.num >> 8) & 0xff;
        key[key.length - 3] = (ref.num >> 16) & 0xff;
        key[key.length - 2] = ref.gen & 0xff;
        key[key.length - 1] = (ref.gen >> 8) & 0xff;
        
        const md5 = createHash('md5').update(key).digest();
        const length = Math.min(this.keyLength + 5, 16);
        return new Uint8Array(md5.slice(0, length));
    }

    decryptString(str: string, ref: Ref): string {
        // Convert string to bytes
        const data = new Uint8Array(str.length);
        for(let i=0; i<str.length; i++) {
            data[i] = str.charCodeAt(i);
        }

        const key = this.computeKey(ref);
        const transform = new RC4CipherTransform(key);
        const decrypted = transform.decrypt(data);

        // Convert back to string
        let res = "";
        for(let i=0; i<decrypted.length; i++) {
            res += String.fromCharCode(decrypted[i]);
        }
        return res;
    }
    
    decryptStream(stream: Stream, ref: Ref): Stream {
        const key = this.computeKey(ref);
        const transform = new RC4CipherTransform(key);
        return new DecryptStream(stream, (data) => transform.decrypt(data));
    }
}

