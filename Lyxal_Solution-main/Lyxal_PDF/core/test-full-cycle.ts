import { PDFDocument, StandardFonts, rgb, saveToStream, WriterTarget } from './dist/index.js';
import { BunFileReader } from './src/core/io/BunFileReader';
import fs from 'node:fs/promises';

// --- Writer Helpers ---
class FileTarget implements WriterTarget {
  private fileHandle: any;
  constructor(fileHandle: any) { this.fileHandle = fileHandle; }
  async write(chunk: Uint8Array): Promise<void> { await this.fileHandle.write(chunk); }
}

const FILENAME = 'lyxal_full_cycle.pdf';

const run = async () => {
  try {
    console.log('--- STEP 1: WRITE STREAMING ---');
    console.log('🚀 Creating 100-page PDF...');
    const pdfDoc = await PDFDocument.create();
    const helvetica = await pdfDoc.embedFont(StandardFonts.Helvetica);
    
    for (let i = 0; i < 100; i++) {
        const page = pdfDoc.addPage();
        const { width, height } = page.getSize();
        
        page.drawText(`Page ${i + 1} - Lyxal Full Cycle Test`, {
            x: 50, y: height - 50, size: 20, font: helvetica
        });

        // Add some weight
        for (let j = 0; j < 20; j++) {
            page.drawText(`Line ${j} : Content content content content content content content content`, {
                x: 50, y: height - 100 - (j * 15), size: 10, font: helvetica
            });
        }
    }

    console.log('🌊 Streaming to disk...');
    const writeStart = performance.now();
    const fileHandle = await fs.open(FILENAME, 'w');
    const target = new FileTarget(fileHandle);
    await saveToStream(pdfDoc, target);
    await fileHandle.close();
    const writeEnd = performance.now();
    console.log(`✅ Written in ${(writeEnd - writeStart).toFixed(2)}ms`);

    const stats = await fs.stat(FILENAME);
    console.log(`📦 File size: ${(stats.size / 1024).toFixed(2)} KB`);

    console.log('\n--- STEP 2: READ STREAMING ---');
    console.log('📖 Loading via PDFDocument.loadStream()...');
    const readStart = performance.now();
    
    const reader = new BunFileReader(FILENAME);
    const loadedDoc = await PDFDocument.loadStream(reader);
    
    const readEnd = performance.now();
    console.log(`✅ Initial Load (XRef parse) in ${(readEnd - readStart).toFixed(2)}ms`);
    
    const pageCount = loadedDoc.getPageCount();
    console.log(`📄 Page Count: ${pageCount} (Expected: 100)`);
    
    if (pageCount !== 100) throw new Error('Page count mismatch!');

    console.log('🔍 Accessing Page 50 (Random Access)...');
    const pageStart = performance.now();
    const page50 = loadedDoc.getPage(49); // 0-based
    const { width, height } = page50.getSize();
    console.log(`   Page 50 Size: ${width}x${height}`);
    const pageEnd = performance.now();
    console.log(`✅ Page 50 loaded in ${(pageEnd - pageStart).toFixed(2)}ms`);

    console.log('🔍 Accessing Page 99 (End of file)...');
    const page99 = loadedDoc.getPage(99);
    console.log(`   Page 99 Size: ${page99.getSize().width}x${page99.getSize().height}`);

    console.log('\n✅ FULL CYCLE TEST PASSED!');

  } catch (err) {
    console.error('❌ Error:', err);
    process.exit(1);
  }
};

run();

