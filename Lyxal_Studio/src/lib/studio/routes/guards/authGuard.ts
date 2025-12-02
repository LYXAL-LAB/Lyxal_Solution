import { GuardExecutionContext, GuardExecutionResult } from '../../types/route';

/**
 * Guard d'authentification
 * Vérifie si l'utilisateur est connecté
 */
export async function executeAuthGuard(
  condition: any,
  context: GuardExecutionContext
): Promise<GuardExecutionResult> {
  console.log('[AuthGuard] 🔐 Checking authentication...');

  try {
    // Vérifier si un utilisateur est présent
    if (!context.user) {
      console.log('[AuthGuard] ❌ No user found - authentication required');
      return {
        success: false,
        error: 'Authentication required',
        redirectTo: '/signin'
      };
    }

    // Vérifier si l'utilisateur a un ID valide
    if (!context.user.id) {
      console.log('[AuthGuard] ❌ Invalid user ID');
      return {
        success: false,
        error: 'Invalid user session',
        redirectTo: '/signin'
      };
    }

    // Vérifier si l'utilisateur a des rôles (signe d'authentification complète)
    if (!context.user.roles || context.user.roles.length === 0) {
      console.log('[AuthGuard] ❌ User has no roles - incomplete authentication');
      return {
        success: false,
        error: 'Incomplete user profile',
        redirectTo: '/signin'
      };
    }

    console.log(`[AuthGuard] ✅ User ${context.user.id} authenticated successfully`);
    return {
      success: true
    };

  } catch (error) {
    console.error('[AuthGuard] Error during authentication check:', error);
    return {
      success: false,
      error: 'Authentication check failed',
      redirectTo: '/signin'
    };
  }
}
