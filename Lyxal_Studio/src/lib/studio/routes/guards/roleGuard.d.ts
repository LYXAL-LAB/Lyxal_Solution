import { GuardExecutionContext, GuardExecutionResult } from '../../types/route';
/**
 * Condition pour le guard de rôle
 */
export interface RoleGuardCondition {
    role: string;
    require_all?: boolean;
}
/**
 * Guard de vérification des rôles utilisateur
 * Vérifie si l'utilisateur possède les rôles requis
 */
export declare function executeRoleGuard(condition: RoleGuardCondition, context: GuardExecutionContext): Promise<GuardExecutionResult>;
