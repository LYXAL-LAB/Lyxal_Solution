import { PDFDocument, StandardFonts, rgb, saveToStream, WriterTarget } from './dist/index.js';
import fs from 'node:fs/promises';

class FileTarget implements WriterTarget {
  private fileHandle: any;
  constructor(fileHandle: any) { this.fileHandle = fileHandle; }
  async write(chunk: Uint8Array): Promise<void> { await this.fileHandle.write(chunk); }
}

const run = async () => {
  try {
    console.log('🚀 Creating Heavy PDF for Streaming...');
    const pdfDoc = await PDFDocument.create();
    const helvetica = await pdfDoc.embedFont(StandardFonts.Helvetica);
    
    // Générer 100 pages
    for (let i = 0; i < 100; i++) {
        const page = pdfDoc.addPage();
        const { width, height } = page.getSize();
        
        page.drawText(`Page ${i + 1} - Lyxal Streaming Test`, {
            x: 50, y: height - 50, size: 20, font: helvetica
        });

        // Remplir la page de texte
        for (let j = 0; j < 50; j++) {
            page.drawText(`Line ${j} : Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.`, {
                x: 50,
                y: height - 80 - (j * 15),
                size: 10,
                font: helvetica,
                color: rgb(0, 0, 0),
            });
        }
        
        // Log progress every 20 pages
        if (i > 0 && i % 20 === 0) console.log(`   Generated ${i} pages...`);
    }

    console.log('🌊 Streaming heavy PDF to disk...');
    const start = performance.now();
    
    const fileHandle = await fs.open('lyxal_heavy_streamed.pdf', 'w');
    const target = new FileTarget(fileHandle);

    // Stream !
    await saveToStream(pdfDoc, target);
    
    await fileHandle.close();
    
    const end = performance.now();
    console.log(`✅ Heavy PDF streamed successfully in ${(end - start).toFixed(2)}ms!`);
    
    const stats = await fs.stat('lyxal_heavy_streamed.pdf');
    console.log(`📦 File size: ${(stats.size / 1024 / 1024).toFixed(2)} MB`);

  } catch (err) {
    console.error('❌ Error:', err);
  }
};

run();
