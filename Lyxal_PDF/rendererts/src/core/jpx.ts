import { Stream } from './stream';
import { Dict } from './primitives';

export class JpxImage {
    width: number = 0;
    height: number = 0;
    componentsCount: number = 0;
    bitsPerComponent: number = 0;
    tiles: any[] = [];
    
    parse(data: Uint8Array) {
        const stream = new Stream(data);
        
        // JPEG 2000 Codestream parsing
        // SOC (Start of Codestream) = 0xFF4F
        
        if (stream.getByte() !== 0xFF || stream.getByte() !== 0x4F) {
            // throw new Error("Invalid JPX signature");
        }
        
        while (stream.pos < stream.length) {
            const marker = (stream.getByte() << 8) | stream.getByte();
            
            switch (marker) {
                case 0xFF51: // SIZ (Image and tile size)
                    this.parseSIZ(stream);
                    break;
                case 0xFF52: // COD (Coding style default)
                case 0xFF53: // COC (Coding style component)
                case 0xFF5C: // QCD (Quantization default)
                    // Skip
                    const len = stream.getUint16();
                    stream.skip(len - 2);
                    break;
                case 0xFF90: // SOT (Start of tile-part)
                    // ...
                    const len2 = stream.getUint16();
                    stream.skip(len2 - 2);
                    break;
                case 0xFFD9: // EOC (End of codestream)
                    return;
                default:
                    // Markers 0xFF30-0xFF3F are invalid/reserved?
                    // Usually we have length after marker for segments.
                    if (marker >= 0xFF00) {
                         const len = stream.getUint16();
                         stream.skip(len - 2);
                    }
                    break;
            }
        }
    }

    parseSIZ(stream: Stream) {
        const len = stream.getUint16();
        const cap = stream.getUint16(); // RSiz (Capabilities)
        this.width = stream.getUint32(); // Xsiz
        this.height = stream.getUint32(); // Ysiz
        const xOsiz = stream.getUint32(); // Image offset X
        const yOsiz = stream.getUint32(); // Image offset Y
        const tileW = stream.getUint32();
        const tileH = stream.getUint32();
        const tileX = stream.getUint32();
        const tileY = stream.getUint32();
        this.componentsCount = stream.getUint16();
        
        // Components info
        // Precision, subsampling...
        stream.skip(this.componentsCount * 3);
    }
}

export class JpxStream extends Stream {
    constructor(stream: Stream, params: Dict | null) {
        const data = stream.getBytes(null);
        // Placeholder: wrapper
        super(data);
    }
}

