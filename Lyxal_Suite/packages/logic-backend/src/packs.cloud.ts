import { createPlugin, OperatorError } from '@lyxal/logic-shared';


export const cloudPlugin = createPlugin('@lyxal/op-cloud', {
'$cloud.upload': { fn: async ({ path, data }, ctx) => { if (!ctx.adapters?.storage?.upload) throw new OperatorError('$cloud.upload', 'no storage adapter'); return ctx.adapters.storage.upload(path, data); }, meta: { name: '$cloud.upload', backendOnly: true } },
});