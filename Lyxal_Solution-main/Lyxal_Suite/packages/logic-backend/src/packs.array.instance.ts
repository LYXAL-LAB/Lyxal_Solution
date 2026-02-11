import { createPlugin } from '@lyxal/logic-shared';
import { runInstanceBackend } from '@lyxal/logic-shared';
import type { OperatorMeta } from '@lyxal/logic-shared';

const pushMetaBE: OperatorMeta = {
  name: '$array.instance.push',
  description: 'Retourne une nouvelle copie du tableau avec la valeur ajoutée en fin (Backend).',
  category: 'array',
  version: '1.0.0',
  instanceOf: 'array',
  args: [
    { name: 'value', type: ['any'], required: true, description: 'Valeur à pousser' }
  ],
  returns: 'array',
  returnInstance: false,
  permissions: {
    uiSafe: false,
    backend: true,
    roles: ['admin', 'editor', 'worker'],
    plans: ['free', 'pro', 'enterprise'],
    moduleAccess: ['automation'],
    premium: false,
    tenantScope: 'local',
    allowedIn: ['workflow']
  },
  examples: [
    {
      title: 'Syntaxe liste',
      backend: [[1, 2], 9],
      expected: [1, 2, 9]
    },
    {
      title: 'Syntaxe objet',
      backend: { on: ['a', 'b'], value: 'c' },
      expected: ['a', 'b', 'c']
    }
  ],
  autoDocs: true,
  backendExample: { on: [1, 2], value: 3 },
  isPure: true,
  complexity: 1,
  ai: {
    usageExamples: ['push value to array on backend'],
    commonMistakes: ['ne pas passer un tableau à "on"'],
    naturalLanguage: ['append item into array backend']
  }
};

export const arrayInstancePlugin = createPlugin('@lyxal/op-array-instance-be', {
  '$array.instance.push': {
    meta: pushMetaBE,
    fn: (params: any, ctx: any) =>
      runInstanceBackend({
        operator: pushMetaBE.name,
        method: 'push',
        params,
        meta: pushMetaBE,
        location: ctx?.location ?? 'backend',
        impl: (arr: any[], value: any) => {
          if (!Array.isArray(arr)) return arr;
          const out = arr.slice();
          out.push(value);
          return out;
        },
      }),
  },
});
