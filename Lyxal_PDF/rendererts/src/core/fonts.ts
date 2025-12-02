import { Dict, Name, Ref } from './primitives';
import { getEncoding } from './encodings';
import { CMap } from './cmap';
import { Stream } from './stream';

export class Font {
    name: string;
    loadedName: string;
    encoding: string[] | null = null;
    widths: number[] = [];
    defaultWidth: number = 0;
    toUnicodeMap: CMap | null = null;

    constructor(name: string) {
        this.name = name;
        this.loadedName = name;
    }

    static async create(xref: any, dict: Dict, ref: Ref | null): Promise<Font> {
        const baseFont = dict.get("BaseFont");
        const name = baseFont instanceof Name ? baseFont.name : "sans-serif";
        const font = new Font(name);
        
        // 1. Encoding
        const encoding = dict.get("Encoding");
        if (encoding instanceof Name) {
            font.encoding = getEncoding(encoding.name);
        } else if (encoding instanceof Dict) {
            const baseEncName = encoding.get("BaseEncoding");
            if (baseEncName instanceof Name) {
                const baseEnc = getEncoding(baseEncName.name);
                if (baseEnc) font.encoding = [...baseEnc]; // Clone
            }
            
            // Differences
            const differences = encoding.get("Differences");
            if (Array.isArray(differences) && font.encoding) {
                let code = 0;
                for (const item of differences) {
                    if (typeof item === 'number') {
                        code = item;
                    } else if (item instanceof Name) {
                        font.encoding[code++] = item.name;
                    }
                }
            }
        }
        
        // 2. Widths
        const firstChar = dict.get("FirstChar") || 0;
        const lastChar = dict.get("LastChar") || 255;
        const widths = dict.get("Widths");
        
        if (Array.isArray(widths)) {
            for (let i = 0; i < widths.length; i++) {
                font.widths[firstChar + i] = widths[i];
            }
        }
        
        // 3. ToUnicode (essential for text selection/search)
        const toUnicode = dict.get("ToUnicode");
        if (toUnicode instanceof Stream) {
            try {
                font.toUnicodeMap = await CMap.parse(toUnicode);
            } catch (e) {
                console.warn("Failed to parse ToUnicode CMap", e);
            }
        }
        
        return font;
    }
    
    getChar(code: number): string {
        // 1. Check ToUnicode
        if (this.toUnicodeMap) {
            const char = this.toUnicodeMap.lookup(code);
            if (char) return char;
        }
        
        // 2. Check Encoding (Glyph Name to Unicode)
        if (this.encoding && this.encoding[code]) {
            const glyphName = this.encoding[code];
            // Simple mapping for standard names
            // TODO: Use full glyph list
            if (glyphName.length === 1) return glyphName;
            if (glyphName === "space") return " ";
            // ...
        }
        
        // 3. Fallback: Identity / ISO-Latin-1
        return String.fromCharCode(code);
    }
    
    getWidth(code: number): number {
        return this.widths[code] || this.defaultWidth;
    }
}

