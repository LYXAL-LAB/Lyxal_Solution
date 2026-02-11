
export class Metadata {
    private _map: Map<string, string>;
    private _data: string;

    constructor({ parsedData, rawData }: { parsedData: Map<string, string>, rawData: string }) {
        this._map = parsedData;
        this._data = rawData;
    }

    getRaw(): string {
        return this._data;
    }

    get(name: string): string | null {
        return this._map.get(name) ?? null;
    }

    has(name: string): boolean {
        return this._map.has(name);
    }

    [Symbol.iterator]() {
        return this._map.entries();
    }
}

