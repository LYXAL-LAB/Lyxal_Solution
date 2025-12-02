import { GuardExecutionContext, GuardExecutionResult } from '../../types/route';

/**
 * Condition pour le guard de fonctionnalité
 */
export interface FeatureGuardCondition {
  feature: string;      // Fonctionnalité requise
  version?: string;     // Version minimum requise
  fallback?: string;    // Fonctionnalité de remplacement si non disponible
}

/**
 * Guard de vérification des fonctionnalités
 * Vérifie si l'utilisateur a accès à une fonctionnalité spécifique
 */
export async function executeFeatureGuard(
  condition: FeatureGuardCondition,
  context: GuardExecutionContext
): Promise<GuardExecutionResult> {
  console.log('[FeatureGuard] ⚡ Checking feature access...', condition);

  try {
    // Vérifier si un utilisateur est présent
    if (!context.user) {
      console.log('[FeatureGuard] ❌ No user found');
      return {
        success: false,
        error: 'User not authenticated',
        redirectTo: '/signin'
      };
    }

    const requiredFeature = condition.feature;
    console.log(`[FeatureGuard] Required feature: ${requiredFeature}`);

    // Sources possibles de fonctionnalités :
    // 1. Rôles utilisateur (super_admin a tout)
    // 2. Permissions explicites
    // 3. Abonnement actif avec features
    // 4. Tenant features
    // 5. Feature flags globaux

    // Vérifier les rôles spéciaux (super_admin a tout accès)
    if (context.user.roles?.includes('super_admin')) {
      console.log(`[FeatureGuard] ✅ Super admin access granted for: ${requiredFeature}`);
      return { success: true };
    }

    // Vérifier les permissions explicites
    if (context.user.permissions?.includes(`feature:${requiredFeature}`)) {
      console.log(`[FeatureGuard] ✅ Explicit permission granted for: ${requiredFeature}`);
      return { success: true };
    }

    // Vérifier l'abonnement
    if (context.user.subscription?.active && context.user.subscription.features) {
      const hasFeature = context.user.subscription.features.includes(requiredFeature);

      if (hasFeature) {
        // Vérifier la version si spécifiée
        if (condition.version) {
          const userVersion = getFeatureVersion(context.user.subscription, requiredFeature);
          if (!isVersionCompatible(userVersion, condition.version)) {
            console.log(`[FeatureGuard] ❌ Version mismatch for ${requiredFeature}. Required: ${condition.version}, User: ${userVersion}`);

            // Essayer la fonctionnalité de fallback
            if (condition.fallback && context.user.subscription.features.includes(condition.fallback)) {
              console.log(`[FeatureGuard] 🔄 Using fallback feature: ${condition.fallback}`);
              return { success: true };
            }

            return {
              success: false,
              error: `Feature version ${condition.version} required for ${requiredFeature}`,
              redirectTo: '/feature/upgrade'
            };
          }
        }

        console.log(`[FeatureGuard] ✅ Subscription feature granted: ${requiredFeature}`);
        return { success: true };
      }
    }

    // Vérifier les features de tenant
    if (context.tenant?.features?.includes(requiredFeature)) {
      console.log(`[FeatureGuard] ✅ Tenant feature granted: ${requiredFeature}`);
      return { success: true };
    }

    // Vérifier les rôles spécifiques qui donnent accès à certaines features
    const featureRoles = getRolesForFeature(requiredFeature);
    const hasRoleAccess = featureRoles.some(role =>
      context.user?.roles?.includes(role)
    );

    if (hasRoleAccess) {
      console.log(`[FeatureGuard] ✅ Role-based feature access granted: ${requiredFeature}`);
      return { success: true };
    }

    // Feature non disponible
    console.log(`[FeatureGuard] ❌ Feature not available: ${requiredFeature}`);
    console.log(`[FeatureGuard] Available features:`, {
      permissions: context.user.permissions,
      subscription: context.user.subscription?.features,
      tenant: context.tenant?.features,
      roles: context.user.roles
    });

    return {
      success: false,
      error: `Feature ${requiredFeature} not available`,
      redirectTo: condition.fallback ? '/feature/upgrade' : '/feature/unavailable'
    };

  } catch (error) {
    console.error('[FeatureGuard] Error during feature check:', error);
    return {
      success: false,
      error: 'Feature verification failed',
      redirectTo: '/error'
    };
  }
}

/**
 * Récupère les rôles qui donnent accès à une fonctionnalité
 */
function getRolesForFeature(feature: string): string[] {
  const featureRoles: Record<string, string[]> = {
    'admin_panel': ['admin', 'super_admin'],
    'user_management': ['admin', 'manager', 'super_admin'],
    'analytics': ['admin', 'manager', 'super_admin'],
    'advanced_search': ['user', 'admin', 'manager', 'super_admin'],
    'export_data': ['user', 'admin', 'manager', 'super_admin'],
    'api_access': ['admin', 'super_admin']
  };

  return featureRoles[feature] || [];
}

/**
 * Récupère la version d'une fonctionnalité dans l'abonnement
 */
function getFeatureVersion(subscription: any, feature: string): string {
  // Dans un vrai système, la version pourrait être stockée séparément
  // Pour l'instant, on retourne 'latest'
  return 'latest';
}

/**
 * Vérifie si une version est compatible avec une version requise
 */
function isVersionCompatible(userVersion: string, requiredVersion: string): boolean {
  if (userVersion === 'latest') return true;

  try {
    // Version simple comparison (x.y.z format)
    const userParts = userVersion.split('.').map(Number);
    const requiredParts = requiredVersion.split('.').map(Number);

    for (let i = 0; i < Math.max(userParts.length, requiredParts.length); i++) {
      const userPart = userParts[i] || 0;
      const requiredPart = requiredParts[i] || 0;

      if (userPart > requiredPart) return true;
      if (userPart < requiredPart) return false;
    }

    return true; // Versions égales
  } catch {
    // En cas d'erreur de parsing, considérer comme compatible
    return true;
  }
}

/**
 * Vérifie si une fonctionnalité est disponible pour un utilisateur
 * (version simplifiée pour usage général)
 */
export function hasFeatureAccess(
  user: any,
  feature: string,
  version?: string
): boolean {
  // Super admin a tout
  if (user?.roles?.includes('super_admin')) return true;

  // Permissions explicites
  if (user?.permissions?.includes(`feature:${feature}`)) return true;

  // Abonnement
  if (user?.subscription?.active && user?.subscription?.features?.includes(feature)) {
    return !version || isVersionCompatible(getFeatureVersion(user.subscription, feature), version);
  }

  // Tenant
  if (user?.tenant?.features?.includes(feature)) return true;

  // Rôles
  const featureRoles = getRolesForFeature(feature);
  return featureRoles.some(role => user?.roles?.includes(role));
}
