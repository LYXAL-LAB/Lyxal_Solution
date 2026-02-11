import { createPlugin } from '@lyxal/logic-shared';


export const objectPlugin = createPlugin('@lyxal/op-object', {
'$object.get': { fn: ({ object, key, all, default: def }: { object: any, key: string, all: boolean, default: any }) => { if (all) return object ? structuredClone(object) : null; if (!object || !key) return def ?? null; const v = key.split('.').reduce((a: any, k: string) => (a == null ? undefined : a[k]), object); return v ?? def ?? null; }, meta: { name: '$object.get', uiSafe: true } },
});