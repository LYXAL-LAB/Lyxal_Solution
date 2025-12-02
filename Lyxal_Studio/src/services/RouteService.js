import { SurrealClient } from './SurrealClient';
import { SystemConfigService } from './SystemConfigService';
/**
 * Récupère la configuration DB pour SurrealClient
 */
async function getDatabaseConfig() {
    const systemConfig = new SystemConfigService();
    const [dbUrl, namespace, database, username, password] = await Promise.all([
        systemConfig.getConfig('infrastructure', 'surrealDbUrl'),
        systemConfig.getConfig('infrastructure', 'surrealNamespace'),
        systemConfig.getConfig('infrastructure', 'surrealDatabase'),
        systemConfig.getConfig('infrastructure', 'surrealUsername'),
        systemConfig.getConfig('infrastructure', 'surrealPassword'),
    ]);
    if (!dbUrl || !namespace || !database || !username || !password) {
        throw new Error('Database configuration incomplete');
    }
    return {
        infrastructure: {
            surrealDbUrl: { value: dbUrl },
            surrealNamespace: { value: namespace },
            surrealDatabase: { value: database },
            surrealUsername: { value: username },
            surrealPassword: { value: password },
        }
    };
}
import { validateRouteCreation, validateRouteUpdate } from '../lib/studio/routes/schemas/routeSchema';
/**
 * Service principal pour la gestion des routes dynamiques
 * Fournit toutes les opérations CRUD sur les routes en base de données
 */
export class RouteService {
    /**
     * Récupère toutes les routes actives
     */
    static async getActiveRoutes() {
        try {
            const config = await getDatabaseConfig();
            const query = `
        SELECT *,
               page.* as page
        FROM studio_route
        WHERE status = "active"
        ORDER BY metadata.order ASC, identity.value ASC
      `;
            console.log('[RouteService] 🔍 Loading active routes...');
            const result = await this.client.queryWithParams(config, query, {});
            if (!result || !Array.isArray(result)) {
                console.warn('[RouteService] No routes found or invalid result');
                return [];
            }
            console.log(`[RouteService] ✅ Loaded ${result.length} active routes`);
            return result;
        }
        catch (error) {
            console.error('[RouteService] Failed to load active routes:', error);
            throw new Error(`Failed to load active routes: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
    }
    /**
     * Récupère une route par son code
     */
    static async getRouteByCode(code) {
        try {
            const config = await getDatabaseConfig();
            const query = `
        SELECT *,
               page.* as page
        FROM studio_route
        WHERE identity.code = $code
        LIMIT 1
      `;
            console.log(`[RouteService] 🔍 Loading route by code: ${code}`);
            const result = await this.client.queryWithParams(config, query, { code });
            if (!result || !Array.isArray(result) || result.length === 0) {
                console.log(`[RouteService] Route not found: ${code}`);
                return null;
            }
            console.log(`[RouteService] ✅ Found route: ${code}`);
            return result[0];
        }
        catch (error) {
            console.error(`[RouteService] Failed to load route ${code}:`, error);
            throw new Error(`Failed to load route ${code}: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
    }
    /**
     * Récupère une route par son chemin
     */
    static async getRouteByPath(path) {
        try {
            const config = await getDatabaseConfig();
            const query = `
        SELECT *,
               page.* as page
        FROM studio_route
        WHERE identity.value = $path
        LIMIT 1
      `;
            console.log(`[RouteService] 🔍 Loading route by path: ${path}`);
            const result = await this.client.queryWithParams(config, query, { path });
            if (!result || !Array.isArray(result) || result.length === 0) {
                console.log(`[RouteService] Route not found: ${path}`);
                return null;
            }
            console.log(`[RouteService] ✅ Found route: ${path}`);
            return result[0];
        }
        catch (error) {
            console.error(`[RouteService] Failed to load route ${path}:`, error);
            throw new Error(`Failed to load route ${path}: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
    }
    /**
     * Récupère une route par son ID
     */
    static async getRouteById(id) {
        try {
            const config = await getDatabaseConfig();
            const query = `
        SELECT *,
               page.* as page
        FROM studio_route
        WHERE id = $id
        LIMIT 1
      `;
            console.log(`[RouteService] 🔍 Loading route by ID: ${id}`);
            const result = await this.client.queryWithParams(config, query, { id });
            if (!result || !Array.isArray(result) || result.length === 0) {
                console.log(`[RouteService] Route not found: ${id}`);
                return null;
            }
            console.log(`[RouteService] ✅ Found route: ${id}`);
            return result[0];
        }
        catch (error) {
            console.error(`[RouteService] Failed to load route ${id}:`, error);
            throw new Error(`Failed to load route ${id}: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
    }
    /**
     * Crée une nouvelle route
     */
    static async createRoute(input) {
        // Validation des données d'entrée
        const validation = validateRouteCreation(input);
        if (!validation.success) {
            throw new ValidationError('Invalid route data', validation.errors);
        }
        try {
            const config = await getDatabaseConfig();
            const query = `
        CREATE studio_route CONTENT {
          identity: $input.identity,
          page: $input.page,
          permissions: $input.permissions,
          guards: $input.guards,
          metadata: $input.metadata,
          status: $input.status,
          created_at: time::now(),
          updated_at: time::now(),
          etag: rand::string(32)
        }
      `;
            console.log('[RouteService] 🆕 Creating new route:', input.identity.code);
            const result = await this.client.queryWithParams(config, query, { input });
            if (!result || !Array.isArray(result) || result.length === 0) {
                throw new Error('Failed to create route - no result returned');
            }
            console.log(`[RouteService] ✅ Created route: ${input.identity.code}`);
            return result[0];
        }
        catch (error) {
            console.error('[RouteService] Failed to create route:', error);
            throw new Error(`Failed to create route: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
    }
    /**
     * Met à jour une route existante
     */
    static async updateRoute(id, input) {
        // Validation des données d'entrée
        const validation = validateRouteUpdate(input);
        if (!validation.success) {
            throw new ValidationError('Invalid route update data', validation.errors);
        }
        try {
            const config = await getDatabaseConfig();
            const query = `
        UPDATE $id SET {
          identity: $input.identity,
          page: $input.page,
          permissions: $input.permissions,
          guards: $input.guards,
          metadata: $input.metadata,
          status: $input.status,
          updated_at: time::now(),
          etag: rand::string(32)
        }
      `;
            console.log(`[RouteService] ✏️ Updating route: ${id}`);
            const result = await this.client.queryWithParams(config, query, { id, input });
            if (!result || !Array.isArray(result) || result.length === 0) {
                throw new Error('Failed to update route - no result returned');
            }
            console.log(`[RouteService] ✅ Updated route: ${id}`);
            return result[0];
        }
        catch (error) {
            console.error(`[RouteService] Failed to update route ${id}:`, error);
            throw new Error(`Failed to update route ${id}: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
    }
    /**
     * Supprime une route
     */
    static async deleteRoute(id) {
        try {
            const config = await getDatabaseConfig();
            const query = `DELETE $id`;
            console.log(`[RouteService] 🗑️ Deleting route: ${id}`);
            const result = await this.client.queryWithParams(config, query, { id });
            console.log(`[RouteService] ✅ Deleted route: ${id}`);
            return true;
        }
        catch (error) {
            console.error(`[RouteService] Failed to delete route ${id}:`, error);
            throw new Error(`Failed to delete route ${id}: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
    }
    /**
     * Change le statut d'une route
     */
    static async setRouteStatus(id, status) {
        try {
            const config = await getDatabaseConfig();
            const query = `
        UPDATE $id SET {
          status: $status,
          updated_at: time::now(),
          etag: rand::string(32)
        }
      `;
            console.log(`[RouteService] 🔄 Setting route ${id} status to: ${status}`);
            const result = await this.client.queryWithParams(config, query, { id, status });
            if (!result || !Array.isArray(result) || result.length === 0) {
                throw new Error('Failed to update route status - no result returned');
            }
            console.log(`[RouteService] ✅ Updated route ${id} status to: ${status}`);
            return result[0];
        }
        catch (error) {
            console.error(`[RouteService] Failed to update route ${id} status:`, error);
            throw new Error(`Failed to update route ${id} status: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
    }
}
RouteService.client = SurrealClient;
/**
 * Erreur de validation personnalisée
 */
export class ValidationError extends Error {
    constructor(message, errors = []) {
        super(message);
        this.errors = errors;
        this.name = 'ValidationError';
    }
}
