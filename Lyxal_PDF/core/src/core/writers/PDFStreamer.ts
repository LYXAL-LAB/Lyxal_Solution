import PDFCrossRefSection from 'src/core/document/PDFCrossRefSection';
import PDFHeader from 'src/core/document/PDFHeader';
import PDFTrailer from 'src/core/document/PDFTrailer';
import PDFTrailerDict from 'src/core/document/PDFTrailerDict';
import PDFDict from 'src/core/objects/PDFDict';
import PDFObject from 'src/core/objects/PDFObject';
import PDFRef from 'src/core/objects/PDFRef';
import PDFContext from 'src/core/PDFContext';
import PDFObjectStream from 'src/core/structures/PDFObjectStream';
import CharCodes from 'src/core/syntax/CharCodes';
import { copyStringIntoBuffer, waitForTick } from 'src/utils';

export interface WriterTarget {
  write(chunk: Uint8Array): Promise<void> | void;
}

class PDFStreamer {
  static forContext = (context: PDFContext, objectsPerTick: number) =>
    new PDFStreamer(context, objectsPerTick);

  protected readonly context: PDFContext;
  protected readonly objectsPerTick: number;
  private parsedObjects = 0;

  protected constructor(context: PDFContext, objectsPerTick: number) {
    this.context = context;
    this.objectsPerTick = objectsPerTick;
  }

  async serializeToTarget(target: WriterTarget): Promise<void> {
    let offset = 0;

    // 1. Header
    const header = PDFHeader.forVersion(1, 7);
    const headerSize = header.sizeInBytes() + 2; // + \n\n
    const headerBuffer = new Uint8Array(headerSize);
    header.copyBytesInto(headerBuffer, 0);
    headerBuffer[headerSize - 2] = CharCodes.Newline;
    headerBuffer[headerSize - 1] = CharCodes.Newline;
    
    await target.write(headerBuffer);
    offset += headerSize;

    // 2. Body (Indirect Objects)
    const xref = PDFCrossRefSection.create();
    const indirectObjects = this.context.enumerateIndirectObjects();

    for (let idx = 0, len = indirectObjects.length; idx < len; idx++) {
      const [ref, object] = indirectObjects[idx];
      
      // Register offset in XRef
      xref.addEntry(ref, offset);

      // Serialize Object
      const objectBuffer = this.serializeIndirectObject(ref, object);
      await target.write(objectBuffer);
      offset += objectBuffer.length;

      // Anti-freeze
      const n = object instanceof PDFObjectStream ? object.getObjectsCount() : 1;
      if (this.shouldWaitForTick(n)) await waitForTick();
    }

    // 3. XRef Table
    const xrefOffset = offset;
    const xrefBuffer = new Uint8Array(xref.sizeInBytes() + 1);
    xref.copyBytesInto(xrefBuffer, 0);
    xrefBuffer[xrefBuffer.length - 1] = CharCodes.Newline;
    
    await target.write(xrefBuffer);
    offset += xrefBuffer.length;

    // 4. Trailer Dict
    const trailerDict = PDFTrailerDict.of(this.createTrailerDict());
    const trailerDictBuffer = new Uint8Array(trailerDict.sizeInBytes() + 2);
    trailerDict.copyBytesInto(trailerDictBuffer, 0);
    trailerDictBuffer[trailerDictBuffer.length - 2] = CharCodes.Newline;
    trailerDictBuffer[trailerDictBuffer.length - 1] = CharCodes.Newline;

    await target.write(trailerDictBuffer);
    offset += trailerDictBuffer.length;

    // 5. Trailer (startxref)
    const trailer = PDFTrailer.forLastCrossRefSectionOffset(xrefOffset);
    const trailerBuffer = new Uint8Array(trailer.sizeInBytes());
    trailer.copyBytesInto(trailerBuffer, 0);
    
    await target.write(trailerBuffer);
    offset += trailerBuffer.length;
  }

  protected serializeIndirectObject(ref: PDFRef, object: PDFObject): Uint8Array {
    const size = this.computeIndirectObjectSize([ref, object]);
    const buffer = new Uint8Array(size);
    let offset = 0;

    const objectNumber = String(ref.objectNumber);
    offset += copyStringIntoBuffer(objectNumber, buffer, offset);
    buffer[offset++] = CharCodes.Space;

    const generationNumber = String(ref.generationNumber);
    offset += copyStringIntoBuffer(generationNumber, buffer, offset);
    buffer[offset++] = CharCodes.Space;

    buffer[offset++] = CharCodes.o;
    buffer[offset++] = CharCodes.b;
    buffer[offset++] = CharCodes.j;
    buffer[offset++] = CharCodes.Newline;

    offset += object.copyBytesInto(buffer, offset);

    buffer[offset++] = CharCodes.Newline;
    buffer[offset++] = CharCodes.e;
    buffer[offset++] = CharCodes.n;
    buffer[offset++] = CharCodes.d;
    buffer[offset++] = CharCodes.o;
    buffer[offset++] = CharCodes.b;
    buffer[offset++] = CharCodes.j;
    buffer[offset++] = CharCodes.Newline;
    buffer[offset++] = CharCodes.Newline;

    return buffer;
  }

  protected computeIndirectObjectSize([ref, object]: [PDFRef, PDFObject]): number {
    const refSize = ref.sizeInBytes() + 3; // 'R' -> 'obj\n'
    const objectSize = object.sizeInBytes() + 9; // '\nendobj\n\n'
    return refSize + objectSize;
  }

  protected createTrailerDict(): PDFDict {
    return this.context.obj({
      Size: this.context.largestObjectNumber + 1,
      Root: this.context.trailerInfo.Root,
      Encrypt: this.context.trailerInfo.Encrypt,
      Info: this.context.trailerInfo.Info,
      ID: this.context.trailerInfo.ID,
    });
  }

  protected shouldWaitForTick = (n: number) => {
    this.parsedObjects += n;
    return this.parsedObjects % this.objectsPerTick === 0;
  };
}

export default PDFStreamer;

