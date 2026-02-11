import { Dict, OperatorFn, OperatorMeta, OperatorPlugin } from './types.js';
import { OperatorError } from './errors.js';


export class OperatorRegistry {
private map = new Map<string, { fn: OperatorFn; meta?: OperatorMeta }>();


register(op: string, fn: OperatorFn, meta?: OperatorMeta) {
if (!op.startsWith('$')) op = `$${op}`;
if (this.map.has(op)) throw new OperatorError(op, 'already registered');
this.map.set(op, { fn, meta });
}


registerPlugin(plugin: OperatorPlugin) {
Object.entries(plugin.operators).forEach(([name, def]) => {
this.register(name, def.fn, def.meta);
});
}


has(op: string) { return this.map.has(op); }
get(op: string) {
const def = this.map.get(op);
if (!def) throw new OperatorError(op, 'not registered');
return def;
}


list(): { name: string; meta?: OperatorMeta }[] {
return Array.from(this.map.entries()).map(([name, { meta }]) => ({ name, meta }));
}
}