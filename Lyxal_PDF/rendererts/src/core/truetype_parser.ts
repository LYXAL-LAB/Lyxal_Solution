import { Stream } from './stream';

interface TableEntry {
    tag: string;
    checksum: number;
    offset: number;
    length: number;
}

export class TrueTypeParser {
    stream: Stream;
    tables: Map<string, TableEntry> = new Map();

    constructor(stream: Stream) {
        this.stream = stream;
    }

    numGlyphs: number = 0;
    numberOfHMetrics: number = 0;
    metrics: { advance: number, lsb: number }[] = [];
    cmap: Map<number, number> = new Map();

    parse() {
        this.parseHeader();
        this.parseMaxp();
        this.parseHhea();
        this.parseHmtx();
        this.parseCmap();
    }

    parseMaxp() {
        const stream = this.getTable("maxp");
        if (!stream) return;
        
        const version = stream.getInt32();
        this.numGlyphs = stream.getUint16();
    }

    parseHhea() {
        const stream = this.getTable("hhea");
        if (!stream) return;
        
        // Skip majorVersion(2), minorVersion(2), ascender(2), descender(2), lineGap(2), 
        // advanceWidthMax(2), minLeftSideBearing(2), minRightSideBearing(2), xMaxExtent(2), 
        // caretSlopeRise(2), caretSlopeRun(2), caretOffset(2), reserved(8), metricDataFormat(2)
        stream.skip(34);
        
        this.numberOfHMetrics = stream.getUint16();
    }

    parseHmtx() {
        const stream = this.getTable("hmtx");
        if (!stream) return;
        
        this.metrics = [];
        for (let i = 0; i < this.numberOfHMetrics; i++) {
            const advance = stream.getUint16();
            const lsb = stream.getInt16();
            this.metrics.push({ advance, lsb });
        }
        
        // There can be more glyphs than metrics. Remaining glyphs use the last advance width.
        // We handle this lookup logic in getWidth(glyphIndex).
    }

    getWidth(glyphIndex: number): number {
        if (glyphIndex < this.numberOfHMetrics) {
            return this.metrics[glyphIndex].advance;
        }
        // Use the last metric's advance for remaining glyphs
        if (this.metrics.length > 0) {
            return this.metrics[this.metrics.length - 1].advance;
        }
        return 0;
    }

    parseCmap() {
        const stream = this.getTable("cmap");
        if (!stream) return;
        
        const version = stream.getUint16();
        const numTables = stream.getUint16();
        
        let selectedOffset = -1;
        
        for (let i = 0; i < numTables; i++) {
            const platformID = stream.getUint16();
            const encodingID = stream.getUint16();
            const offset = stream.getUint32();
            
            // Prefer Windows Unicode (3, 1) or Unicode (0, 3)
            if ((platformID === 3 && encodingID === 1) || (platformID === 0 && encodingID === 3)) {
                selectedOffset = offset;
                break;
            }
            // Fallback to Mac Roman (1, 0)
            if (platformID === 1 && encodingID === 0 && selectedOffset === -1) {
                selectedOffset = offset;
            }
        }
        
        if (selectedOffset !== -1) {
            this.parseCmapSubtable(stream, selectedOffset);
        }
    }

    parseCmapSubtable(stream: Stream, offset: number) {
        stream.pos = offset;
        const format = stream.getUint16();
        const length = stream.getUint16();
        const language = stream.getUint16();
        
        if (format === 4) {
            // Segment mapping to delta values
            const segCountX2 = stream.getUint16();
            const segCount = segCountX2 / 2;
            const searchRange = stream.getUint16();
            const entrySelector = stream.getUint16();
            const rangeShift = stream.getUint16();
            
            const endCount: number[] = [];
            for (let i = 0; i < segCount; i++) endCount.push(stream.getUint16());
            
            stream.getUint16(); // reservedPad
            
            const startCount: number[] = [];
            for (let i = 0; i < segCount; i++) startCount.push(stream.getUint16());
            
            const idDelta: number[] = [];
            for (let i = 0; i < segCount; i++) idDelta.push(stream.getInt16()); // Signed!
            
            const idRangeOffsetPos = stream.pos;
            const idRangeOffset: number[] = [];
            for (let i = 0; i < segCount; i++) idRangeOffset.push(stream.getUint16());
            
            // Populate Map
            // This is a simplified parse, we should really do lookup on demand or fill a dense array.
            // But Map is fine for sparse fonts.
            
            for (let i = 0; i < segCount; i++) {
                const start = startCount[i];
                const end = endCount[i];
                const delta = idDelta[i];
                const rangeOffset = idRangeOffset[i];
                
                if (rangeOffset === 0) {
                    for (let c = start; c <= end; c++) {
                        let glyphIndex = (c + delta) & 0xFFFF;
                        this.cmap.set(c, glyphIndex);
                    }
                } else {
                    // rangeOffset is offset from the location of idRangeOffset[i] itself.
                    // location of idRangeOffset[i] is idRangeOffsetPos + i * 2
                    const currentRangeOffsetPos = idRangeOffsetPos + (i * 2);
                    
                    for (let c = start; c <= end; c++) {
                        const offset = currentRangeOffsetPos + rangeOffset + (c - start) * 2;
                        
                        const savedPos = stream.pos;
                        stream.pos = offset;
                        let glyphIndex = stream.getUint16();
                        stream.pos = savedPos;
                        
                        if (glyphIndex !== 0) {
                             glyphIndex = (glyphIndex + delta) & 0xFFFF;
                             this.cmap.set(c, glyphIndex);
                        }
                    }
                }
            }
        } else if (format === 0) {
            // Byte encoding table
            for (let i = 0; i < 256; i++) {
                const glyphIndex = stream.getByte();
                this.cmap.set(i, glyphIndex);
            }
        }
    }

    parseHeader() {
        const stream = this.stream;
        stream.pos = 0;
        
        const version = stream.getInt32(); // 1.0 or 'true' or 'OTTO'
        const numTables = stream.getUint16();
        const searchRange = stream.getUint16();
        const entrySelector = stream.getUint16();
        const rangeShift = stream.getUint16();

        for (let i = 0; i < numTables; i++) {
            const tag = this.readTag(stream);
            const checksum = stream.getUint32();
            const offset = stream.getUint32();
            const length = stream.getUint32();
            
            this.tables.set(tag, { tag, checksum, offset, length });
        }
    }

    readTag(stream: Stream): string {
        const b1 = stream.getByte();
        const b2 = stream.getByte();
        const b3 = stream.getByte();
        const b4 = stream.getByte();
        return String.fromCharCode(b1, b2, b3, b4);
    }

    getTable(tag: string): Stream | null {
        const entry = this.tables.get(tag);
        if (!entry) return null;
        return this.stream.makeSubStream(entry.offset, entry.length);
    }
}

