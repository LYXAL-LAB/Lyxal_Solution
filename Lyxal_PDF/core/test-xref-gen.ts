import { PDFDocument } from './dist/index.js';
import fs from 'node:fs/promises';

const run = async () => {
  console.log('Generating PDF with XRef Stream...');
  const pdfDoc = await PDFDocument.create();
  const page = pdfDoc.addPage();
  page.drawText('Test XRef Stream');
  
  // useObjectStreams: true forces PDF 1.5+ structure (compressed objects and XRef stream)
  const pdfBytes = await pdfDoc.save({ useObjectStreams: true });
  
  await fs.writeFile('lyxal_xref_stream.pdf', pdfBytes);
  console.log(`Generated 'lyxal_xref_stream.pdf' (${pdfBytes.length} bytes)`);
};

run();

