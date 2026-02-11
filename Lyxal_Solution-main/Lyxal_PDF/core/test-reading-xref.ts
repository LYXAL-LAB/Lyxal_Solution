import { BunFileReader } from './src/core/io/BunFileReader';
import { PDFObjectLoader } from './src/core/io/PDFObjectLoader';
import PDFRef from './src/core/objects/PDFRef';

const run = async () => {
  const filename = 'lyxal_xref_stream.pdf';
  
  try {
    const reader = new BunFileReader(filename);
    const loader = new PDFObjectLoader(reader);
    
    console.log('1️⃣ Finding StartXref...');
    const startXref = await loader.findStartXrefOffset();
    console.log(`   Offset: ${startXref}`);
    
    console.log('2️⃣ Parsing XRef Table (Expecting XRef Stream)...');
    await loader.readXrefTable();
    console.log('   ✅ XRef Table parsed');
    
    // Check if we can find an object
    // Object 1 is usually valid
    console.log('3️⃣ Loading Object 1 0 R...');
    const obj = await loader.loadObject(PDFRef.of(1, 0));
    console.log('   ✅ Loaded:', obj.constructor.name);
    console.log(obj.toString());
    
  } catch (err) {
    console.error('❌ Error:', err);
  }
};

run();

