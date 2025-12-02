import { OPS } from './ops';

export class OperatorList {
    fnArray: number[] = [];
    argsArray: any[] = [];

    addOp(fn: number, args: any[] = []) {
        this.fnArray.push(fn);
        this.argsArray.push(args);
    }

    get length() {
        return this.fnArray.length;
    }

    get totalLength() {
        return this.fnArray.length;
    }
}

