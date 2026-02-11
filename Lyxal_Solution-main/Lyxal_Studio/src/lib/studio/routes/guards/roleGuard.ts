import { GuardExecutionContext, GuardExecutionResult } from '../../types/route';

/**
 * Condition pour le guard de rôle
 */
export interface RoleGuardCondition {
  role: string;
  require_all?: boolean; // Si true, nécessite tous les rôles spécifiés
}

/**
 * Guard de vérification des rôles utilisateur
 * Vérifie si l'utilisateur possède les rôles requis
 */
export async function executeRoleGuard(
  condition: RoleGuardCondition,
  context: GuardExecutionContext
): Promise<GuardExecutionResult> {
  console.log('[RoleGuard] 👤 Checking user roles...', condition);

  try {
    // Vérifier si un utilisateur est présent
    if (!context.user) {
      console.log('[RoleGuard] ❌ No user found');
      return {
        success: false,
        error: 'User not authenticated',
        redirectTo: '/signin'
      };
    }

    // Vérifier si l'utilisateur a des rôles
    if (!context.user.roles || context.user.roles.length === 0) {
      console.log('[RoleGuard] ❌ User has no roles');
      return {
        success: false,
        error: 'User has no roles assigned',
        redirectTo: '/unauthorized'
      };
    }

    const requiredRole = condition.role;
    const userRoles = context.user.roles;

    console.log(`[RoleGuard] Required role: ${requiredRole}`);
    console.log(`[RoleGuard] User roles:`, userRoles);

    // Vérifier si l'utilisateur a le rôle requis (super_admin a tous les droits)
    const hasRole = userRoles.includes(requiredRole) || userRoles.includes('super_admin');

    if (!hasRole) {
      console.log(`[RoleGuard] ❌ User does not have required role: ${requiredRole}`);
      return {
        success: false,
        error: `Required role not found: ${requiredRole}`,
        redirectTo: '/unauthorized'
      };
    }

    // Vérifier les permissions associées au rôle (super_admin a tous les droits)
    if (!userRoles.includes('super_admin')) {
      const rolePermissions = getPermissionsForRole(requiredRole);
      if (rolePermissions.length > 0) {
        const hasPermissions = rolePermissions.every(perm =>
          context.user?.permissions?.includes(perm)
        );

        if (!hasPermissions) {
          console.log(`[RoleGuard] ❌ User missing permissions for role: ${requiredRole}`);
          return {
            success: false,
            error: `Missing permissions for role: ${requiredRole}`,
            redirectTo: '/unauthorized'
          };
        }
      }
    }

    console.log(`[RoleGuard] ✅ User has required role: ${requiredRole}`);
    return {
      success: true
    };

  } catch (error) {
    console.error('[RoleGuard] Error during role check:', error);
    return {
      success: false,
      error: 'Role verification failed',
      redirectTo: '/error'
    };
  }
}

/**
 * Récupère les permissions associées à un rôle
 */
function getPermissionsForRole(role: string): string[] {
  const rolePermissions: Record<string, string[]> = {
    'admin': ['admin', 'authenticated'],
    'manager': ['manager', 'authenticated'],
    'user': ['authenticated'],
    'super_admin': ['admin', 'manager', 'authenticated'],
    'guest': []
  };

  return rolePermissions[role] || [];
}
