declare module '@lyxal-compression/compression' {
  export function deflate(input: Uint8Array | string, options?: any): Uint8Array;
  export function inflate(input: Uint8Array, options?: any): Uint8Array | string;
  // Add other exports as needed based on usage
  const pako: {
    deflate: typeof deflate;
    inflate: typeof inflate;
    [key: string]: any;
  };
  export default pako;
}

