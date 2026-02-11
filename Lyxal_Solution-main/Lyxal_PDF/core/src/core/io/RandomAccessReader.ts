/**
 * Interface for reading data from a source that supports random access.
 * This allows parsing huge PDFs without loading them entirely into memory.
 */
export interface RandomAccessReader {
  /**
   * Reads a specific range of bytes.
   * @param position The offset from the start of the file.
   * @param length The number of bytes to read.
   * @returns The bytes read.
   */
  read(position: number, length: number): Promise<Uint8Array>;

  /**
   * Returns the total size of the file/resource in bytes.
   */
  getSize(): number;
}

/**
 * An implementation of RandomAccessReader that wraps a Uint8Array.
 * Useful for backward compatibility with in-memory loading.
 */
export class MemoryReader implements RandomAccessReader {
  private readonly data: Uint8Array;

  constructor(data: Uint8Array) {
    this.data = data;
  }

  async read(position: number, length: number): Promise<Uint8Array> {
    return this.data.subarray(position, position + length);
  }

  getSize(): number {
    return this.data.length;
  }
}

