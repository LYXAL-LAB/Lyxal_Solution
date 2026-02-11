import { EngineContext, OperatorRegistry } from '@lyxal/logic-shared';
import { corePlugin } from './packs.core.js';
import { utilsPlugin } from './packs.utils.js';
// backend-only packs to add below
import { httpPlugin } from './packs.http.js';
import { surrealPlugin } from './packs.surreal.js';
import { aiPlugin } from './packs.ai.js';
import { cryptoPlugin } from './packs.crypto.js';
import { schedulerPlugin } from './packs.scheduler.js';
import { cloudPlugin } from './packs.cloud.js';
import { dateInstancePlugin } from './packs.date.instance.js';
import { arrayInstancePlugin } from './packs.array.instance.js';


export class BackendLogicEngine {
public registry = new OperatorRegistry();
constructor() {
this.registry.registerPlugin(corePlugin);
this.registry.registerPlugin(utilsPlugin);
this.registry.registerPlugin(httpPlugin);
this.registry.registerPlugin(surrealPlugin);
this.registry.registerPlugin(aiPlugin);
this.registry.registerPlugin(cryptoPlugin);
this.registry.registerPlugin(schedulerPlugin);
this.registry.registerPlugin(cloudPlugin);
this.registry.registerPlugin(dateInstancePlugin);   // namespace: $date.instance.*
this.registry.registerPlugin(arrayInstancePlugin);  // namespace: $array.instance.*
}
run(op: string, params: any, ctx: EngineContext) {
const { fn } = this.registry.get(op);
const beCtx: EngineContext = { ...ctx, secure: false, engine: 'backend' };
return fn(params, beCtx);
}
}