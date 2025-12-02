import { createPlugin } from '@lyxal/logic-shared';


export const arrayPlugin = createPlugin('@lyxal/op-array', {
'$array.get': { fn: ({ array, value, index, all }) => { if (!Array.isArray(array)) return null; if (all) return array; if (typeof index === 'number') return array[index]; return array.find((it) => it === value || it?.id === value || it?.value === value) ?? null; }, meta: { name: '$array.get', uiSafe: true } },
'$array.length': { fn: ({ array }) => (Array.isArray(array) ? array.length : 0), meta: { name: '$array.length', uiSafe: true } },
});