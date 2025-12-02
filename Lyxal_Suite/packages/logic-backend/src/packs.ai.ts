import { createPlugin, OperatorError } from '@lyxal/logic-shared';


export const aiPlugin = createPlugin('@lyxal/op-ai', {
'$ai.generate': { fn: async (input, ctx) => { if (!ctx.adapters?.ai?.generate) throw new OperatorError('$ai.generate', 'no ai adapter'); return ctx.adapters.ai.generate(input); }, meta: { name: '$ai.generate', backendOnly: true } },
'$ai.embed': { fn: async (input, ctx) => { if (!ctx.adapters?.ai?.embed) throw new OperatorError('$ai.embed', 'no ai adapter'); return ctx.adapters.ai.embed!(input); }, meta: { name: '$ai.embed', backendOnly: true } },
});