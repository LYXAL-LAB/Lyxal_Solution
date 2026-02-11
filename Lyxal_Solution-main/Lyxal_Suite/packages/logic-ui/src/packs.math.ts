import { createPlugin, OperatorFn } from '@lyxal/logic-shared';


const num = (v: any) => Number(Array.isArray(v) ? v[0] : v);


export const mathPlugin = createPlugin('@lyxal/op-math', {
'$math.add': { fn: (args) => (args || []).reduce((a: number, b: any) => a + Number(b), 0), meta: { name: '$math.add', uiSafe: true } },
'$math.sub': { fn: (args) => (args || []).slice(1).reduce((a: number, b: any) => a - Number(b), Number(args?.[0] ?? 0)), meta: { name: '$math.sub', uiSafe: true } },
'$math.mul': { fn: (args) => (args || []).reduce((a: number, b: any) => a * Number(b), 1), meta: { name: '$math.mul', uiSafe: true } },
'$math.div': { fn: (args) => (args || []).slice(1).reduce((a: number, b: any) => a / Number(b), Number(args?.[0] ?? 0)), meta: { name: '$math.div', uiSafe: true } },
'$math.round': { fn: (arg) => Math.round(num(arg)), meta: { name: '$math.round', uiSafe: true } },
});