import { createPlugin } from '@lyxal/logic-shared';


export const utilsPlugin = createPlugin('@lyxal/op-utils', {
'$string.upper': { fn: (arg) => String(Array.isArray(arg) ? arg[0] : arg ?? '').toUpperCase(), meta: { name: '$string.upper', uiSafe: true } },
'$string.lower': { fn: (arg) => String(Array.isArray(arg) ? arg[0] : arg ?? '').toLowerCase(), meta: { name: '$string.lower', uiSafe: true } },
'$string.trim': { fn: (arg) => String(Array.isArray(arg) ? arg[0] : arg ?? '').trim(), meta: { name: '$string.trim', uiSafe: true } },
'$number.parse': { fn: (arg) => Number(Array.isArray(arg) ? arg[0] : arg), meta: { name: '$number.parse', uiSafe: true } },
'$bool': { fn: (arg) => !!(Array.isArray(arg) ? arg[0] : arg), meta: { name: '$bool', uiSafe: true } },
});