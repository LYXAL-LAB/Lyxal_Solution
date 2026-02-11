/**
 * Système de logging pour le module lyxalsurreal
 * Permet une gestion centralisée et configurable des logs
 */

import { existsSync, mkdirSync, appendFileSync } from 'fs';
import { dirname } from 'path';

export enum LogLevel {
  NONE = 0,
  ERROR = 1,
  WARN = 2,
  INFO = 3,
  DEBUG = 4,
  TRACE = 5
}

export interface LogOptions {
  level: LogLevel;
  prefix?: string;
  timestampFormat?: string;
  colorize?: boolean;
  logToFile?: boolean;
  logFilePath?: string;
}

export class Logger {
  private static instance: Logger;
  private options: LogOptions;

  private constructor(options: LogOptions) {
    this.options = {
      prefix: '[LYXALSURREAL]',
      timestampFormat: 'HH:mm:ss.SSS',
      colorize: true,
      ...options
    };
  }

  public static getInstance(options?: Partial<LogOptions>): Logger {
    if (!Logger.instance) {
      const defaultOptions: LogOptions = {
        level: process.env.NODE_ENV === 'production' ? LogLevel.INFO : LogLevel.DEBUG,
        prefix: '[LYXALSURREAL]',
        timestampFormat: 'HH:mm:ss.SSS',
        colorize: process.env.NODE_ENV !== 'production',
        logToFile: process.env.NODE_ENV === 'production',
        logFilePath: './logs/lyxalsurreal.log'
      };
      
      Logger.instance = new Logger({
        ...defaultOptions,
        ...options
      });
    } else if (options) {
      // Mettre à jour les options si fournies
      Logger.instance.options = {
        ...Logger.instance.options,
        ...options
      };
    }
    
    return Logger.instance;
  }

  /**
   * Formater un message de log
   */
  private formatMessage(level: string, message: string): string {
    const timestamp = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
    return `${timestamp} ${this.options.prefix} [${level}] ${message}`;
  }

  /**
   * Colorer un message selon son niveau
   */
  private colorize(level: string, message: string): string {
    if (!this.options.colorize) return message;
    
    type ColorKeys = 'ERROR' | 'WARN' | 'INFO' | 'DEBUG' | 'TRACE';
    const colors: Record<ColorKeys, string> = {
      ERROR: '\x1b[31m', // Rouge
      WARN: '\x1b[33m',  // Jaune
      INFO: '\x1b[36m',  // Cyan
      DEBUG: '\x1b[90m', // Gris
      TRACE: '\x1b[35m'  // Magenta
    };
    
    const reset = '\x1b[0m';
    return `${colors[level as ColorKeys] || ''}${message}${reset}`;
  }

  /**
   * Log un message d'erreur
   */
  public error(message: string, error?: Error): void {
    if (this.options.level < LogLevel.ERROR) return;
    
    const formattedMsg = this.formatMessage('ERROR', message);
    const coloredMsg = this.colorize('ERROR', formattedMsg);
    
    console.error(coloredMsg);
    if (error) {
      console.error(this.colorize('ERROR', `${this.options.prefix} [ERROR] ${error.stack || error.message}`));
    }
    
    // Implémenter la journalisation dans un fichier si activée
    if (this.options.logToFile) {
      this.logToFile(formattedMsg);
      if (error) {
        this.logToFile(`${this.options.prefix} [ERROR] ${error.stack || error.message}`);
      }
    }
  }

  /**
   * Log un avertissement
   */
  public warn(message: string): void {
    if (this.options.level < LogLevel.WARN) return;
    
    const formattedMsg = this.formatMessage('WARN', message);
    console.warn(this.colorize('WARN', formattedMsg));
    
    if (this.options.logToFile) {
      this.logToFile(formattedMsg);
    }
  }

  /**
   * Log une information
   */
  public info(message: string): void {
    if (this.options.level < LogLevel.INFO) return;
    
    const formattedMsg = this.formatMessage('INFO', message);
    console.info(this.colorize('INFO', formattedMsg));
    
    if (this.options.logToFile) {
      this.logToFile(formattedMsg);
    }
  }

  /**
   * Log un message de débogage
   */
  public debug(message: string): void {
    if (this.options.level < LogLevel.DEBUG) return;
    
    const formattedMsg = this.formatMessage('DEBUG', message);
    console.debug(this.colorize('DEBUG', formattedMsg));
    
    if (this.options.logToFile) {
      this.logToFile(formattedMsg);
    }
  }

  /**
   * Log une trace (détaillée)
   */
  public trace(message: string): void {
    if (this.options.level < LogLevel.TRACE) return;
    
    const formattedMsg = this.formatMessage('TRACE', message);
    console.log(this.colorize('TRACE', formattedMsg));
    
    if (this.options.logToFile) {
      this.logToFile(formattedMsg);
    }
  }

  /**
   * Écrire dans un fichier de log (implémentation simple)
   */
  private logToFile(message: string): void {
    if (!this.options.logFilePath) return;
    
    try {
      // Créer le répertoire de logs s'il n'existe pas
      const dir = dirname(this.options.logFilePath);
      if (!existsSync(dir)) {
        mkdirSync(dir, { recursive: true });
      }
      
      appendFileSync(this.options.logFilePath, message + '\n');
    } catch (error: unknown) {
      // Éviter de boucler en cas d'erreur lors de l'écriture du log
      if (error instanceof Error) {
        console.error(`Erreur lors de l'écriture dans le fichier de log: ${error.message}`);
      } else {
        console.error(`Erreur lors de l'écriture dans le fichier de log: ${String(error)}`);
      }
    }
  }
} 