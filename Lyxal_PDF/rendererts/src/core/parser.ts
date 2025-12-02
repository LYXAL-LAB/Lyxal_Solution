import { BaseStream, Stream } from './stream';
import { Cmd, Dict, Name, Ref, EOF, isCmd, isName, XRef, isDict } from './primitives';
import { FlateStream } from './flate_stream';
import { Jbig2Stream } from './jbig2';
import { JpxStream } from './jpx';

// A '1' in this array means the character is white space. A '1' or
// '2' means the character ends a name or command.
const specialChars = new Uint8Array([
  1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, // 0x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 1x
  1, 0, 0, 0, 0, 2, 0, 0, 2, 2, 0, 0, 0, 0, 0, 2, // 2x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, // 3x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 4x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, // 5x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 6x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, // 7x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 8x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 9x
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // ax
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // bx
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // cx
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // dx
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // ex
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  // fx
]);

function toHexDigit(ch: number): number {
  if (ch >= 0x30 && ch <= 0x39) return ch & 0x0f;
  if ((ch >= 0x41 && ch <= 0x46) || (ch >= 0x61 && ch <= 0x66)) return (ch & 0x0f) + 9;
  return -1;
}

export class Lexer {
  stream: BaseStream;
  currentChar: number = -1;
  strBuf: string[] = [];

  constructor(stream: BaseStream) {
    this.stream = stream;
    this.nextChar();
  }

  nextChar() {
    return (this.currentChar = this.stream.getByte());
  }

  peekChar() {
    return this.stream.peekByte();
  }

  getNumber(): number {
    let ch = this.currentChar;
    let eNotation = false;
    let divideBy = 0;
    let sign = 1;

    if (ch === 0x2d) { // '-'
      sign = -1;
      ch = this.nextChar();
      if (ch === 0x2d) ch = this.nextChar();
    } else if (ch === 0x2b) { // '+'
      ch = this.nextChar();
    }

    if (ch === 0x0a || ch === 0x0d) { // LF CR
      do { ch = this.nextChar(); } while (ch === 0x0a || ch === 0x0d);
    }

    if (ch === 0x2e) { // '.'
      divideBy = 10;
      ch = this.nextChar();
    }

    if (ch < 0x30 || ch > 0x39) {
        return 0; 
    }

    let baseValue = ch - 0x30;
    let powerValue = 0;
    let powerValueSign = 1;

    while ((ch = this.nextChar()) >= 0) {
        if (ch >= 0x30 && ch <= 0x39) {
            const digit = ch - 0x30;
            if (eNotation) {
                powerValue = powerValue * 10 + digit;
            } else {
                if (divideBy !== 0) divideBy *= 10;
                baseValue = baseValue * 10 + digit;
            }
        } else if (ch === 0x2e) { // '.'
            if (divideBy === 0) divideBy = 1;
            else break;
        } else if (ch === 0x2d) { // '-'
             // Ignore minus in middle
        } else if (ch === 0x45 || ch === 0x65) { // 'E' 'e'
            ch = this.peekChar();
            if (ch === 0x2b || ch === 0x2d) {
                powerValueSign = ch === 0x2d ? -1 : 1;
                this.nextChar();
            } else if (ch < 0x30 || ch > 0x39) {
                break;
            }
            eNotation = true;
        } else {
            break;
        }
    }

    if (divideBy !== 0) baseValue /= divideBy;
    if (eNotation) baseValue *= Math.pow(10, powerValueSign * powerValue);
    return sign * baseValue;
  }

  getString(): string {
      let numParen = 1;
      const strBuf = this.strBuf;
      strBuf.length = 0;
      let ch = this.nextChar();
      
      while (true) {
          let charBuffered = false;
          switch (ch) {
              case -1: return strBuf.join("");
              case 0x28: numParen++; strBuf.push("("); break;
              case 0x29: 
                  numParen--;
                  if (numParen === 0) {
                      this.nextChar();
                      return strBuf.join("");
                  }
                  strBuf.push(")");
                  break;
              case 0x5c:
                  ch = this.nextChar();
                  switch (ch) {
                      case -1: return strBuf.join("");
                      case 0x6e: strBuf.push("\n"); break;
                      case 0x72: strBuf.push("\r"); break;
                      case 0x74: strBuf.push("\t"); break;
                      case 0x62: strBuf.push("\b"); break;
                      case 0x66: strBuf.push("\f"); break;
                      case 0x5c: case 0x28: case 0x29: strBuf.push(String.fromCharCode(ch)); break;
                      case 0x30: case 0x31: case 0x32: case 0x33:
                      case 0x34: case 0x35: case 0x36: case 0x37:
                          let x = ch & 0x0f;
                          ch = this.nextChar();
                          charBuffered = true;
                          if (ch >= 0x30 && ch <= 0x37) {
                              x = (x << 3) + (ch & 0x0f);
                              ch = this.nextChar();
                              if (ch >= 0x30 && ch <= 0x37) {
                                  charBuffered = false;
                                  x = (x << 3) + (ch & 0x0f);
                              }
                          }
                          strBuf.push(String.fromCharCode(x));
                          break;
                      case 0x0d: 
                          if (this.peekChar() === 0x0a) this.nextChar();
                          break;
                      case 0x0a: break;
                      default: strBuf.push(String.fromCharCode(ch)); break;
                  }
                  break;
              default:
                  strBuf.push(String.fromCharCode(ch));
          }
          if (!charBuffered) ch = this.nextChar();
      }
  }

  getName(): Name {
      const strBuf = this.strBuf;
      strBuf.length = 0;
      let ch = this.nextChar();
      while (ch >= 0 && !specialChars[ch]) {
          if (ch === 0x23) { // '#'
              ch = this.nextChar();
              const x1 = toHexDigit(ch);
              if (x1 !== -1) {
                  ch = this.nextChar();
                  const x2 = toHexDigit(ch);
                  if (x2 !== -1) {
                      strBuf.push(String.fromCharCode((x1 << 4) | x2));
                      ch = this.nextChar();
                      continue;
                  }
              }
              strBuf.push("#");
          } else {
              strBuf.push(String.fromCharCode(ch));
              ch = this.nextChar();
          }
      }
      return Name.get(strBuf.join(""));
  }
  
  getHexString(): string {
      const strBuf = this.strBuf;
      strBuf.length = 0;
      let ch = this.currentChar;
      let firstDigit = -1;
      
      while (true) {
          if (ch < 0 || ch === 0x3e) { this.nextChar(); break; }
          if (specialChars[ch] === 1) { ch = this.nextChar(); continue; }
          const digit = toHexDigit(ch);
          if (digit !== -1) {
              if (firstDigit === -1) firstDigit = digit;
              else {
                  strBuf.push(String.fromCharCode((firstDigit << 4) | digit));
                  firstDigit = -1;
              }
          }
          ch = this.nextChar();
      }
      if (firstDigit !== -1) strBuf.push(String.fromCharCode(firstDigit << 4));
      return strBuf.join("");
  }

  skipToNextLine() {
    let ch = this.currentChar;
    while (ch >= 0) {
      if (ch === 0x0d) { // CR
        ch = this.nextChar();
        if (ch === 0x0a) { // LF
          this.nextChar();
        }
        break;
      } else if (ch === 0x0a) { // LF
        this.nextChar();
        break;
      }
      ch = this.nextChar();
    }
  }

  getObj(): any {
      let ch = this.currentChar;
      while (true) {
          if (ch < 0) return EOF;
          if (ch === 0x25) { // '%'
              do { ch = this.nextChar(); } while (ch !== 0x0a && ch !== 0x0d && ch >= 0);
          } else if (specialChars[ch] === 1) { 
              ch = this.nextChar();
          } else {
              break;
          }
      }

      switch (ch) {
          case 0x30: case 0x31: case 0x32: case 0x33: case 0x34: 
          case 0x35: case 0x36: case 0x37: case 0x38: case 0x39: 
          case 0x2b: case 0x2d: case 0x2e: 
              return this.getNumber();
          case 0x28: return this.getString(); 
          case 0x2f: return this.getName(); 
          case 0x5b: this.nextChar(); return Cmd.get("[");
          case 0x5d: this.nextChar(); return Cmd.get("]");
          case 0x3c: 
              ch = this.nextChar();
              if (ch === 0x3c) { this.nextChar(); return Cmd.get("<<"); }
              return this.getHexString();
          case 0x3e: 
              ch = this.nextChar();
              if (ch === 0x3e) { this.nextChar(); return Cmd.get(">>"); }
              return Cmd.get(">");
          case 0x7b: this.nextChar(); return Cmd.get("{");
          case 0x7d: this.nextChar(); return Cmd.get("}");
          case 0x29: this.nextChar(); throw new Error("Illegal character: )");
      }

      let str = String.fromCharCode(ch);
      while ((ch = this.nextChar()) >= 0 && !specialChars[ch]) {
          str += String.fromCharCode(ch);
      }
      
      if (str === "true") return true;
      if (str === "false") return false;
      if (str === "null") return null;
      
      return Cmd.get(str);
  }
}

export class Parser {
    lexer: Lexer;
    xref: XRef | null;
    buf1: any = null;
    buf2: any = null;
    allowStreams: boolean;

    constructor(lexer: Lexer, xref: XRef | null = null, allowStreams: boolean = true) {
        this.lexer = lexer;
        this.xref = xref;
        this.allowStreams = allowStreams;
        this.refill();
    }

    refill() {
        this.buf1 = this.lexer.getObj();
        this.buf2 = this.lexer.getObj();
    }

    shift() {
        this.buf1 = this.buf2;
        this.buf2 = this.lexer.getObj();
    }

    makeStream(dict: Dict, cipherTransform: any = null): any {
        const lexer = this.lexer;
        let stream = lexer.stream;

        // Skip to start of stream data
        lexer.skipToNextLine();
        const startPos = stream.pos - 1;

        let length = dict.get("Length");
        if (typeof length !== 'number') {
            length = 0;
        }

        // Skip data
        stream.skip(length);
        lexer.nextChar(); 

        if (isCmd(this.buf2, "endstream")) {
            this.shift(); 
        } 
        this.shift(); 

        // Create raw stream
        let subStream = stream.makeSubStream(startPos, length, dict);
        
        if (cipherTransform) {
            subStream = cipherTransform.decryptStream(subStream);
        }

        // Apply filters
        subStream = this.filter(subStream, dict);
        
        return subStream;
    }

    filter(stream: BaseStream, dict: Dict): any {
        let filter = dict.get("Filter") || dict.get("F");
        let params = dict.get("DecodeParms") || dict.get("DP");

        if (isName(filter)) {
            return this.makeFilter(stream, (filter as Name).name, params);
        }
        return stream;
    }

    makeFilter(stream: BaseStream, name: string, params: any): any {
        if (name === "FlateDecode" || name === "Fl") {
            return new FlateStream(stream, stream.length, params);
        }
        if (name === "JBIG2Decode") {
            return new Jbig2Stream(stream instanceof Stream ? stream : new Stream(stream.getBytes(null)), params);
        }
        if (name === "JPXDecode") {
            return new JpxStream(stream instanceof Stream ? stream : new Stream(stream.getBytes(null)), params);
        }
        return stream;
    }

    getObj(cipherTransform: any = null): any {
        const buf1 = this.buf1;
        this.shift();

        if (buf1 instanceof Cmd) {
            switch (buf1.cmd) {
                case "[": // Array
                    const array: any[] = [];
                    while (!isCmd(this.buf1, "]") && this.buf1 !== EOF) {
                        array.push(this.getObj(cipherTransform));
                    }
                    if (this.buf1 === EOF) throw new Error("End of file inside array");
                    this.shift();
                    return array;
                case "<<": // Dict
                    const dict = new Dict(this.xref);
                    while (!isCmd(this.buf1, ">>") && this.buf1 !== EOF) {
                        if (!isName(this.buf1)) {
                            this.shift();
                            continue;
                        }
                        const key = (this.buf1 as Name).name;
                        this.shift();
                        if (this.buf1 === EOF) break;
                        dict.set(key, this.getObj(cipherTransform));
                    }
                    if (this.buf1 === EOF) throw new Error("End of file inside dict");
                    
                    if (isCmd(this.buf2, "stream") && this.allowStreams) {
                        return this.makeStream(dict, cipherTransform);
                    }
                    this.shift();
                    return dict;
                default:
                    return buf1;
            }
        }

        if (typeof buf1 === 'string') {
            if (cipherTransform) {
                return cipherTransform.decryptString(buf1);
            }
            return buf1;
        }

        if (Number.isInteger(buf1)) {
            if (Number.isInteger(this.buf1) && isCmd(this.buf2, "R")) {
                const ref = Ref.get(buf1, this.buf1);
                this.shift();
                this.shift();
                return ref;
            }
        }

        return buf1;
    }
}
