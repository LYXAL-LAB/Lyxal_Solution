import { Dict, Name, Ref } from './primitives';
import { getEncoding } from './encodings';
import { CMap } from './cmap';
import { Stream } from './stream';
import { CFFParser } from './cff_parser';
import { TrueTypeParser } from './truetype_parser';

export class Font {
    name: string;
    loadedName: string;
    encoding: string[] | null = null;
    widths: number[] = [];
    defaultWidth: number = 0;
    toUnicodeMap: CMap | null = null;
    
    // Embedded Font Data
    cff: CFFParser | null = null;
    ttf: TrueTypeParser | null = null;
    isEmbedded: boolean = false;

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
        
        // 3. Font Descriptor (Embedded Fonts)
        const fontDesc = dict.get("FontDescriptor");
        if (fontDesc instanceof Dict) {
            font.defaultWidth = fontDesc.get("MissingWidth") || 0;
            
            // Type 1 / CFF
            let fontFile = fontDesc.get("FontFile3");
            if (fontFile instanceof Stream) {
                const subtype = fontFile.dict?.get("Subtype");
                if (subtype && subtype.name === "Type1C") {
                    try {
                        const cff = new CFFParser(fontFile);
                        cff.parse();
                        font.cff = cff;
                        font.isEmbedded = true;
                    } catch (e) {
                        console.warn("Failed to parse CFF font", e);
                    }
                }
            }

            // TrueType
            if (!font.isEmbedded) {
                fontFile = fontDesc.get("FontFile2");
                if (fontFile instanceof Stream) {
                    try {
                        const ttf = new TrueTypeParser(fontFile);
                        ttf.parse();
                        font.ttf = ttf;
                        font.isEmbedded = true;
                    } catch (e) {
                         console.warn("Failed to parse TrueType font", e);
                    }
                }
            }
        }

        // 4. ToUnicode (essential for text selection/search)
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
        // PDF Widths take precedence
        if (this.widths[code] !== undefined) {
             return this.widths[code];
        }

        // Fallback to embedded font metrics if available
        if (this.ttf) {
            // Need to map code to glyph index using cmap
            // This is a simplification; handling encoding vs cmap is complex
            const gid = this.ttf.cmap.get(code);
            if (gid !== undefined) {
                 // TTF units to PDF units (usually 1000 em)
                 // PDF = TTF * 1000 / unitsPerEm (usually 2048 or 1000)
                 // We need unitsPerEm from Head table (not parsed yet)
                 // For now, assume PDF widths are usually present for simple fonts.
                 return this.ttf.getWidth(gid); 
            }
        }
        
        return this.defaultWidth;
    }
}

