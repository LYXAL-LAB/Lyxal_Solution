// packages/logic-ui/src/operators/operatorMapUI.ts
import type { EngineContext } from '@lyxal/logic-shared/src/engine/EngineContext';

/**
 * operatorMapUI
 *
 * Structure :
 * {
 *   namespace: {
 *     category: {
 *       method: (params, ctx) => any
 *     }
 *   }
 * }
 *
 * Exemple: $date.instance.addDays → operatorMapUI.date.instance.addDays
 */

export const operatorMapUI = {
  date: {
    instance: {
      addDays: (params: any, ctx: EngineContext) => {
        const [dateLike, days] = Array.isArray(params)
          ? params
          : [params?.date, params?.days];

        const d = dateLike ? new Date(dateLike) : new Date();
        d.setDate(d.getDate() + Number(days ?? 0));
        return d.toISOString();
      },
    },
  },

  math: {
    basic: {
      add: (params: any) => {
        const [a, b] = Array.isArray(params) ? params : [params?.a, params?.b];
        return Number(a) + Number(b);
      },
      subtract: (params: any) => {
        const [a, b] = Array.isArray(params) ? params : [params?.a, params?.b];
        return Number(a) - Number(b);
      },
    },
  },

  string: {
    format: {
      toUpper: (params: any) => {
        const value = Array.isArray(params) ? params[0] : params?.value;
        return typeof value === 'string' ? value.toUpperCase() : value;
      },
      toLower: (params: any) => {
        const value = Array.isArray(params) ? params[0] : params?.value;
        return typeof value === 'string' ? value.toLowerCase() : value;
      },
    },
  },
} as const;
