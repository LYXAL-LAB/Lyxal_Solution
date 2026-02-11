import PDFDocument from 'src/api/PDFDocument';
import PDFStreamer, { WriterTarget } from 'src/core/writers/PDFStreamer';

export const saveToStream = async (
  pdfDoc: PDFDocument,
  target: WriterTarget,
  objectsPerTick = 50
): Promise<void> => {
  const streamer = PDFStreamer.forContext(pdfDoc.context, objectsPerTick);
  await streamer.serializeToTarget(target);
};

