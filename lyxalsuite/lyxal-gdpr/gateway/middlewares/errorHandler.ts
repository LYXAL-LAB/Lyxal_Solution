import { MiddlewareHandler } from 'hono';

export const errorHandler: MiddlewareHandler = async (ctx, next) => {
  try {
    await next();
  } catch (err) {
    console.error('[GDPR ERROR]', err);
    return ctx.json({ error: 'Internal Server Error' }, 500);
  }
};