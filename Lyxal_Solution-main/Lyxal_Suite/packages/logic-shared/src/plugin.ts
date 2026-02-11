import { OperatorPlugin } from './types.js';


export function createPlugin(id: string, defs: OperatorPlugin['operators']): OperatorPlugin {
return { id, operators: defs };
}