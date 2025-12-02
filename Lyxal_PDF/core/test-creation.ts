import { PDFDocument, StandardFonts, rgb } from './dist/index.js';
import fs from 'node:fs/promises';

const run = async () => {
  try {
    console.log('🚀 Creating PDF...');
    
    // 1. Create document
    const pdfDoc = await PDFDocument.create();
    
    // 2. Add page
    const page = pdfDoc.addPage();
    const { width, height } = page.getSize();
    
    // 3. Embed font (uses @lyxal-pdf/pdf-fonts)
    const helvetica = await pdfDoc.embedFont(StandardFonts.Helvetica);
    
    // 4. Draw text
    const fontSize = 30;
    page.drawText('Hello Lyxal PDF Engine!', {
      x: 50,
      y: height - 4 * fontSize,
      size: fontSize,
      font: helvetica,
      color: rgb(0, 0.53, 0.71),
    });
    
    console.log('✍️  Writing PDF...');
    
    // 5. Save (uses @lyxal-compression/compression)
    const pdfBytes = await pdfDoc.save();
    
    await fs.writeFile('lyxal_test.pdf', pdfBytes);
    
    console.log(`✅ PDF created successfully! Size: ${pdfBytes.length} bytes`);
  } catch (err) {
    console.error('❌ Error:', err);
  }
};

run();

