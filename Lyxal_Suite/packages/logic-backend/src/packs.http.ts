import { createPlugin, OperatorError } from '@lyxal/logic-shared';


export const httpPlugin = createPlugin('@lyxal/op-http', {
'$http.get': { fn: async ({ url, init }, ctx) => { if (!ctx.adapters?.http?.get) throw new OperatorError('$http.get', 'no http adapter'); return ctx.adapters.http.get(url, init); }, meta: { name: '$http.get', backendOnly: true } },
'$http.post': { fn: async ({ url, body, init }, ctx) => { if (!ctx.adapters?.http?.post) throw new OperatorError('$http.post', 'no http adapter'); return ctx.adapters.http.post(url, body, init); }, meta: { name: '$http.post', backendOnly: true } },
});