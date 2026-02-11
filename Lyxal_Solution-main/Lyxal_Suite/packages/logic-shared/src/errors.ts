export class OperatorError extends Error {
    constructor(public op: string, message: string) {
    super(`Operator Error: ${op} — ${message}`);
    }
    }