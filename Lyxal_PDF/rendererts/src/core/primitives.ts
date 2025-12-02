export const EOF = Symbol("EOF");
export const CIRCULAR_REF = Symbol("CIRCULAR_REF");

export class Name {
    name: string;
    private static cache = new Map<string, Name>();

    constructor(name: string) {
        this.name = name;
    }

    static get(name: string): Name {
        let obj = Name.cache.get(name);
        if (!obj) {
            obj = new Name(name);
            Name.cache.set(name, obj);
        }
        return obj;
    }
}

export class Cmd {
    cmd: string;
    private static cache = new Map<string, Cmd>();

    constructor(cmd: string) {
        this.cmd = cmd;
    }

    static get(cmd: string): Cmd {
        let obj = Cmd.cache.get(cmd);
        if (!obj) {
            obj = new Cmd(cmd);
            Cmd.cache.set(cmd, obj);
        }
        return obj;
    }
}

export class Ref {
    num: number;
    gen: number;
    private static cache = new Map<string, Ref>();

    constructor(num: number, gen: number) {
        this.num = num;
        this.gen = gen;
    }

    toString(): string {
        return this.gen === 0 ? `${this.num}R` : `${this.num}R${this.gen}`;
    }

    static get(num: number, gen: number): Ref {
        const key = gen === 0 ? `${num}R` : `${num}R${gen}`;
        let obj = Ref.cache.get(key);
        if (!obj) {
            obj = new Ref(num, gen);
            Ref.cache.set(key, obj);
        }
        return obj;
    }
}

// Minimal interface to break circular dependency
export interface XRef {
    fetch(ref: Ref, suppressEncryption?: boolean): any;
    fetchAsync(ref: Ref, suppressEncryption?: boolean): Promise<any>;
}

export class Dict {
    private map = new Map<string, any>();
    public xref: XRef | null = null;
    public objId: string | null = null;
    public suppressEncryption = false;

    constructor(xref: XRef | null = null) {
        this.xref = xref;
    }

    assignXref(newXref: XRef) {
        this.xref = newXref;
    }

    get size() {
        return this.map.size;
    }

    get(key1: string, key2?: string, key3?: string): any {
        let value = this.map.get(key1);
        if (value === undefined && key2 !== undefined) {
            value = this.map.get(key2);
            if (value === undefined && key3 !== undefined) {
                value = this.map.get(key3);
            }
        }
        if (value instanceof Ref && this.xref) {
            return this.xref.fetch(value, this.suppressEncryption);
        }
        return value;
    }

    async getAsync(key1: string, key2?: string, key3?: string): Promise<any> {
        let value = this.map.get(key1);
        if (value === undefined && key2 !== undefined) {
            value = this.map.get(key2);
            if (value === undefined && key3 !== undefined) {
                value = this.map.get(key3);
            }
        }
        if (value instanceof Ref && this.xref) {
            return this.xref.fetchAsync(value, this.suppressEncryption);
        }
        return value;
    }

    getArray(key1: string, key2?: string, key3?: string): any {
        let value = this.get(key1, key2, key3);
        
        if (Array.isArray(value)) {
            value = value.slice(); // Clone
            for (let i = 0; i < value.length; i++) {
                if (value[i] instanceof Ref && this.xref) {
                    value[i] = this.xref.fetch(value[i], this.suppressEncryption);
                }
            }
        }
        return value;
    }

    getRaw(key: string): any {
        return this.map.get(key);
    }

    getKeys(): string[] {
        return Array.from(this.map.keys());
    }

    getRawValues(): any[] {
        return Array.from(this.map.values());
    }

    set(key: string, value: any) {
        this.map.set(key, value);
    }

    has(key: string): boolean {
        return this.map.has(key);
    }

    forEach(callback: (value: any, key: string) => void) {
        this.map.forEach(callback);
    }
}

export function isName(v: any, name?: string): boolean {
    return v instanceof Name && (name === undefined || v.name === name);
}

export function isCmd(v: any, cmd?: string): boolean {
    return v instanceof Cmd && (cmd === undefined || v.cmd === cmd);
}

export function isDict(v: any, type?: string): boolean {
    return v instanceof Dict && (type === undefined || isName(v.get("Type"), type));
}

export function isRef(v: any): boolean {
    return v instanceof Ref;
}

