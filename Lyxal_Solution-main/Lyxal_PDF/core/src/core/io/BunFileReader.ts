import { RandomAccessReader } from './RandomAccessReader';

// Declare Bun global for TypeScript if not available
declare const Bun: any;

export class BunFileReader implements RandomAccessReader {
  private readonly file: any; // BunFile
  private readonly size: number;

  constructor(filePath: string) {
    this.file = Bun.file(filePath);
    this.size = this.file.size;
  }

  async read(position: number, length: number): Promise<Uint8Array> {
    const end = position + length;
    // Bun.file().slice(start, end) returns a Blob-like object
    const slice = this.file.slice(position, end);
    // Convert to ArrayBuffer then Uint8Array
    const arrayBuffer = await slice.arrayBuffer();
    return new Uint8Array(arrayBuffer);
  }

  getSize(): number {
    return this.size;
  }
}

