import { createPlugin, OperatorError } from '@lyxal/logic-shared';


export const surrealPlugin = createPlugin('@lyxal/op-surreal', {
'$surreal.query': { fn: async ({ sql, vars }, ctx) => { if (!ctx.adapters?.surreal?.query) throw new OperatorError('$surreal.query', 'no surreal adapter'); return ctx.adapters.surreal.query(sql, vars); }, meta: { name: '$surreal.query', backendOnly: true } },
});