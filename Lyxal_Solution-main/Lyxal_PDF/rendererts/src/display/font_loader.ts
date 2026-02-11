export class FontLoader {
    docId: string;
    
    constructor(docId: string) {
        this.docId = docId;
    }

    async bind(fontData: any): Promise<void> {
        if (!fontData.data) return;

        const fontName = fontData.loadedName;
        // Basic descriptors mapping
        // TODO: Map fontData properties (flags, italicAngle etc) to FontFaceDescriptors
        const descriptors: FontFaceDescriptors = {
            style: 'normal',
            weight: 'normal',
        };

        if (fontData.italic) descriptors.style = 'italic';
        if (fontData.bold) descriptors.weight = 'bold';

        // Load Font using FontFace API
        if (typeof FontFace !== 'undefined') {
            try {
                // fontData.data is Uint8Array
                const fontFace = new FontFace(fontName, fontData.data, descriptors);
                
                // Add to document fonts
                // TypeScript definitions for document.fonts might be outdated or missing 'add'
                // Cast to any to bypass strict check for standard API
                (document.fonts as any).add(fontFace);
                
                await fontFace.load();
            } catch (e) {
                console.warn(`FontLoader: Failed to load font ${fontName}`, e);
                // Fallback?
            }
        } else {
            console.warn("FontLoader: FontFace API not supported");
            // Legacy fallback using style tags and base64 (omitted for brevity in modern context)
        }
    }
}
