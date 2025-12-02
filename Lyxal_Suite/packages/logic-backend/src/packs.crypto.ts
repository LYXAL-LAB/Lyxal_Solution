import { createPlugin, OperatorError } from '@lyxal/logic-shared';


export const cryptoPlugin = createPlugin('@lyxal/op-crypto', {
'$crypto.hash': { fn: async ({ input, algo }, ctx) => { if (!ctx.adapters?.crypto?.hash) throw new OperatorError('$crypto.hash', 'no crypto adapter'); return ctx.adapters.crypto.hash(input, algo); }, meta: { name: '$crypto.hash', backendOnly: true } },
});