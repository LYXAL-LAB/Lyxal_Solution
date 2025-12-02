import { createPlugin } from '@lyxal/logic-shared';
import { runInstanceBackend } from '@lyxal/logic-shared';
import type { OperatorMeta } from '@lyxal/logic-shared';

const addDaysMetaBE: OperatorMeta = {
  name: '$date.instance.addDays',
  description: 'Ajoute N jours à une date (Backend) et renvoie une ISO string.',
  category: 'date',
  version: '1.0.0',
  instanceOf: 'date',
  args: [
    { name: 'days', type: 'number', required: true, description: 'Nombre de jours à ajouter' }
  ],
  returns: 'string',
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
      title: 'Liste (array) : on + days',
      backend: ['2025-01-10', 3],
      expected: '2025-01-13T...Z'
    },
    {
      title: 'Objet nommé : on + days',
      backend: { on: '2025-01-10', days: 3 },
      expected: '2025-01-13T...Z'
    }
  ],
  autoDocs: true,
  backendExample: { on: '2025-01-01', days: 1 },
  isPure: true,
  complexity: 1,
  ai: {
    usageExamples: ['add days backend array syntax', 'add days backend named syntax'],
    commonMistakes: ['Oublier "on" en objet', 'Passer days en string'],
    naturalLanguage: ['add N days on backend']
  }
};

export const dateInstancePlugin = createPlugin('@lyxal/op-date-instance-be', {
  '$date.instance.addDays': {
    meta: addDaysMetaBE,
    fn: (params: any, ctx: any) =>
      runInstanceBackend({
        operator: addDaysMetaBE.name,
        method: 'addDays',
        params,
        meta: addDaysMetaBE,
        location: ctx?.location ?? 'backend',
        impl: (dateLike: string | Date, days: number) => {
          const d = dateLike ? new Date(dateLike) : new Date();
          d.setDate(d.getDate() + Number(days ?? 0));
          return d.toISOString();
        },
      }),
  },
});
