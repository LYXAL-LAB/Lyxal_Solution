import { MiddlewareHandler } from 'hono';

export const requireRole = (role: string): MiddlewareHandler => {
  return async (ctx, next) => {
    const auth = ctx.get('auth');
    if (!auth?.roles?.includes(role)) {
      return ctx.json({ error: 'Forbidden' }, 403);
    }
    await next();
  };
};