// packages/logic-backend/src/operators/operatorMapBackend.ts
import type { EngineContext } from '@lyxal/logic-shared/src/engine/EngineContext';

/**
 * operatorMapBackend
 *
 * Structure :
 * {
 *   namespace: {
 *     category: {
 *       method: async (params, ctx) => any
 *     }
 *   }
 * }
 *
 * Exemple: $http.get → operatorMapBackend.http.request.get
 */

export const operatorMapBackend = {
  date: {
    instance: {
      addDays: async (params: any) => {
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
      add: async (params: any) => {
        const [a, b] = Array.isArray(params) ? params : [params?.a, params?.b];
        return Number(a) + Number(b);
      },
      subtract: async (params: any) => {
        const [a, b] = Array.isArray(params) ? params : [params?.a, params?.b];
        return Number(a) - Number(b);
      },
    },
  },

  http: {
    request: {
      get: async (params: any) => {
        const url = Array.isArray(params) ? params[0] : params?.url;
        if (!url) throw new Error(`$http.get requires a url`);
        const res = await fetch(url);
        return res.json();
      },

      post: async (params: any) => {
        const [url, body] = Array.isArray(params)
          ? params
          : [params?.url, params?.body];
        if (!url) throw new Error(`$http.post requires a url`);
        const res = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body ?? {}),
        });
        return res.json();
      },
    },
  },

  surreal: {
    query: {
      run: async (params: any, ctx: EngineContext) => {
        const [sql, vars] = Array.isArray(params)
          ? params
          : [params?.sql, params?.vars];

        const surreal = (ctx as any).surreal;
        if (!surreal?.query) {
          throw new Error(`No Surreal adapter found in context at ctx.surreal`);
        }
        return surreal.query(sql, vars ?? {});
      },
    },
  },
} as const;
