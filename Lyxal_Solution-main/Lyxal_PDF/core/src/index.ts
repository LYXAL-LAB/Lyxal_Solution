export * from 'src/api/index';
export * from 'src/core/index';
export * from 'src/types/index';
export * from 'src/utils/index';

// Export Streamer extension
export * from 'src/api/PDFDocumentStreamer';
export type { WriterTarget } from 'src/core/writers/PDFStreamer';

// Export Loader extensions (Experimental)
export { PDFObjectLoader } from 'src/core/io/PDFObjectLoader';
export { BunFileReader } from 'src/core/io/BunFileReader';
export { RandomAccessReader } from 'src/core/io/RandomAccessReader';
