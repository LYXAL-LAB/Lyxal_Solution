// src/utils/retry.ts
// =========================================================
// Retry PRO (exponential backoff + jitter) pour LYXAL
// =========================================================

export interface RetryOptions {
    attempts: number;
    delayMs: number;
    backoffFactor?: number; // exponentiel (par défaut 1.5)
    jitter?: boolean; // ajoute une variation aléatoire
  }
  
  export async function withRetry<T>(
    fn: () => Promise<T>,
    opts: RetryOptions,
  ): Promise<T> {
    const {
      attempts,
      delayMs,
      backoffFactor = 1.5,
      jitter = true,
    } = opts;
  
    let lastError: unknown;
  
    let currentDelay = delayMs;
  
    for (let i = 0; i < attempts; i++) {
      try {
        return await fn();
      } catch (err) {
        lastError = err;
  
        if (i >= attempts - 1) break;
  
        let sleepTime = currentDelay;
  
        if (jitter) {
          sleepTime = sleepTime * (0.8 + Math.random() * 0.4); // +/-20%
        }
  
        await new Promise((resolve) => setTimeout(resolve, sleepTime));
  
        currentDelay *= backoffFactor;
      }
    }
  
    throw lastError;
  }  