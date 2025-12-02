import { createPlugin } from '@lyxal/logic-shared';
import { runInstanceUI } from '@lyxal/logic-shared';
import type { OperatorMeta } from '@lyxal/logic-shared';

const addDaysMeta: OperatorMeta = {
  name: '$date.instance.addDays',
  description: 'Ajoute N jours à une date et renvoie une ISO string.',
  category: 'date',
  version: '1.0.0',
  instanceOf: 'date',
  args: [
    {
      name: 'days',
      type: 'number',
      required: true,
      description: 'Nombre de jours à ajouter',
      ui: { label: 'Jours', widget: 'number', placeholder: 'ex: 3', example: 3 }
    }
  ],
  returns: 'string',
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
      title: 'Ajouter 5 jours à maintenant',
      ui: { date: '{{now}}', days: 5 },
      expected: 'ISO string'
    }
  ],
  autoDocs: true,
  uiExample: { date: '{{now}}', days: 2 },
  isPure: true,
  complexity: 1,
  ai: {
    usageExamples: ['Ajoute 3 jours à la date fournie'],
    commonMistakes: ['Passer un texte non date', 'Oublier "days"'],
    naturalLanguage: ['add days to date', 'date + N days']
  }
};

export const dateInstancePlugin = createPlugin('@lyxal/op-date-instance', {
  '$date.instance.addDays': {
    meta: addDaysMeta,
    fn: (params: any, ctx: any) =>
      runInstanceUI({
        operator: addDaysMeta.name,
        method: 'addDays',
        params,
        meta: addDaysMeta,
        location: ctx?.location ?? 'ui',
        impl: (dateLike: string | Date, days: number) => {
          const d = dateLike ? new Date(dateLike) : new Date();
          d.setDate(d.getDate() + Number(days ?? 0));
          return d.toISOString();
        },
      }),
  },
});
