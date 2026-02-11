/**
 * Utilitaire pour normaliser et valider les routes
 * Assure la cohérence et la qualité des données de routes
 */
export class RouteNormalizer {
    /**
     * Normalise une route complète
     */
    static normalizeRoute(route, options = {}) {
        const result = {
            route: route,
            changes: [],
            warnings: [],
            errors: []
        };
        try {
            // Normaliser l'identité
            const identityResult = this.normalizeIdentity(route.identity, options);
            result.route.identity = identityResult.identity;
            result.changes.push(...identityResult.changes);
            result.warnings.push(...identityResult.warnings);
            // Normaliser les permissions
            const permissionsResult = this.normalizePermissions(route.permissions);
            result.route.permissions = permissionsResult.permissions;
            result.changes.push(...permissionsResult.changes);
            // Normaliser les guards
            if (route.guards) {
                const guardsResult = this.normalizeGuards(route.guards);
                result.route.guards = guardsResult.guards;
                result.changes.push(...guardsResult.changes);
                result.warnings.push(...guardsResult.warnings);
            }
            // Normaliser les métadonnées
            if (options.sanitizeMetadata && route.metadata) {
                const metadataResult = this.normalizeMetadata(route.metadata);
                result.route.metadata = metadataResult.metadata;
                result.changes.push(...metadataResult.changes);
            }
            // Appliquer les valeurs par défaut
            if (options.enforceDefaults) {
                const defaultsResult = this.applyDefaults(result.route);
                result.route = defaultsResult.route;
                result.changes.push(...defaultsResult.changes);
            }
            // Valider la cohérence globale
            const validationResult = this.validateRouteConsistency(result.route);
            result.warnings.push(...validationResult.warnings);
            result.errors.push(...validationResult.errors);
        }
        catch (error) {
            result.errors.push(`Normalization failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
        return result;
    }
    /**
     * Normalise l'identité d'une route
     */
    static normalizeIdentity(identity, options = {}) {
        const changes = [];
        const warnings = [];
        if (!identity) {
            throw new Error('Route identity is required');
        }
        let value = identity.value;
        let slug = identity.slug;
        let code = identity.code;
        // Normaliser le chemin
        if (value) {
            const originalValue = value;
            value = this.normalizePath(value);
            if (value !== originalValue) {
                changes.push(`Path normalized: '${originalValue}' → '${value}'`);
            }
        }
        else {
            throw new Error('Route path (value) is required');
        }
        // Générer ou valider le slug
        if (!slug && options.generateSlugs) {
            slug = this.generateSlugFromPath(value);
            changes.push(`Slug generated: '${slug}'`);
        }
        else if (slug) {
            const normalizedSlug = this.normalizeSlug(slug);
            if (normalizedSlug !== slug) {
                changes.push(`Slug normalized: '${slug}' → '${normalizedSlug}'`);
                slug = normalizedSlug;
            }
        }
        // Générer ou valider le code
        if (!code && options.generateCodes) {
            code = this.generateCodeFromPath(value);
            changes.push(`Code generated: '${code}'`);
        }
        else if (code) {
            const normalizedCode = this.normalizeCode(code);
            if (normalizedCode !== code) {
                changes.push(`Code normalized: '${code}' → '${normalizedCode}'`);
                code = normalizedCode;
            }
        }
        // Vérifications finales - ces champs doivent être définis
        if (!slug) {
            throw new Error('Route slug is required (use generateSlugs option or provide explicit slug)');
        }
        if (!code) {
            throw new Error('Route code is required (use generateCodes option or provide explicit code)');
        }
        // Vérifier la cohérence
        if (slug && !this.isValidSlug(slug)) {
            warnings.push(`Slug format may be invalid: '${slug}'`);
        }
        if (code && !this.isValidCode(code)) {
            warnings.push(`Code format may be invalid: '${code}'`);
        }
        return {
            identity: { value, slug, code },
            changes,
            warnings
        };
    }
    /**
     * Normalise les permissions
     */
    static normalizePermissions(permissions) {
        const changes = [];
        if (!permissions || permissions.length === 0) {
            changes.push('Default permissions applied: ["guest"]');
            return {
                permissions: ['guest'],
                changes
            };
        }
        // Éliminer les doublons et valider
        const uniquePermissions = [...new Set(permissions)];
        const validPermissions = uniquePermissions.filter(p => ['guest', 'authenticated', 'admin', 'manager'].includes(p));
        if (validPermissions.length !== uniquePermissions.length) {
            const invalid = uniquePermissions.filter(p => !validPermissions.includes(p));
            changes.push(`Invalid permissions removed: ${invalid.join(', ')}`);
        }
        // Trier pour la cohérence
        validPermissions.sort();
        return {
            permissions: validPermissions,
            changes
        };
    }
    /**
     * Normalise les guards
     */
    static normalizeGuards(guards) {
        const changes = [];
        const warnings = [];
        if (!guards || guards.length === 0) {
            return { guards: [], changes, warnings };
        }
        const normalizedGuards = guards.map((guard, index) => {
            if (!guard.type) {
                warnings.push(`Guard ${index}: missing type`);
                return guard;
            }
            // Valider le type de guard
            const validTypes = ['auth', 'role', 'subscription', 'feature'];
            if (!validTypes.includes(guard.type)) {
                warnings.push(`Guard ${index}: invalid type '${guard.type}'`);
            }
            // Normaliser les conditions
            if (guard.condition && typeof guard.condition === 'object') {
                // TODO: Validation plus poussée selon le type
            }
            return guard;
        });
        return {
            guards: normalizedGuards,
            changes,
            warnings
        };
    }
    /**
     * Normalise les métadonnées
     */
    static normalizeMetadata(metadata) {
        const changes = [];
        const normalized = { ...metadata };
        // Normaliser le titre
        if (normalized.title_i18n) {
            normalized.title_i18n = normalized.title_i18n.trim();
        }
        // Normaliser la description
        if (normalized.description_i18n) {
            normalized.description_i18n = normalized.description_i18n.trim();
        }
        // Normaliser l'ordre
        if (normalized.order !== undefined) {
            const order = Math.max(0, Math.floor(normalized.order));
            if (order !== normalized.order) {
                changes.push(`Order normalized: ${normalized.order} → ${order}`);
                normalized.order = order;
            }
        }
        // Normaliser les tags
        if (normalized.tags) {
            normalized.tags = normalized.tags
                .map(tag => tag.toLowerCase().trim())
                .filter(tag => tag.length > 0)
                .filter((tag, index, arr) => arr.indexOf(tag) === index); // Éliminer doublons
        }
        return { metadata: normalized, changes };
    }
    /**
     * Applique les valeurs par défaut
     */
    static applyDefaults(route) {
        const changes = [];
        // Valeur par défaut pour le statut
        if (!route.status) {
            route.status = 'active';
            changes.push('Default status applied: "active"');
        }
        // Valeur par défaut pour les métadonnées
        if (!route.metadata) {
            route.metadata = {};
            changes.push('Default metadata applied: {}');
        }
        // Valeur par défaut pour l'ordre
        if (route.metadata && route.metadata.order === undefined) {
            route.metadata.order = 999;
            changes.push('Default order applied: 999');
        }
        return { route, changes };
    }
    /**
     * Valide la cohérence globale de la route
     */
    static validateRouteConsistency(route) {
        const warnings = [];
        const errors = [];
        // Vérifier la cohérence admin/permissions
        if (route.permissions.includes('admin') && route.permissions.length > 1) {
            warnings.push('Admin permission should be exclusive');
        }
        // Vérifier les guards pour les permissions élevées
        if (route.permissions.includes('admin') && (!route.guards || route.guards.length === 0)) {
            warnings.push('Admin routes should have guards');
        }
        // Vérifier la présence de page
        if (!route.page?.identity?.code) {
            errors.push('Route must reference a valid page');
        }
        return { warnings, errors };
    }
    // === UTILITAIRES ===
    static normalizePath(path) {
        // S'assurer qu'il commence par /
        let normalized = path.startsWith('/') ? path : `/${path}`;
        // Supprimer les slash multiples
        normalized = normalized.replace(/\/+/g, '/');
        // Supprimer le slash final sauf pour la racine
        if (normalized.length > 1 && normalized.endsWith('/')) {
            normalized = normalized.slice(0, -1);
        }
        return normalized;
    }
    static generateSlugFromPath(path) {
        return path
            .replace(/^\/+/, '') // Supprimer les slash initiaux
            .replace(/\/+/g, '-') // Remplacer les slash par des tirets
            .toLowerCase();
    }
    static generateCodeFromPath(path) {
        return path
            .replace(/^\/+/, '') // Supprimer les slash initiaux
            .replace(/\/+/g, '_') // Remplacer les slash par des underscores
            .toLowerCase();
    }
    static normalizeSlug(slug) {
        return slug
            .toLowerCase()
            .replace(/[^a-z0-9-]/g, '-') // Remplacer les caractères spéciaux par -
            .replace(/-+/g, '-') // Supprimer les - multiples
            .replace(/^-|-$/g, ''); // Supprimer les - au début/fin
    }
    static normalizeCode(code) {
        return code
            .toLowerCase()
            .replace(/[^a-z0-9_]/g, '_') // Remplacer les caractères spéciaux par _
            .replace(/_+/g, '_') // Supprimer les _ multiples
            .replace(/^_|_$/g, ''); // Supprimer les _ au début/fin
    }
    static isValidSlug(slug) {
        return /^[a-z0-9-]+$/.test(slug);
    }
    static isValidCode(code) {
        return /^[a-z_]+$/.test(code);
    }
}
