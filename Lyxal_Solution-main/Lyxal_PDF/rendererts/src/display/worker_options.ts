
export class GlobalWorkerOptions {
    static _port: Worker | null = null;
    static _src: string = "";

    static get workerPort(): Worker | null {
        return this._port;
    }

    static set workerPort(val: Worker | null) {
        if (
            !(typeof Worker !== "undefined" && val instanceof Worker) &&
            val !== null
        ) {
            throw new Error("Invalid `workerPort` type.");
        }
        this._port = val;
    }

    static get workerSrc(): string {
        return this._src;
    }

    static set workerSrc(val: string) {
        if (typeof val !== "string") {
            throw new Error("Invalid `workerSrc` type.");
        }
        this._src = val;
    }
}

