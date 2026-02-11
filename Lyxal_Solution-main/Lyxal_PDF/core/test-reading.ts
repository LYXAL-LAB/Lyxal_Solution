import { PDFDocument, StandardFonts, saveToStream, WriterTarget } from './dist/index.js';
import { BunFileReader } from './src/core/io/BunFileReader';
import { PDFObjectLoader } from './src/core/io/PDFObjectLoader';
import PDFRef from './src/core/objects/PDFRef';
import fs from 'node:fs/promises';

// --- Setup: Generate a PDF ---
class FileTarget implements WriterTarget {
  private fileHandle: any;
  constructor(fileHandle: any) { this.fileHandle = fileHandle; }
  async write(chunk: Uint8Array): Promise<void> { await this.fileHandle.write(chunk); }
}

const generatePdf = async (filename: string) => {
  const pdfDoc = await PDFDocument.create();
  const page = pdfDoc.addPage();
  page.drawText('Test for Reading', { x: 50, y: 500, size: 20 });
  
  const fileHandle = await fs.open(filename, 'w');
  const target = new FileTarget(fileHandle);
  await saveToStream(pdfDoc, target);
  await fileHandle.close();
};

// --- Test: Read Partial ---
const run = async () => {
  const filename = 'temp_read_test.pdf';
  
  try {
    console.log('1️⃣ Generating PDF...');
    await generatePdf(filename);
    
    console.log('2️⃣ Initializing Reader (Lazy Loading)...');
    const reader = new BunFileReader(filename);
    const loader = new PDFObjectLoader(reader);
    
    console.log(`   File size: ${reader.getSize()} bytes`);
    
    console.log('3️⃣ Finding StartXref...');
    const startXref = await loader.findStartXrefOffset();
    console.log(`   StartXref found at offset: ${startXref}`);
    
    console.log('4️⃣ Parsing XRef Table...');
    await loader.readXrefTable();
    
    // In our generated PDF, object 6 is usually the content stream
    // Or object 1 is the Pages root.
    console.log('5️⃣ Loading Object 1 0 R (Pages Root)...');
    const ref = PDFRef.of(1, 0);
    const obj = await loader.loadObject(ref);
    
    console.log('   ✅ Object Loaded:', obj.constructor.name);
    console.log('   Dump:', obj.toString());

  } catch (err) {
    console.error('❌ Error:', err);
  } finally {
    // Cleanup
    // await fs.unlink(filename);
  }
};

run();
