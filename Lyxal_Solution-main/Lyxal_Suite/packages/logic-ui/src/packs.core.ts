import { createPlugin, OperatorFn } from '@lyxal/logic-shared';


const $eq: OperatorFn = (args) => {
const [a, b] = Array.isArray(args) ? args : [args, undefined];
return a === b;
};
const $not: OperatorFn = (arg) => !(Array.isArray(arg) ? arg[0] : arg);
const $and: OperatorFn = (args) => (Array.isArray(args) ? args.every(Boolean) : Boolean(args));
const $or: OperatorFn = (args) => (Array.isArray(args) ? args.some(Boolean) : Boolean(args));
const $if: OperatorFn = (args) => {
const [cond, thenV, elseV] = args || [];
return cond ? thenV : elseV;
};


export const corePlugin = createPlugin('@lyxal/op-core', {
'$eq': { fn: $eq, meta: { name: '$eq', uiSafe: true } },
'$not': { fn: $not, meta: { name: '$not', uiSafe: true } },
'$and': { fn: $and, meta: { name: '$and', uiSafe: true } },
'$or': { fn: $or, meta: { name: '$or', uiSafe: true } },
'$if': { fn: $if, meta: { name: '$if', uiSafe: true } },
});