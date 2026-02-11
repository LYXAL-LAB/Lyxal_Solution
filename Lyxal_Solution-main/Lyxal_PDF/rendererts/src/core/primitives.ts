/* Copyright 2012 Mozilla Foundation
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

import { assert, shadow, unreachable } from "../shared/util";

declare const PDFJSDev: any;

export const CIRCULAR_REF = Symbol("CIRCULAR_REF");
export const EOF = Symbol("EOF");

let CmdCache: Record<string, Cmd> = Object.create(null);
let NameCache: Record<string, Name> = Object.create(null);
let RefCache: Record<string, Ref> = Object.create(null);

export function clearPrimitiveCaches(): void {
  CmdCache = Object.create(null);
  NameCache = Object.create(null);
  RefCache = Object.create(null);
}

export class Name {
  name: string;

  constructor(name: string) {
    if (
      (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
      typeof name !== "string"
    ) {
      unreachable('Name: The "name" must be a string.');
    }
    this.name = name;
  }

  static get(name: string): Name {
    // eslint-disable-next-line no-restricted-syntax
    return (NameCache[name] ||= new Name(name));
  }
}

export class Cmd {
  cmd: string;

  constructor(cmd: string) {
    if (
      (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
      typeof cmd !== "string"
    ) {
      unreachable('Cmd: The "cmd" must be a string.');
    }
    this.cmd = cmd;
  }

  static get(cmd: string): Cmd {
    // eslint-disable-next-line no-restricted-syntax
    return (CmdCache[cmd] ||= new Cmd(cmd));
  }
}

const nonSerializable = function nonSerializableClosure() {
  return nonSerializable; // Creating closure on some variable.
};

// Define a minimal interface for XRef to avoid circular dependency issues during porting
interface XRefLike {
  fetch(ref: Ref, suppressEncryption?: boolean): any;
  fetchAsync(ref: Ref, suppressEncryption?: boolean): Promise<any>;
}

export class Dict {
  _map: Map<string, any>;
  xref: XRefLike | null;
  objId: string | null;
  suppressEncryption: boolean;
  __nonSerializable__: typeof nonSerializable;

  constructor(xref: XRefLike | null = null) {
    // Map should only be used internally, use functions below to access.
    this._map = new Map();
    this.xref = xref;
    this.objId = null;
    this.suppressEncryption = false;
    this.__nonSerializable__ = nonSerializable; // Disable cloning of the Dict.
  }

  assignXref(newXref: XRefLike | null): void {
    this.xref = newXref;
  }

  get size(): number {
    return this._map.size;
  }

  // Automatically dereferences Ref objects.
  get(key1: string, key2?: string, key3?: string): any {
    let value = this._map.get(key1);
    if (value === undefined && key2 !== undefined) {
      if (
        (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
        key2.length < key1.length
      ) {
        unreachable("Dict.get: Expected keys to be ordered by length.");
      }
      value = this._map.get(key2);
      if (value === undefined && key3 !== undefined) {
        if (
          (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
          key3.length < key2.length
        ) {
          unreachable("Dict.get: Expected keys to be ordered by length.");
        }
        value = this._map.get(key3);
      }
    }
    if (value instanceof Ref && this.xref) {
      return this.xref.fetch(value, this.suppressEncryption);
    }
    return value;
  }

  // Same as get(), but returns a promise and uses fetchIfRefAsync().
  async getAsync(key1: string, key2?: string, key3?: string): Promise<any> {
    let value = this._map.get(key1);
    if (value === undefined && key2 !== undefined) {
      if (
        (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
        key2.length < key1.length
      ) {
        unreachable("Dict.getAsync: Expected keys to be ordered by length.");
      }
      value = this._map.get(key2);
      if (value === undefined && key3 !== undefined) {
        if (
          (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
          key3.length < key2.length
        ) {
          unreachable("Dict.getAsync: Expected keys to be ordered by length.");
        }
        value = this._map.get(key3);
      }
    }
    if (value instanceof Ref && this.xref) {
      return this.xref.fetchAsync(value, this.suppressEncryption);
    }
    return value;
  }

  // Same as get(), but dereferences all elements if the result is an Array.
  getArray(key1: string, key2?: string, key3?: string): any {
    let value = this._map.get(key1);
    if (value === undefined && key2 !== undefined) {
      if (
        (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
        key2.length < key1.length
      ) {
        unreachable("Dict.getArray: Expected keys to be ordered by length.");
      }
      value = this._map.get(key2);
      if (value === undefined && key3 !== undefined) {
        if (
          (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
          key3.length < key2.length
        ) {
          unreachable("Dict.getArray: Expected keys to be ordered by length.");
        }
        value = this._map.get(key3);
      }
    }
    if (value instanceof Ref && this.xref) {
      value = this.xref.fetch(value, this.suppressEncryption);
    }

    if (Array.isArray(value)) {
      value = value.slice(); // Ensure that we don't modify the Dict data.
      for (let i = 0, ii = value.length; i < ii; i++) {
        if (value[i] instanceof Ref && this.xref) {
          value[i] = this.xref.fetch(value[i], this.suppressEncryption);
        }
      }
    }
    return value;
  }

  // No dereferencing.
  getRaw(key: string): any {
    return this._map.get(key);
  }

  getKeys(): string[] {
    return [...this._map.keys()];
  }

  // No dereferencing.
  getRawValues(): any[] {
    return [...this._map.values()];
  }

  getRawEntries(): IterableIterator<[string, any]> {
    return this._map.entries();
  }

  set(key: string, value: any): void {
    if (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) {
      if (typeof key !== "string") {
        unreachable('Dict.set: The "key" must be a string.');
      } else if (value === undefined) {
        unreachable('Dict.set: The "value" cannot be undefined.');
      }
    }
    this._map.set(key, value);
  }

  setIfNotExists(key: string, value: any): void {
    if (!this.has(key)) {
      this.set(key, value);
    }
  }

  setIfNumber(key: string, value: any): void {
    if (typeof value === "number") {
      this.set(key, value);
    }
  }

  setIfArray(key: string, value: any): void {
    if (Array.isArray(value) || ArrayBuffer.isView(value)) {
      this.set(key, value);
    }
  }

  setIfDefined(key: string, value: any): void {
    if (value !== undefined && value !== null) {
      this.set(key, value);
    }
  }

  setIfName(key: string, value: any): void {
    if (typeof value === "string") {
      this.set(key, Name.get(value));
    } else if (value instanceof Name) {
      this.set(key, value);
    }
  }

  setIfDict(key: string, value: any): void {
    if (value instanceof Dict) {
      this.set(key, value);
    }
  }

  has(key: string): boolean {
    return this._map.has(key);
  }

  *[Symbol.iterator](): IterableIterator<[string, any]> {
    for (const [key, value] of this._map) {
      yield [
        key,
        value instanceof Ref && this.xref
          ? this.xref.fetch(value, this.suppressEncryption)
          : value,
      ];
    }
  }

  static get empty(): Dict {
    const emptyDict = new Dict(null);

    emptyDict.set = (key: string, value: any) => {
      unreachable("Should not call `set` on the empty dictionary.");
    };
    return shadow(this, "empty", emptyDict);
  }

  static merge({ xref, dictArray, mergeSubDicts = false }: { xref: XRefLike | null, dictArray: any[], mergeSubDicts?: boolean }): Dict {
    const mergedDict = new Dict(xref),
      properties = new Map<string, any[]>();

    for (const dict of dictArray) {
      if (!(dict instanceof Dict)) {
        continue;
      }
      for (const [key, value] of dict._map) {
        let property = properties.get(key);
        if (property === undefined) {
          property = [];
          properties.set(key, property);
        } else if (!mergeSubDicts || !(value instanceof Dict)) {
          // Ignore additional entries, if either:
          //  - This is a "shallow" merge, where only the first element matters.
          //  - The value is *not* a `Dict`, since other types cannot be merged.
          continue;
        }
        property.push(value);
      }
    }
    for (const [name, values] of properties) {
      if (values.length === 1 || !(values[0] instanceof Dict)) {
        mergedDict._map.set(name, values[0]);
        continue;
      }
      const subDict = new Dict(xref);

      for (const dict of values) {
        for (const [key, value] of dict._map) {
          if (!subDict._map.has(key)) {
            subDict._map.set(key, value);
          }
        }
      }
      if (subDict.size > 0) {
        mergedDict._map.set(name, subDict);
      }
    }
    properties.clear();

    return mergedDict.size > 0 ? mergedDict : Dict.empty;
  }

  clone(): Dict {
    const dict = new Dict(this.xref);
    for (const key of this.getKeys()) {
      dict.set(key, this.getRaw(key));
    }
    return dict;
  }

  delete(key: string): void {
    this._map.delete(key);
  }
}

export class Ref {
  num: number;
  gen: number;

  constructor(num: number, gen: number) {
    this.num = num;
    this.gen = gen;
  }

  toString(): string {
    // This function is hot, so we make the string as compact as possible.
    // |this.gen| is almost always zero, so we treat that case specially.
    if (this.gen === 0) {
      return `${this.num}R`;
    }
    return `${this.num}R${this.gen}`;
  }

  static fromString(str: string): Ref | null {
    const ref = RefCache[str];
    if (ref) {
      return ref;
    }
    const m = /^(\d+)R(\d*)$/.exec(str);
    if (!m || m[1] === "0") {
      return null;
    }

    // eslint-disable-next-line no-restricted-syntax
    return (RefCache[str] = new Ref(
      parseInt(m[1]),
      !m[2] ? 0 : parseInt(m[2])
    ));
  }

  static get(num: number, gen: number): Ref {
    const key = gen === 0 ? `${num}R` : `${num}R${gen}`;
    // eslint-disable-next-line no-restricted-syntax
    return (RefCache[key] ||= new Ref(num, gen));
  }
}

// The reference is identified by number and generation.
// This structure stores only one instance of the reference.
export class RefSet {
  _set: Set<string>;

  constructor(parent: RefSet | null = null) {
    if (
      (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) &&
      parent &&
      !(parent instanceof RefSet)
    ) {
      unreachable('RefSet: Invalid "parent" value.');
    }
    this._set = new Set(parent?._set);
  }

  has(ref: Ref): boolean {
    return this._set.has(ref.toString());
  }

  put(ref: Ref): void {
    this._set.add(ref.toString());
  }

  remove(ref: Ref): void {
    this._set.delete(ref.toString());
  }

  [Symbol.iterator](): IterableIterator<string> {
    return this._set.values();
  }

  clear(): void {
    this._set.clear();
  }
}

export class RefSetCache {
  _map: Map<string, any>;

  constructor() {
    this._map = new Map();
  }

  get size(): number {
    return this._map.size;
  }

  get(ref: Ref): any {
    return this._map.get(ref.toString());
  }

  has(ref: Ref): boolean {
    return this._map.has(ref.toString());
  }

  put(ref: Ref, obj: any): void {
    this._map.set(ref.toString(), obj);
  }

  putAlias(ref: Ref, aliasRef: Ref): void {
    this._map.set(ref.toString(), this.get(aliasRef));
  }

  [Symbol.iterator](): IterableIterator<any> {
    return this._map.values();
  }

  clear(): void {
    this._map.clear();
  }

  *values(): IterableIterator<any> {
    yield* this._map.values();
  }

  *items(): IterableIterator<[Ref | null, any]> {
    for (const [ref, value] of this._map) {
      yield [Ref.fromString(ref), value];
    }
  }

  *keys(): IterableIterator<Ref | null> {
    for (const ref of this._map.keys()) {
      yield Ref.fromString(ref);
    }
  }
}

export function isName(v: any, name?: string): boolean {
  return v instanceof Name && (name === undefined || v.name === name);
}

export function isCmd(v: any, cmd?: string): boolean {
  return v instanceof Cmd && (cmd === undefined || v.cmd === cmd);
}

export function isDict(v: any, type?: string): boolean {
  return (
    v instanceof Dict && (type === undefined || isName(v.get("Type"), type))
  );
}

export function isRefsEqual(v1: any, v2: any): boolean {
  if (typeof PDFJSDev === "undefined" || PDFJSDev.test("TESTING")) {
    assert(
      v1 instanceof Ref && v2 instanceof Ref,
      "isRefsEqual: Both parameters should be `Ref`s."
    );
  }
  return v1.num === v2.num && v1.gen === v2.gen;
}
