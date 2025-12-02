import { BaseStream, Stream } from './stream';
import { Dict } from './primitives';

// Bun provides native zlib support
// We need to declare it to avoid TS errors if types are missing, 
// but Bun global usually has it.
// If not, we use 'node:zlib' which Bun implements.
import { inflateSync } from 'node:zlib';

export class FlateStream extends Stream {
    constructor(stream: BaseStream, length: number = 0, params: Dict | null = null) {
        // Read compressed bytes from the source stream
        const bytes = stream.getBytes(length || null); // Read until length or end
        
        let decompressed: Uint8Array;
        try {
            decompressed = inflateSync(bytes);
        } catch (e) {
            // Fallback or error handling
            console.error("FlateDecode failed", e);
            throw new Error("FlateDecode failed: " + e);
        }

        // Initialize this stream with decompressed data
        super(decompressed, 0, decompressed.length, stream instanceof Stream ? stream.dict : null);
        
        // TODO: Handle Predictor (PNG filters) often used with Flate
        if (params) {
            const predictor = params.get("Predictor");
            if (predictor && predictor > 1) {
                // We will need a PredictorStream wrapper later
                // console.warn("FlateStream: Predictor not implemented yet", predictor);
            }
        }
    }
}

