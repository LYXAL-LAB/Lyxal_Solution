import { MiddlewareHandler } from 'hono';

// Stockage en mémoire pour le rate limiting (5 requêtes/min/IP)
const requestCounts = new Map<string, { count: number; timestamp: number }>();
const WINDOW_MS = 60_000; // 1 minute en millisecondes
const MAX_REQUESTS = 5;

// Nettoyage périodique de la mémoire (toutes les 5 minutes)
setInterval(() => {
  const now = Date.now();
  for (const [ip, data] of requestCounts.entries()) {
    if (now - data.timestamp > WINDOW_MS) {
      requestCounts.delete(ip);
    }
  }
}, 300_000); // 5 minutes

export const rateLimit: MiddlewareHandler = async (c, next) => {
  const ip = c.req.header('x-forwarded-for') || c.req.raw.headers.get('x-real-ip') || 'local';
  const now = Date.now();
  const entry = requestCounts.get(ip) || { count: 0, timestamp: now };

  if (now - entry.timestamp > WINDOW_MS) {
    entry.count = 0;
    entry.timestamp = now;
  }

  entry.count += 1;
  requestCounts.set(ip, entry);

  if (entry.count > MAX_REQUESTS) {
    return c.json({ error: 'Trop de requêtes', message: 'Veuillez réessayer plus tard' }, 429);
  }

  await next();
};
