import type {
  CreateMasterPlatformData,
  CreateMasterPlatformResponse,
  UpdateMasterConfigResponse,
  SystemIdentity,
  SystemInfrastructure,
  SystemConfigMetadata,
  Environment,
  DaisyUITheme,
  ValidationResult,
  MasterValidationRules
} from '../core/types';
import { BaseSurrealClient } from '../core/baseSurrealClient';

/**
 * Client spécialisé pour le niveau 0 MASTER
 * 
 * Responsabilités :
 * - Gestion des plateformes MASTER
 * - Configuration identité et infrastructure
 * - Historique et audit des modifications
 * - Validation des données MASTER
 */
export class Level0MasterClient {
  private baseClient: BaseSurrealClient;

  constructor(baseClient: BaseSurrealClient) {
    this.baseClient = baseClient;
  }

  // ==========================================
  // NAVIGATION NIVEAU MASTER
  // ==========================================

  /**
   * Utiliser le niveau MASTER (namespace et database par défaut)
   */
  public async useMasterLevel(): Promise<void> {
    const config = this.baseClient.getDefaultConfig();
    await this.baseClient.use(config.namespace, config.database);
  }

  /**
   * Vérifier si le niveau MASTER est configuré
   */
  public async isMasterLevelConfigured(): Promise<boolean> {
    try {
      await this.useMasterLevel();
      const result = await this.baseClient.query('SELECT * FROM system_identity LIMIT 1');
      return result[0] && (result[0] as any[]).length > 0;
    } catch (error) {
      return false;
    }
  }

  // ==========================================
  // VALIDATION DONNÉES MASTER
  // ==========================================

  /**
   * Règles de validation par défaut pour MASTER
   */
  private getValidationRules(): MasterValidationRules {
    return {
      platform_name: {
        minLength: 2,
        maxLength: 100,
        pattern: /^[a-zA-Z0-9\s_-]+$/
      },
      platform_id: {
        minLength: 5,
        maxLength: 50,
        pattern: /^[a-zA-Z0-9_-]+$/
      },
      surreal_db_url: {
        pattern: /^wss?:\/\/.+\/rpc$/
      },
      surreal_namespace: {
        minLength: 3,
        pattern: /^[a-zA-Z0-9_-]+$/
      },
      passwords: {
        minLength: 6
      }
    };
  }

  /**
   * Valider les données de création d'une plateforme MASTER
   */
  public validateMasterPlatformData(data: CreateMasterPlatformData): ValidationResult {
    const rules = this.getValidationRules();
    const errors: string[] = [];
    const warnings: string[] = [];

    // Validation platform_name
    if (!data.platform_name || data.platform_name.length < rules.platform_name.minLength) {
      errors.push(`Le nom de la plateforme doit contenir au moins ${rules.platform_name.minLength} caractères`);
    }
    if (data.platform_name && data.platform_name.length > rules.platform_name.maxLength) {
      errors.push(`Le nom de la plateforme ne peut pas dépasser ${rules.platform_name.maxLength} caractères`);
    }
    if (data.platform_name && !rules.platform_name.pattern?.test(data.platform_name)) {
      errors.push('Le nom de la plateforme ne peut contenir que des lettres, chiffres, espaces, tirets et underscores');
    }

    // Validation platform_id
    if (!data.platform_id || data.platform_id.length < rules.platform_id.minLength) {
      errors.push(`L'ID de la plateforme doit contenir au moins ${rules.platform_id.minLength} caractères`);
    }
    if (data.platform_id && !rules.platform_id.pattern.test(data.platform_id)) {
      errors.push('L\'ID de la plateforme ne peut contenir que des lettres, chiffres, tirets et underscores');
    }

    // Validation URLs
    if (!data.surreal_db_url || !rules.surreal_db_url.pattern.test(data.surreal_db_url)) {
      errors.push('L\'URL SurrealDB doit commencer par ws:// ou wss:// et se terminer par /rpc');
    }
    if (!data.logto_master_endpoint || !data.logto_master_endpoint.startsWith('https://')) {
      errors.push('L\'endpoint Logto doit commencer par https://');
    }
    if (!data.api_base_url || !data.api_base_url.startsWith('https://')) {
      errors.push('L\'URL de l\'API doit commencer par https://');
    }

    // Validation namespace
    if (!data.surreal_namespace || data.surreal_namespace.length < rules.surreal_namespace.minLength) {
      errors.push(`Le namespace SurrealDB doit contenir au moins ${rules.surreal_namespace.minLength} caractères`);
    }
    if (data.surreal_namespace && !rules.surreal_namespace.pattern.test(data.surreal_namespace)) {
      errors.push('Le namespace SurrealDB ne peut contenir que des lettres, chiffres, tirets et underscores');
    }

    // Validation mots de passe
    if (!data.surreal_password || data.surreal_password.length < rules.passwords.minLength) {
      errors.push(`Le mot de passe SurrealDB doit contenir au moins ${rules.passwords.minLength} caractères`);
    }

    // Validation champs requis
    const requiredFields = [
      'surreal_database', 'surreal_username', 'logto_admin_app_id'
    ];
    
    for (const field of requiredFields) {
      if (!data[field as keyof CreateMasterPlatformData]) {
        errors.push(`Le champ ${field} est requis`);
      }
    }

    // Warnings pour sécurité
    if (data.environment === 'production' && data.surreal_password && data.surreal_password.length < 12) {
      warnings.push('Pour la production, un mot de passe de 12+ caractères est recommandé');
    }

    return {
      isValid: errors.length === 0,
      errors,
      warnings
    };
  }

  // ==========================================
  // GESTION PLATEFORMES MASTER
  // ==========================================

  /**
   * Créer une nouvelle plateforme MASTER
   */
  public async createMasterPlatform(data: CreateMasterPlatformData): Promise<CreateMasterPlatformResponse> {
    // 1. Validation des données
    const validation = this.validateMasterPlatformData(data);
    if (!validation.isValid) {
      throw new Error(`Données invalides: ${validation.errors.join(', ')}`);
    }

    // 2. Navigation vers le niveau MASTER
    await this.useMasterLevel();

    // 3. Appel de la fonction SurrealDB
    try {
      const result = await this.baseClient.query(`
        RETURN fn::create_master_platform($data);
      `, { data });

      if (!result[0] || !result[0].success) {
        throw new Error(result[0]?.message || 'Erreur lors de la création de la plateforme');
      }

      // 4. Invalider les caches pertinents
      this.baseClient.invalidateCache('master_platform:*');
      this.baseClient.invalidateCache('system_identity:*');
      this.baseClient.invalidateCache('system_infrastructure:*');

      return result[0] as CreateMasterPlatformResponse;
    } catch (error) {
      console.error('Erreur lors de la création de la plateforme MASTER:', error);
      throw error;
    }
  }

  /**
   * Mettre à jour une configuration MASTER
   */
  public async updateMasterConfig(
    tableName: 'system_identity' | 'system_infrastructure',
    fieldName: string,
    newValue: string,
    platformId: string,
    changedBy: string,
    reason?: string
  ): Promise<UpdateMasterConfigResponse> {
    await this.useMasterLevel();

    try {
      const result = await this.baseClient.query(`
        RETURN fn::update_master_config($table, $field, $value, $id, $user, $reason);
      `, {
        table: tableName,
        field: fieldName,
        value: newValue,
        id: platformId,
        user: changedBy,
        reason: reason || 'Mise à jour configuration'
      });

      if (!result[0] || !result[0].success) {
        throw new Error(result[0]?.message || 'Erreur lors de la mise à jour');
      }

      // Invalider les caches
      this.baseClient.invalidateCache(`${tableName}:*`);
      this.baseClient.invalidateCache('master_platform:*');

      return result[0] as UpdateMasterConfigResponse;
    } catch (error) {
      console.error('Erreur lors de la mise à jour de la configuration MASTER:', error);
      throw error;
    }
  }

  /**
   * Récupérer une plateforme MASTER complète
   */
  public async getMasterPlatform(platformId: string): Promise<{
    identity: SystemIdentity;
    infrastructure: SystemInfrastructure;
  }> {
    await this.useMasterLevel();

    try {
      const result = await this.baseClient.cachedQuery(`
        RETURN fn::get_master_platform($id);
      `, { id: platformId }, `master_platform:${platformId}`, 5 * 60 * 1000); // Cache 5 minutes

      if (!result[0] || !result[0].success) {
        throw new Error(result[0]?.message || 'Plateforme non trouvée');
      }

      return result[0].data;
    } catch (error) {
      console.error('Erreur lors de la récupération de la plateforme MASTER:', error);
      throw error;
    }
  }

  /**
   * Lister toutes les plateformes MASTER
   */
  public async listMasterPlatforms(): Promise<{
    identities: SystemIdentity[];
    infrastructures: SystemInfrastructure[];
  }> {
    await this.useMasterLevel();

    try {
      const [identityResult, infrastructureResult] = await Promise.all([
        this.baseClient.cachedQuery('SELECT * FROM system_identity', {}, 'all_identities', 2 * 60 * 1000),
        this.baseClient.cachedQuery('SELECT * FROM system_infrastructure', {}, 'all_infrastructures', 2 * 60 * 1000)
      ]);

      return {
        identities: identityResult[0] as SystemIdentity[],
        infrastructures: infrastructureResult[0] as SystemInfrastructure[]
      };
    } catch (error) {
      console.error('Erreur lors de la liste des plateformes MASTER:', error);
      throw error;
    }
  }

  /**
   * Supprimer une plateforme MASTER (avec confirmation)
   */
  public async deleteMasterPlatform(
    platformId: string,
    confirmation: string,
    deletedBy: string
  ): Promise<{ success: boolean; message: string }> {
    if (confirmation !== 'DELETE_CONFIRMED') {
      throw new Error('Confirmation requise avec "DELETE_CONFIRMED"');
    }

    await this.useMasterLevel();

    try {
      const result = await this.baseClient.query(`
        RETURN fn::delete_master_platform($id, $confirmation, $user);
      `, {
        id: platformId,
        confirmation,
        user: deletedBy
      });

      if (!result[0] || !result[0].success) {
        throw new Error(result[0]?.message || 'Erreur lors de la suppression');
      }

      // Invalider tous les caches liés
      this.baseClient.invalidateCache('master_platform:*');
      this.baseClient.invalidateCache('system_identity:*');
      this.baseClient.invalidateCache('system_infrastructure:*');

      return result[0];
    } catch (error) {
      console.error('Erreur lors de la suppression de la plateforme MASTER:', error);
      throw error;
    }
  }

  // ==========================================
  // GESTION CONFIGURATION SYSTÈME
  // ==========================================

  /**
   * Mettre à jour le thème par défaut
   */
  public async updateDefaultTheme(
    platformId: string,
    newTheme: DaisyUITheme,
    changedBy: string
  ): Promise<UpdateMasterConfigResponse> {
    return await this.updateMasterConfig(
      'system_identity',
      'theme_par_defaut',
      newTheme,
      platformId,
      changedBy,
      'Changement de thème par défaut'
    );
  }

  /**
   * Mettre à jour l'environnement
   */
  public async updateEnvironment(
    platformId: string,
    newEnvironment: Environment,
    changedBy: string
  ): Promise<UpdateMasterConfigResponse> {
    return await this.updateMasterConfig(
      'system_identity',
      'environment',
      newEnvironment,
      platformId,
      changedBy,
      'Changement d\'environnement'
    );
  }

  /**
   * Mettre à jour l'URL SurrealDB
   */
  public async updateSurrealDbUrl(
    platformId: string,
    newUrl: string,
    changedBy: string
  ): Promise<UpdateMasterConfigResponse> {
    // Validation de l'URL
    if (!newUrl.match(/^wss?:\/\/.+\/rpc$/)) {
      throw new Error('URL SurrealDB invalide - doit commencer par ws:// ou wss:// et se terminer par /rpc');
    }

    return await this.updateMasterConfig(
      'system_infrastructure',
      'surreal_db_url',
      newUrl,
      platformId,
      changedBy,
      'Changement d\'URL SurrealDB'
    );
  }

  // ==========================================
  // HISTORIQUE ET AUDIT
  // ==========================================

  /**
   * Récupérer l'historique des modifications
   */
  public async getConfigHistory(
    tableName?: 'system_identity' | 'system_infrastructure',
    limit: number = 50
  ): Promise<SystemConfigMetadata[]> {
    await this.useMasterLevel();

    let query = 'SELECT * FROM system_config_metadata';
    const conditions: string[] = [];
    const vars: Record<string, any> = { limit };

    if (tableName) {
      conditions.push('table_name = $tableName');
      vars.tableName = tableName;
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY changed_at DESC LIMIT $limit';

    try {
      const result = await this.baseClient.cachedQuery(
        query,
        vars,
        `config_history:${tableName || 'all'}:${limit}`,
        60 * 1000 // Cache 1 minute
      );

      return result[0] as SystemConfigMetadata[];
    } catch (error) {
      console.error('Erreur lors de la récupération de l\'historique:', error);
      throw error;
    }
  }

  /**
   * Obtenir les statistiques d'utilisation
   */
  public async getMasterStats(): Promise<{
    totalPlatforms: number;
    totalConfigChanges: number;
    lastActivity: Date | null;
    environmentDistribution: Record<Environment, number>;
  }> {
    await this.useMasterLevel();

    try {
      const [platformsResult, changesResult, lastActivityResult, envResult] = await Promise.all([
        this.baseClient.cachedQuery('SELECT COUNT() as total FROM system_identity', {}, 'master_stats:platforms', 5 * 60 * 1000),
        this.baseClient.cachedQuery('SELECT COUNT() as total FROM system_config_metadata', {}, 'master_stats:changes', 5 * 60 * 1000),
        this.baseClient.cachedQuery('SELECT changed_at FROM system_config_metadata ORDER BY changed_at DESC LIMIT 1', {}, 'master_stats:last_activity', 60 * 1000),
        this.baseClient.cachedQuery('SELECT environment, COUNT() as count FROM system_identity GROUP BY environment', {}, 'master_stats:env_dist', 5 * 60 * 1000)
      ]);

      const environmentDistribution: Record<Environment, number> = {
        dev: 0,
        staging: 0,
        production: 0
      };

      if (envResult[0]) {
        for (const env of envResult[0] as any[]) {
          environmentDistribution[env.environment as Environment] = env.count;
        }
      }

      return {
        totalPlatforms: platformsResult[0]?.[0]?.total || 0,
        totalConfigChanges: changesResult[0]?.[0]?.total || 0,
        lastActivity: lastActivityResult[0]?.[0]?.changed_at || null,
        environmentDistribution
      };
    } catch (error) {
      console.error('Erreur lors de la récupération des statistiques MASTER:', error);
      throw error;
    }
  }
} 