import { createPlugin, OperatorError } from '@lyxal/logic-shared';


export const schedulerPlugin = createPlugin('@lyxal/op-scheduler', {
'$schedule.cron': { fn: async ({ spec, payload }, ctx) => { if (!ctx.adapters?.scheduler?.cron) throw new OperatorError('$schedule.cron', 'no scheduler adapter'); return ctx.adapters.scheduler.cron(spec, payload); }, meta: { name: '$schedule.cron', backendOnly: true } },
});