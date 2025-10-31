/**
 * @file logger.ts
 * @description Module de journalisation simple pour l'API Gateway
 */

/**
 * Interface pour le logger
 */
interface Logger {
  info(message: string, context?: string): void;
  error(message: string, context?: string): void;
  warn(message: string, context?: string): void;
  debug(message: string, context?: string): void;
}

/**
 * Logger simple pour l'API Gateway
 */
class SimpleLogger implements Logger {
  info(message: string, context: string = 'app'): void {
    console.log(`[INFO] [${context}] ${message}`);
  }

  error(message: string, context: string = 'app'): void {
    console.error(`[ERROR] [${context}] ${message}`);
  }

  warn(message: string, context: string = 'app'): void {
    console.warn(`[WARN] [${context}] ${message}`);
  }

  debug(message: string, context: string = 'app'): void {
    console.debug(`[DEBUG] [${context}] ${message}`);
  }
}

// Exporter une instance singleton du logger
export const logger = new SimpleLogger(); 