import { test, expect, describe } from "bun:test";
import { RC4CipherTransform } from '../src/core/crypto';

describe("Crypto", () => {
    test("RC4 encryption/decryption", () => {
        const key = new Uint8Array([0x01, 0x23, 0x45, 0x67, 0x89]);
        const plaintext = new Uint8Array([0x48, 0x65, 0x6c, 0x6c, 0x6f]); // "Hello"

        const rc4 = new RC4CipherTransform(key);
        const ciphertext = rc4.decrypt(plaintext); // encrypt

        const rc4_dec = new RC4CipherTransform(key);
        const decrypted = rc4_dec.decrypt(ciphertext);

        const result = new TextDecoder().decode(decrypted);

        expect(result).toBe("Hello");
    });
});

