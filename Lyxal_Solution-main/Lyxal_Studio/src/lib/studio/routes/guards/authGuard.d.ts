import { GuardExecutionContext, GuardExecutionResult } from '../../types/route';
/**
 * Guard d'authentification
 * Vérifie si l'utilisateur est connecté
 */
export declare function executeAuthGuard(condition: any, context: GuardExecutionContext): Promise<GuardExecutionResult>;
