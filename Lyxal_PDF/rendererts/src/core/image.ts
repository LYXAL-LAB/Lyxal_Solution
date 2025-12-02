import { Stream } from './stream';
import { Dict, Name } from './primitives';

export class PDFImage {
    width: number;
    height: number;
    bpc: number;
    numComps: number;
    stream: Stream;
    imageMask: boolean;
    
    constructor(stream: Stream) {
        this.stream = stream;
        const dict = stream.dict;
        
        this.width = dict?.get("Width") || 0;
        this.height = dict?.get("Height") || 0;
        this.bpc = dict?.get("BitsPerComponent") || 8;
        this.imageMask = dict?.get("ImageMask") || false;
        
        if (this.imageMask) {
            this.numComps = 1;
        } else {
            const cs = dict?.get("ColorSpace");
            if (cs instanceof Name) {
                if (cs.name === "DeviceGray") this.numComps = 1;
                else if (cs.name === "DeviceRGB") this.numComps = 3;
                else if (cs.name === "DeviceCMYK") this.numComps = 4;
                else this.numComps = 3; // Fallback
            } else if (Array.isArray(cs)) {
                // TODO: Handle array color spaces (Indexed, ICCBased...)
                this.numComps = 3; 
            } else {
                this.numComps = 3; // Default
            }
        }
    }
    
    get isJpeg(): boolean {
        // We need to check the ORIGINAL filter of the stream, not the current stream which might be decoded
        // For simplicity, we assume we check the dict of the stream provided.
        // If the stream is already a FlateStream wrapping a DCTDecode, this logic is tricky.
        // Actually, if it's DCTDecode, we usually don't wrap it in FlateStream unless there are multiple filters.
        
        const filter = this.stream.dict?.get("Filter");
        if (filter instanceof Name) {
            return filter.name === "DCTDecode" || filter.name === "DCT";
        }
        return false;
    }

    async getImageData(): Promise<Uint8ClampedArray> {
        const bytes = this.stream.getBytes(null);
        
        // If 1 bit mask, we need to expand bits to bytes
        if (this.bpc === 1 && this.numComps === 1) {
            // TODO: Implement bit expansion
            // Placeholder: return empty
            return new Uint8ClampedArray(this.width * this.height * 4);
        }

        const rgba = new Uint8ClampedArray(this.width * this.height * 4);
        let pos = 0;
        
        for (let i = 0; i < this.width * this.height; i++) {
            if (pos >= bytes.length) break;

            if (this.numComps === 3) {
                rgba[i * 4] = bytes[pos++];
                rgba[i * 4 + 1] = bytes[pos++];
                rgba[i * 4 + 2] = bytes[pos++];
                rgba[i * 4 + 3] = 255;
            } else if (this.numComps === 1) {
                const val = bytes[pos++];
                rgba[i * 4] = val;
                rgba[i * 4 + 1] = val;
                rgba[i * 4 + 2] = val;
                rgba[i * 4 + 3] = 255;
            } else if (this.numComps === 4) {
                // CMYK to RGB (naive)
                const c = bytes[pos++];
                const m = bytes[pos++];
                const y = bytes[pos++];
                const k = bytes[pos++];
                
                rgba[i * 4] = 255 * (1 - c/255) * (1 - k/255);
                rgba[i * 4 + 1] = 255 * (1 - m/255) * (1 - k/255);
                rgba[i * 4 + 2] = 255 * (1 - y/255) * (1 - k/255);
                rgba[i * 4 + 3] = 255;
            }
        }
        
        return rgba;
    }
}

