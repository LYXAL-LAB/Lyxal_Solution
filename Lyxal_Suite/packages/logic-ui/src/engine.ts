import { EngineContext, OperatorRegistry } from '@lyxal/logic-shared';
import { corePlugin } from './packs.core.js';
import { mathPlugin } from './packs.math.js';
import { datePlugin } from './packs.date.js';
import { arrayPlugin } from './packs.array.js';
import { objectPlugin } from './packs.object.js';
import { utilsPlugin } from './packs.utils.js';
import { dateInstancePlugin } from './packs.date.instance.js';
import { arrayInstancePlugin } from './packs.array.instance.js';


export class UILogicEngine {
public registry = new OperatorRegistry();


constructor() {
// register built-in UI-safe plugins
this.registry.registerPlugin(corePlugin);
this.registry.registerPlugin(mathPlugin);
this.registry.registerPlugin(datePlugin);
this.registry.registerPlugin(arrayPlugin);
this.registry.registerPlugin(objectPlugin);
this.registry.registerPlugin(utilsPlugin);
this.registry.registerPlugin(dateInstancePlugin);   // namespace: $date.instance.*
this.registry.registerPlugin(arrayInstancePlugin);  // namespace: $array.instance.*
}


run(op: string, params: any, ctx: EngineContext) {
const { fn, meta } = this.registry.get(op);
if (meta?.backendOnly) throw new Error(`Operator ${op} not allowed in UI engine`);
const uiCtx: EngineContext = { ...ctx, secure: true, engine: 'ui' };
return fn(params, uiCtx);
}
}