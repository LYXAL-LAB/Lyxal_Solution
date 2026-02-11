import { createPlugin } from '@lyxal/logic-shared';
import { runInstanceUI } from '@lyxal/logic-shared';
import type { OperatorMeta } from '@lyxal/logic-shared';

const pushMeta: OperatorMeta = {
  name: '$array.instance.push',
  description: 'Retourne une nouvelle copie du tableau avec la valeur ajoutée en fin.',
  category: 'array',
  version: '1.0.0',
  instanceOf: 'array',
  args: [
    {
      name: 'value',
      type: ['any'],
      required: true,
      description: 'Valeur à pousser dans le tableau'
    }
  ],
  returns: 'array',
  returnInstance: false,
  permissions: {
    uiSafe: true,
    backend: false,
    roles: ['admin', 'editor', 'viewer'],
    plans: ['free', 'pro', 'enterprise'],
    moduleAccess: ['studio'],
    premium: false,
    tenantScope: 'local',
    allowedIn: ['renderer']
  },
  examples: [
    {
      title: 'Ajouter un élément',
      ui: { array: [1, 2], value: 3 },
      expected: [1, 2, 3]
    }
  ],
  autoDocs: true,
  uiExample: { array: ['a', 'b'], value: 'c' },
  isPure: true,
  complexity: 1,
  ai: {
    usageExamples: ['append value to array'],
    commonMistakes: ['Passer un objet au lieu d’un tableau pour "array"'],
    naturalLanguage: ['push into array', 'array append element']
  }
};

export const arrayInstancePlugin = createPlugin('@lyxal/op-array-instance', {
  '$array.instance.push': {
    meta: pushMeta,
    fn: (params: any, ctx: any) =>
      runInstanceUI({
        operator: pushMeta.name,
        method: 'push',
        params,
        meta: pushMeta,
        location: ctx?.location ?? 'ui',
        impl: (arr: any[], value: any) => {
          if (!Array.isArray(arr)) return arr;
          const out = arr.slice();
          out.push(value);
          return out;
        },
      }),
  },
});
