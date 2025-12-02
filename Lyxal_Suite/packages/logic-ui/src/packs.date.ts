import { createPlugin } from '@lyxal/logic-shared';


export const datePlugin = createPlugin('@lyxal/op-date', {
'$date.now': { fn: () => new Date().toISOString(), meta: { name: '$date.now', uiSafe: true } },
'$date.format': { fn: ([input, fmt]) => { const d = input ? new Date(input) : new Date(); return fmt === 'ts' ? d.getTime() : (fmt === 'iso' ? d.toISOString() : d.toLocaleString()); }, meta: { name: '$date.format', uiSafe: true } },
});