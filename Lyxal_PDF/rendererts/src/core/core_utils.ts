/* Copyright 2019 Mozilla Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  AnnotationEditorPrefix,
  assert,
  BaseException,
  hexNumbers,
  objectSize,
  stringToPDFString,
  Util,
  warn,
  // @ts-ignore
} from "../shared/util.js";
import { Dict, isName, Ref, RefSet } from "./primitives";
import { BaseStream } from "./base_stream";

declare const PDFJSDev: any;

const PDF_VERSION_REGEXP = /^[1-9]\.\d$/;
const MAX_INT_32 = 2 ** 31 - 1;
const MIN_INT_32 = -(2 ** 31);

const IDENTITY_MATRIX = [1, 0, 0, 1, 0, 0];

const RESOURCES_KEYS_OPERATOR_LIST = [
  "ColorSpace",
  "ExtGState",
  "Font",
  "Pattern",
  "Properties",
  "Shading",
  "XObject",
  "Action",
];

const RESOURCES_KEYS_TEXT_CONTENT = [
  "ExtGState",
  "Font",
  "Properties",
  "XObject",
];

function getLookupTableFactory(initializer: any) {
  let lookup: any;
  return function () {
    if (initializer) {
      lookup = Object.create(null);
      initializer(lookup);
      initializer = null;
    }
    return lookup;
  };
}

class MissingDataException extends BaseException {
  begin: number;
  end: number;

  constructor(begin: number, end: number) {
    super(`Missing data [${begin}, ${end})`, "MissingDataException");
    this.begin = begin;
    this.end = end;
  }
}

class ParserEOFException extends BaseException {
  constructor(msg: string) {
    super(msg, "ParserEOFException");
  }
}

class XRefEntryException extends BaseException {
  constructor(msg: string) {
    super(msg, "XRefEntryException");
  }
}

class XRefParseException extends BaseException {
  constructor(msg: string) {
    super(msg, "XRefParseException");
  }
}

/**
 * Combines multiple ArrayBuffers into a single Uint8Array.
 * @param {Array<ArrayBuffer>} arr - An array of ArrayBuffers.
 * @returns {Uint8Array}
 */
function arrayBuffersToBytes(arr: ArrayBuffer[]): Uint8Array {
  if (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) {
    for (const item of arr) {
      assert(
        item instanceof ArrayBuffer,
        "arrayBuffersToBytes - expected an ArrayBuffer."
      );
    }
  }
  const length = arr.length;
  if (length === 0) {
    return new Uint8Array(0);
  }
  if (length === 1) {
    return new Uint8Array(arr[0]);
  }
  let dataLength = 0;
  for (let i = 0; i < length; i++) {
    dataLength += arr[i].byteLength;
  }
  const data = new Uint8Array(dataLength);
  let pos = 0;
  for (let i = 0; i < length; i++) {
    const item = new Uint8Array(arr[i]);
    data.set(item, pos);
    pos += item.byteLength;
  }
  return data;
}

async function fetchBinaryData(url: string): Promise<Uint8Array> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(
      `Failed to fetch file "${url}" with "${response.statusText}".`
    );
  }
  return new Uint8Array(await response.arrayBuffer());
}

/**
 * Get the value of an inheritable property.
 */
function getInheritableProperty({
  dict,
  key,
  getArray = false,
  stopWhenFound = true,
}: {
  dict: Dict;
  key: string;
  getArray?: boolean;
  stopWhenFound?: boolean;
}): any {
  let values: any[] | undefined;
  const visited = new RefSet();

  while (dict instanceof Dict && !(dict.objId && visited.has(dict.objId))) {
    if (dict.objId) {
      visited.put(dict.objId);
    }
    const value = getArray ? dict.getArray(key) : dict.get(key);
    if (value !== undefined) {
      if (stopWhenFound) {
        return value;
      }
      (values ||= []).push(value);
    }
    dict = dict.get("Parent");
  }
  return values;
}

/**
 * Get the parent dictionary to update when a property is set.
 */
function getParentToUpdate(dict: Dict, ref: Ref, xref: any): { dict: Dict | null, ref: Ref | null } {
  const visited = new RefSet();
  const firstDict = dict;
  const result = { dict: null, ref: null };

  while (dict instanceof Dict && !visited.has(ref)) {
    visited.put(ref);
    if (dict.has("T")) {
      break;
    }
    ref = dict.getRaw("Parent");
    if (!(ref instanceof Ref)) {
      return result;
    }
    dict = xref.fetch(ref);
  }
  if (dict instanceof Dict && dict !== firstDict) {
    // @ts-ignore
    result.dict = dict;
    // @ts-ignore
    result.ref = ref;
  }
  // @ts-ignore
  return result;
}

// prettier-ignore
const ROMAN_NUMBER_MAP = [
  "", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM",
  "", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC",
  "", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"
];

function toRomanNumerals(number: number, lowerCase = false): string {
  assert(
    Number.isInteger(number) && number > 0,
    "The number should be a positive integer."
  );

  const roman =
    "M".repeat((number / 1000) | 0) +
    ROMAN_NUMBER_MAP[((number % 1000) / 100) | 0] +
    ROMAN_NUMBER_MAP[10 + (((number % 100) / 10) | 0)] +
    ROMAN_NUMBER_MAP[20 + (number % 10)];
  return lowerCase ? roman.toLowerCase() : roman;
}

function log2(x: number): number {
  return x > 0 ? Math.ceil(Math.log2(x)) : 0;
}

function readInt8(data: Uint8Array, offset: number): number {
  return (data[offset] << 24) >> 24;
}

function readInt16(data: Uint8Array, offset: number): number {
  return ((data[offset] << 24) | (data[offset + 1] << 16)) >> 16;
}

function readUint16(data: Uint8Array, offset: number): number {
  return (data[offset] << 8) | data[offset + 1];
}

function readUint32(data: Uint8Array, offset: number): number {
  return (
    ((data[offset] << 24) |
      (data[offset + 1] << 16) |
      (data[offset + 2] << 8) |
      data[offset + 3]) >>>
    0
  );
}

function isWhiteSpace(ch: number): boolean {
  return ch === 0x20 || ch === 0x09 || ch === 0x0d || ch === 0x0a;
}

function isBooleanArray(arr: any, len: number | null): boolean {
  return (
    Array.isArray(arr) &&
    (len === null || arr.length === len) &&
    arr.every(x => typeof x === "boolean")
  );
}

function isNumberArray(arr: any, len: number | null): boolean {
  if (Array.isArray(arr)) {
    return (
      (len === null || arr.length === len) &&
      arr.every(x => typeof x === "number")
    );
  }

  return (
    ArrayBuffer.isView(arr) &&
    !(arr instanceof BigInt64Array || arr instanceof BigUint64Array) &&
    (len === null || arr.length === len)
  );
}

function lookupMatrix(arr: any, fallback: any): any {
  return isNumberArray(arr, 6) ? arr : fallback;
}

function lookupRect(arr: any, fallback: any): any {
  return isNumberArray(arr, 4) ? arr : fallback;
}

function lookupNormalRect(arr: any, fallback: any): any {
  return isNumberArray(arr, 4) ? Util.normalizeRect(arr) : fallback;
}

function parseXFAPath(path: string): { name: string, pos: number }[] {
  const positionPattern = /(.+)\[(\d+)\]$/;
  return path.split(".").map(component => {
    const m = component.match(positionPattern);
    if (m) {
      return { name: m[1], pos: parseInt(m[2], 10) };
    }
    return { name: component, pos: 0 };
  });
}

function escapePDFName(str: string): string {
  const buffer = [];
  let start = 0;
  for (let i = 0, ii = str.length; i < ii; i++) {
    const char = str.charCodeAt(i);
    if (
      char < 0x21 ||
      char > 0x7e ||
      char === 0x23 /* # */ ||
      char === 0x28 /* ( */ ||
      char === 0x29 /* ) */ ||
      char === 0x3c /* < */ ||
      char === 0x3e /* > */ ||
      char === 0x5b /* [ */ ||
      char === 0x5d /* ] */ ||
      char === 0x7b /* { */ ||
      char === 0x7d /* } */ ||
      char === 0x2f /* / */ ||
      char === 0x25 /* % */
    ) {
      if (start < i) {
        buffer.push(str.substring(start, i));
      }
      buffer.push(`#${char.toString(16)}`);
      start = i + 1;
    }
  }

  if (buffer.length === 0) {
    return str;
  }

  if (start < str.length) {
    buffer.push(str.substring(start, str.length));
  }

  return buffer.join("");
}

function escapeString(str: string): string {
  return str.replaceAll(/([()\\\n\r])/g, match => {
    if (match === "\n") {
      return "\\n";
    } else if (match === "\r") {
      return "\\r";
    }
    return `\\${match}`;
  });
}

function _collectJS(entry: any, xref: any, list: string[], parents: RefSet) {
  if (!entry) {
    return;
  }

  let parent = null;
  if (entry instanceof Ref) {
    if (parents.has(entry)) {
      return;
    }
    parent = entry;
    parents.put(parent);
    entry = xref.fetch(entry);
  }
  if (Array.isArray(entry)) {
    for (const element of entry) {
      _collectJS(element, xref, list, parents);
    }
  } else if (entry instanceof Dict) {
    if (isName(entry.get("S"), "JavaScript")) {
      const js = entry.get("JS");
      let code;
      if (js instanceof BaseStream) {
        code = js.getString();
      } else if (typeof js === "string") {
        code = js;
      }
      code &&= stringToPDFString(
        code
      ).replaceAll("\x00", "");
      if (code) {
        list.push(code.trim());
      }
    }
    _collectJS(entry.getRaw("Next"), xref, list, parents);
  }

  if (parent) {
    parents.remove(parent);
  }
}

function collectActions(xref: any, dict: Dict, eventType: any): any {
  const actions: any = Object.create(null);
  const additionalActionsDicts = getInheritableProperty({
    dict,
    key: "AA",
    stopWhenFound: false,
  });
  if (additionalActionsDicts) {
    for (let i = additionalActionsDicts.length - 1; i >= 0; i--) {
      const additionalActions = additionalActionsDicts[i];
      if (!(additionalActions instanceof Dict)) {
        continue;
      }
      for (const key of additionalActions.getKeys()) {
        const action = eventType[key];
        if (!action) {
          continue;
        }
        const actionDict = additionalActions.getRaw(key);
        const parents = new RefSet();
        const list: string[] = [];
        _collectJS(actionDict, xref, list, parents);
        if (list.length > 0) {
          actions[action] = list;
        }
      }
    }
  }
  if (dict.has("A")) {
    const actionDict = dict.get("A");
    const parents = new RefSet();
    const list: string[] = [];
    _collectJS(actionDict, xref, list, parents);
    if (list.length > 0) {
      actions.Action = list;
    }
  }
  return objectSize(actions) > 0 ? actions : null;
}

const XMLEntities: Record<number, string> = {
  0x3c: "&lt;",
  0x3e: "&gt;",
  0x26: "&amp;",
  0x22: "&quot;",
  0x27: "&apos;",
};

function* codePointIter(str: string) {
  for (let i = 0, ii = str.length; i < ii; i++) {
    const char = str.codePointAt(i);
    if (char && char > 0xd7ff && (char < 0xe000 || char > 0xfffd)) {
      i++;
    }
    yield char;
  }
}

function encodeToXmlString(str: string): string {
  const buffer = [];
  let start = 0;
  for (let i = 0, ii = str.length; i < ii; i++) {
    const char = str.codePointAt(i);
    if (char && 0x20 <= char && char <= 0x7e) {
      const entity = XMLEntities[char];
      if (entity) {
        if (start < i) {
          buffer.push(str.substring(start, i));
        }
        buffer.push(entity);
        start = i + 1;
      }
    } else {
      if (start < i) {
        buffer.push(str.substring(start, i));
      }
      buffer.push(`&#x${char!.toString(16).toUpperCase()};`);
      if (char! > 0xd7ff && (char! < 0xe000 || char! > 0xfffd)) {
        i++;
      }
      start = i + 1;
    }
  }

  if (buffer.length === 0) {
    return str;
  }
  if (start < str.length) {
    buffer.push(str.substring(start, str.length));
  }
  return buffer.join("");
}

function validateFontName(fontFamily: string, mustWarn = false): boolean {
  const m = /^("|').*("|')$/.exec(fontFamily);
  if (m && m[1] === m[2]) {
    const re = new RegExp(`[^\\\\]${m[1]}`);
    if (re.test(fontFamily.slice(1, -1))) {
      if (mustWarn) {
        warn(`FontFamily contains unescaped ${m[1]}: ${fontFamily}.`);
      }
      return false;
    }
  } else {
    for (const ident of fontFamily.split(/[ \t]+/)) {
      if (/^(\d|(-(\d|-)))/.test(ident) || !/^[\w-\\]+$/.test(ident)) {
        if (mustWarn) {
          warn(`FontFamily contains invalid <custom-ident>: ${fontFamily}.`);
        }
        return false;
      }
    }
  }
  return true;
}

function validateCSSFont(cssFontInfo: any): boolean {
  const DEFAULT_CSS_FONT_OBLIQUE = "14";
  const DEFAULT_CSS_FONT_WEIGHT = "400";
  const CSS_FONT_WEIGHT_VALUES = new Set([
    "100",
    "200",
    "300",
    "400",
    "500",
    "600",
    "700",
    "800",
    "900",
    "1000",
    "normal",
    "bold",
    "bolder",
    "lighter",
  ]);

  const { fontFamily, fontWeight, italicAngle } = cssFontInfo;

  if (!validateFontName(fontFamily, true)) {
    return false;
  }

  const weight = fontWeight ? fontWeight.toString() : "";
  cssFontInfo.fontWeight = CSS_FONT_WEIGHT_VALUES.has(weight)
    ? weight
    : DEFAULT_CSS_FONT_WEIGHT;

  const angle = parseFloat(italicAngle);
  cssFontInfo.italicAngle =
    isNaN(angle) || angle < -90 || angle > 90
      ? DEFAULT_CSS_FONT_OBLIQUE
      : italicAngle.toString();

  return true;
}

function recoverJsURL(str: string): { url: string, newWindow: boolean } | null {
  const URL_OPEN_METHODS = ["app.launchURL", "window.open", "xfa.host.gotoURL"];
  const regex = new RegExp(
    "^\\s*(" +
      URL_OPEN_METHODS.join("|").replaceAll(".", "\\.") +
      ")\\((?:'|\")([^'\"]*)(?:'|\")(?:,\\s*(\\w+)\\)|\\))",
    "i"
  );

  const jsUrl = regex.exec(str);
  if (jsUrl?.[2]) {
    return {
      url: jsUrl[2],
      newWindow: jsUrl[1] === "app.launchURL" && jsUrl[3] === "true",
    };
  }

  return null;
}

function numberToString(value: number): string {
  if (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) {
    assert(
      typeof value === "number",
      `numberToString - the value (${value}) should be a number.`
    );
  }

  if (Number.isInteger(value)) {
    return value.toString();
  }

  const roundedValue = Math.round(value * 100);
  if (roundedValue % 100 === 0) {
    return (roundedValue / 100).toString();
  }

  if (roundedValue % 10 === 0) {
    return value.toFixed(1);
  }

  return value.toFixed(2);
}

function getNewAnnotationsMap(annotationStorage: Map<string, any>): Map<number, any[]> | null {
  if (!annotationStorage) {
    return null;
  }
  const newAnnotationsByPage = new Map();
  for (const [key, value] of annotationStorage) {
    if (!key.startsWith(AnnotationEditorPrefix)) {
      continue;
    }
    let annotations = newAnnotationsByPage.get(value.pageIndex);
    if (!annotations) {
      annotations = [];
      newAnnotationsByPage.set(value.pageIndex, annotations);
    }
    annotations.push(value);
  }
  return newAnnotationsByPage.size > 0 ? newAnnotationsByPage : null;
}

function stringToAsciiOrUTF16BE(str: string): string {
  if (str === null || str === undefined) {
    return str;
  }
  return isAscii(str) ? str : stringToUTF16String(str, true);
}

function isAscii(str: string): boolean {
  if (typeof str !== "string") {
    return false;
  }
  return !str || /^[\x00-\x7F]*$/.test(str);
}

function stringToUTF16HexString(str: string): string {
  const buf = [];
  for (let i = 0, ii = str.length; i < ii; i++) {
    const char = str.charCodeAt(i);
    buf.push(hexNumbers[(char >> 8) & 0xff], hexNumbers[char & 0xff]);
  }
  return buf.join("");
}

function stringToUTF16String(str: string, bigEndian = false): string {
  const buf = [];
  if (bigEndian) {
    buf.push("\xFE\xFF");
  }
  for (let i = 0, ii = str.length; i < ii; i++) {
    const char = str.charCodeAt(i);
    buf.push(
      String.fromCharCode((char >> 8) & 0xff),
      String.fromCharCode(char & 0xff)
    );
  }
  return buf.join("");
}

function getRotationMatrix(rotation: number, width: number, height: number): number[] {
  switch (rotation) {
    case 90:
      return [0, 1, -1, 0, width, 0];
    case 180:
      return [-1, 0, 0, -1, width, height];
    case 270:
      return [0, -1, 1, 0, 0, height];
    default:
      throw new Error("Invalid rotation");
  }
}

function getSizeInBytes(x: number): number {
  return Math.ceil(Math.ceil(Math.log2(1 + x)) / 8);
}

export {
  arrayBuffersToBytes,
  codePointIter,
  collectActions,
  encodeToXmlString,
  escapePDFName,
  escapeString,
  fetchBinaryData,
  getInheritableProperty,
  getLookupTableFactory,
  getNewAnnotationsMap,
  getParentToUpdate,
  getRotationMatrix,
  getSizeInBytes,
  IDENTITY_MATRIX,
  isAscii,
  isBooleanArray,
  isNumberArray,
  isWhiteSpace,
  log2,
  lookupMatrix,
  lookupNormalRect,
  lookupRect,
  MAX_INT_32,
  MIN_INT_32,
  MissingDataException,
  numberToString,
  ParserEOFException,
  parseXFAPath,
  PDF_VERSION_REGEXP,
  readInt16,
  readInt8,
  readUint16,
  readUint32,
  recoverJsURL,
  RESOURCES_KEYS_OPERATOR_LIST,
  RESOURCES_KEYS_TEXT_CONTENT,
  stringToAsciiOrUTF16BE,
  stringToUTF16HexString,
  stringToUTF16String,
  toRomanNumerals,
  validateCSSFont,
  validateFontName,
  XRefEntryException,
  XRefParseException,
};
