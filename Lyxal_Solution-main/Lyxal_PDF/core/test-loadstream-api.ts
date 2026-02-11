import { PDFDocument } from './dist/index.js';
import { BunFileReader } from './src/core/io/BunFileReader';

const run = async () => {
  const filename = 'lyxal_xref_stream.pdf';
  const reader = new BunFileReader(filename);
  
  console.log('🚀 Loading via PDFDocument.loadStream()...');
  const pdfDoc = await PDFDocument.loadStream(reader);
  
  console.log(`   Page count: ${pdfDoc.getPageCount()}`);
  
  const page = pdfDoc.getPage(0);
  const { width, height } = page.getSize();
  console.log(`   First page size: ${width}x${height}`);
  
  console.log('✅ Success!');
};
run();

