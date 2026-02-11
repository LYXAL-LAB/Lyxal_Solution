import { RandomAccessReader } from './RandomAccessReader';
import ByteStream from 'src/core/parser/ByteStream';
import PDFParser from 'src/core/parser/PDFParser';
import PDFObject from 'src/core/objects/PDFObject';
import PDFRawStream from 'src/core/objects/PDFRawStream';
import PDFDict from 'src/core/objects/PDFDict';
import PDFNumber from 'src/core/objects/PDFNumber';
import PDFName from 'src/core/objects/PDFName';
import PDFRef from 'src/core/objects/PDFRef';
import CharCodes from 'src/core/syntax/CharCodes';
import PDFXRefStreamParser from 'src/core/parser/PDFXRefStreamParser';
import PDFObjectStreamParser from 'src/core/parser/PDFObjectStreamParser';
import { decodePDFRawStream } from 'src/core/streams/decode';
import PDFContext from 'src/core/PDFContext';

type XRefEntry = 
  | { type: 'standard', offset: number }
  | { type: 'compressed', streamObjNum: number, index: number };

export class PDFObjectLoader {
  private readonly reader: RandomAccessReader;
  private readonly context?: PDFContext;
  private xrefTable: Map<number, XRefEntry> = new Map();
  private trailerInfo: any = {}; // Stores Root, Encrypt, etc.
  
  constructor(reader: RandomAccessReader, context?: PDFContext) {
    this.reader = reader;
    this.context = context;
  }

  getAllObjectRefs(): PDFRef[] {
      const refs: PDFRef[] = [];
      for (const [objNum, entry] of this.xrefTable) {
          refs.push(PDFRef.of(objNum, 0));
      }
      return refs;
  }

  getTrailerInfo(): any {
      return this.trailerInfo;
  }

  async loadObject(ref: PDFRef): Promise<PDFObject> {
    const entry = this.xrefTable.get(ref.objectNumber);
    if (!entry) {
        throw new Error(`Object ${ref.objectNumber} not found in XRef table.`);
    }

    if (entry.type === 'standard') {
        return this.loadObjectAt(entry.offset);
    } else {
        const streamRef = PDFRef.of(entry.streamObjNum, 0);
        
        // Avoid infinite recursion if stream obj is not in table (should not happen if standard)
        if (!this.xrefTable.has(entry.streamObjNum)) {
             throw new Error(`Stream Object ${entry.streamObjNum} not found in table.`);
        }

        const streamObj = await this.loadObject(streamRef);
        
        if (!(streamObj instanceof PDFRawStream)) {
            throw new Error(`Object ${entry.streamObjNum} is not a stream.`);
        }

        const decoded = decodePDFRawStream(streamObj).decode();
        const streamParser = new PDFParser(decoded, this.context);
        
        const firstOffset = streamObj.dict.lookup(PDFName.of('First'), PDFNumber)?.asNumber() || 0;
        const count = streamObj.dict.lookup(PDFName.of('N'), PDFNumber)?.asNumber() || 0;
        
        if (entry.index >= count) throw new Error(`Index ${entry.index} out of bounds.`);

        for (let i = 0; i < count; i++) {
            const objNumObj = streamParser.parseObject();
            if (!(objNumObj instanceof PDFNumber)) throw new Error('Expected number');
            const objNum = objNumObj.asNumber();
            
            const offObj = streamParser.parseObject();
            if (!(offObj instanceof PDFNumber)) throw new Error('Expected offset');
            const off = offObj.asNumber();
            
            if (i === entry.index) {
                const absoluteOffset = firstOffset + off;
                const objectContent = decoded.subarray(absoluteOffset);
                const objParser = new PDFParser(objectContent, this.context);
                return objParser.parseObject();
            }
        }
        
        throw new Error(`Could not find object ${ref.objectNumber} in stream.`);
    }
  }

  async loadObjectAt(offset: number, estimatedLength: number = 4096): Promise<PDFObject> {
    const data = await this.reader.read(offset, estimatedLength);
    const parser = new PDFParser(data, this.context);
    const result = await parser.parseIndirectObject();
    return result[1];
  }

  async readXrefTable(): Promise<void> {
    const startXref = await this.findStartXrefOffset();
    const headChunk = await this.reader.read(startXref, 128); 
    const str = this.bytesToString(headChunk);

    if (str.startsWith('xref')) {
        const fullChunk = await this.reader.read(startXref, 16384); 
        this.parseAsciiXref(this.bytesToString(fullChunk));
        
        const trailerIdx = this.bytesToString(fullChunk).lastIndexOf('trailer');
        if (trailerIdx !== -1) {
             const trailerChunk = fullChunk.subarray(trailerIdx + 7); // skip 'trailer'
             const parser = new PDFParser(trailerChunk, this.context);
             const dict = parser.parseObject();
             if (dict instanceof PDFDict) {
                 this.populateTrailerInfo(dict);
             }
        }

    } else {
        const object = await this.loadObjectAt(startXref);
        
        if (object instanceof PDFRawStream) {
             const type = object.dict.lookup(PDFName.of('Type'));
             if (type === PDFName.of('XRef')) {
                 const parser = PDFXRefStreamParser.forStream(object);
                 const entries = parser.parseIntoContext();
                 
                 this.populateTrailerInfo(object.dict);

                 let stdCount = 0;
                 let compCount = 0;

                 for (const entry of entries) {
                     if (entry.deleted) continue;
                     if (entry.inObjectStream) {
                         this.xrefTable.set(entry.ref.objectNumber, {
                             type: 'compressed',
                             streamObjNum: entry.offset,
                             index: entry.ref.generationNumber
                         });
                         compCount++;
                     } else {
                         this.xrefTable.set(entry.ref.objectNumber, {
                             type: 'standard',
                             offset: entry.offset
                         });
                         stdCount++;
                     }
                 }
                 console.log(`DEBUG: Parsed XRef Stream. Standard: ${stdCount}, Compressed: ${compCount}`);
                 return;
             }
        }
        console.warn('Unknown XRef format or parsing failed');
    }
  }

  private populateTrailerInfo(dict: PDFDict) {
      const get = (name: string) => {
          let val = dict.lookup(PDFName.of(name));
          if (!val) {
              const target = '/' + name;
              for (const [key, value] of dict.entries()) {
                  if (key.asString() === target) return value;
              }
          }
          return val;
      };

      this.trailerInfo = {
          Root: get('Root'),
          Encrypt: get('Encrypt'),
          Info: get('Info'),
          ID: get('ID'),
      };
  }

  private parseAsciiXref(data: string) {
    const lines = data.split(/\r\n|\r|\n/);
    let idx = 0;
    if (lines[idx].trim() === 'xref') idx++;
    while (idx < lines.length) {
        const line = lines[idx];
        if (!line) { idx++; continue; }
        if (line.trim() === 'trailer') break;
        const headerMatch = line.match(/^(\d+)\s+(\d+)$/);
        if (headerMatch) {
            let objectNumber = parseInt(headerMatch[1], 10);
            const count = parseInt(headerMatch[2], 10);
            idx++;
            for (let i = 0; i < count && idx < lines.length; i++) {
                const entryLine = lines[idx++];
                const entryMatch = entryLine.match(/^(\d{10}) (\d{5}) (n|f)/);
                if (entryMatch) {
                    if (entryMatch[3] === 'n') {
                        const offset = parseInt(entryMatch[1], 10);
                        this.xrefTable.set(objectNumber, { type: 'standard', offset });
                    }
                    objectNumber++;
                }
            }
        } else {
            idx++;
        }
    }
  }

  async findStartXrefOffset(): Promise<number> {
    const fileSize = this.reader.getSize();
    const scanSize = Math.min(fileSize, 1024);
    const startPos = fileSize - scanSize;
    const tail = await this.reader.read(startPos, scanSize);
    const tailStr = this.bytesToString(tail);
    const startxrefIndex = tailStr.lastIndexOf('startxref');
    if (startxrefIndex === -1) throw new Error('Could not find startxref');
    const eofIndex = tailStr.lastIndexOf('%%EOF');
    const numberStr = tailStr.substring(startxrefIndex + 9, eofIndex).trim();
    return parseInt(numberStr, 10);
  }

  private bytesToString(bytes: Uint8Array): string {
    let str = '';
    for (let i = 0; i < bytes.length; i++) str += String.fromCharCode(bytes[i]);
    return str;
  }
}
