import { readFileSync } from 'fs';
import { join } from 'path';
import { BaseSurrealClient } from './baseSurrealClient';
import type { SurrealConfig } from './types';

/**
 * 🚀 DÉPLOYEUR MASTER - Exécution des fichiers .surql
 * 
 * Responsabilités :
 * - Lecture des fichiers .surql depuis le filesystem
 * - Exécution dans SurrealDB avec le bon namespace/database
 * - Gestion des erreurs et logging
 * - Support de déploiement séquentiel (ordre important)
 */
export class MasterDeployer {
  private client: BaseSurrealClient;
  private deploymentPath: string;

  constructor(config: SurrealConfig, deploymentPath?: string) {
    this.client = new BaseSurrealClient(config);
    this.deploymentPath = deploymentPath || join(process.cwd(), 'lyxalsuite/lyxal-surreal/database/modules/config/level-0-master');
  }

  /**
   * 📁 Lire un fichier .surql depuis le filesystem
   */
  private readSurqlFile(filename: string): string {
    try {
      const filepath = join(this.deploymentPath, filename);
      const content = readFileSync(filepath, 'utf-8');
      console.log(`✅ Fichier lu: ${filename} (${content.length} caractères)`);
      return content;
    } catch (error) {
      console.error(`❌ Erreur lecture fichier ${filename}:`, error);
      throw new Error(`Impossible de lire le fichier ${filename}: ${error}`);
    }
  }

  /**
   * 🎯 Exécuter un fichier .surql dans SurrealDB
   */
  private async executeSurqlFile(filename: string, namespace: string, database: string): Promise<void> {
    try {
      console.log(`🚀 Déploiement ${filename} dans NS ${namespace} DB ${database}...`);

      // 1. Connexion et sélection du namespace/database
      await this.client.connect();
      await this.client.use(namespace, database);

      // 2. Lecture du fichier
      const sqlContent = this.readSurqlFile(filename);

      // 3. Exécution du contenu SQL
      const result = await this.client.query(sqlContent);
      
      console.log(`✅ ${filename} déployé avec succès`);
      console.log(`📊 Résultat:`, result?.length || 0, 'instructions exécutées');

    } catch (error) {
      console.error(`❌ Erreur déploiement ${filename}:`, error);
      throw new Error(`Échec déploiement ${filename}: ${error}`);
    }
  }

  /**
   * 🏛️ Déployer un MASTER complet (fichier fusionné)
   */
  async deployMasterComplete(masterConfig: {
    masterName: string;          // Ex: "primary", "restaurant_pro", "ecommerce_suite"
    platformName?: string;       // Ex: "LYXAL", "LYXAL_RESTAURANT_PRO"
    environment?: string;        // Ex: "production", "staging"
  }): Promise<void> {
    const namespace = masterConfig.masterName === 'primary' 
      ? 'lyxal_master' 
      : `master_${masterConfig.masterName}`;
    
    const database = 'platform_control';

    console.log(`\n🎯 === DÉPLOIEMENT MASTER: ${masterConfig.masterName.toUpperCase()} ===`);
    console.log(`📍 Namespace: ${namespace}`);
    console.log(`📍 Database: ${database}`);
    console.log(`📍 Plateforme: ${masterConfig.platformName || 'LYXAL'}`);

    try {
      // Étape 1: Déploiement de la structure complète
      await this.executeSurqlFile('master_complete_structure.surql', namespace, database);

      // Étape 2: Insertion des données initiales  
      await this.executeSurqlFile('master_system_data.surql', namespace, database);

      // Étape 3: Création des fonctions métier
      await this.executeSurqlFile('master_system_functions.surql', namespace, database);

      // Étape 4: Personnalisation si ce n'est pas le master primary
      if (masterConfig.masterName !== 'primary') {
        await this.customizeMasterForClient(namespace, database, masterConfig);
      }

      console.log(`\n🎉 === DÉPLOIEMENT MASTER TERMINÉ AVEC SUCCÈS ===`);
      console.log(`✅ Master "${masterConfig.masterName}" opérationnel !`);
      console.log(`🌐 Namespace: ${namespace}`);

    } catch (error) {
      console.error(`\n💥 === ÉCHEC DÉPLOIEMENT MASTER ===`);
      console.error(`❌ Master: ${masterConfig.masterName}`);
      console.error(`❌ Erreur:`, error);
      throw error;
    } finally {
      await this.client.disconnect();
    }
  }

  /**
   * 🎨 Personnaliser un MASTER pour un client commercial
   */
  private async customizeMasterForClient(
    namespace: string, 
    database: string, 
    config: { masterName: string; platformName?: string; environment?: string }
  ): Promise<void> {
    console.log(`🎨 Personnalisation MASTER pour client...`);

    const customizations = `
      -- Personnalisation du MASTER ${config.masterName}
      UPDATE system_identity SET 
        platform_name = "${config.platformName || 'LYXAL_' + config.masterName.toUpperCase()}",
        platform_id = "${config.masterName}-master-001",
        environment = "${config.environment || 'production'}",
        updated_at = time::now();

      UPDATE system_infrastructure SET
        surreal_namespace = "${namespace}",
        surreal_database = "${database}",
        updated_at = time::now();
    `;

    await this.client.query(customizations);
    console.log(`✅ Personnalisation appliquée`);
  }

  /**
   * 🔄 Déploiement en série (plusieurs MASTER)
   */
  async deployMultipleMasters(masterConfigs: Array<{
    masterName: string;
    platformName?: string;
    environment?: string;
  }>): Promise<void> {
    console.log(`\n🚀 === DÉPLOIEMENT MULTI-MASTER ===`);
    console.log(`📊 Nombre de MASTER à déployer: ${masterConfigs.length}`);

    for (let i = 0; i < masterConfigs.length; i++) {
      const config = masterConfigs[i];
      console.log(`\n📍 [${i + 1}/${masterConfigs.length}] Déploiement: ${config.masterName}`);
      
      try {
        await this.deployMasterComplete(config);
        console.log(`✅ [${i + 1}/${masterConfigs.length}] ${config.masterName} déployé`);
      } catch (error) {
        console.error(`❌ [${i + 1}/${masterConfigs.length}] Échec ${config.masterName}:`, error);
        throw error; // Arrêter le déploiement en cas d'erreur
      }
    }

    console.log(`\n🎉 === TOUS LES MASTER DÉPLOYÉS AVEC SUCCÈS ===`);
  }

  /**
   * 🔧 Utilitaire : Vérifier l'état d'un MASTER
   */
  async checkMasterStatus(masterName: string): Promise<{
    exists: boolean;
    namespace: string;
    tablesCount: number;
    lastUpdate: string;
  }> {
    const namespace = masterName === 'primary' ? 'lyxal_master' : `master_${masterName}`;
    
    try {
      await this.client.connect();
      await this.client.use(namespace, 'platform_control');

      const tables = await this.client.query('INFO FOR DB;');
      const identity = await this.client.query('SELECT * FROM system_identity LIMIT 1;');

      return {
        exists: true,
        namespace,
        tablesCount: Object.keys(tables[0]?.tables || {}).length,
        lastUpdate: identity[0]?.updatedAt || 'Inconnu'
      };
    } catch (error) {
      return {
        exists: false,
        namespace,
        tablesCount: 0,
        lastUpdate: 'N/A'
      };
    } finally {
      await this.client.disconnect();
    }
  }
}

/**
 * 🎯 FONCTION UTILITAIRE RAPIDE
 */
export async function deployMaster(
  config: SurrealConfig,
  masterName: string,
  platformName?: string
): Promise<void> {
  const deployer = new MasterDeployer(config);
  await deployer.deployMasterComplete({
    masterName,
    platformName,
    environment: 'production'
  });
}

/**
 * 🎯 EXEMPLES D'UTILISATION
 */
export const masterDeploymentExamples = {
  // Déploiement MASTER primaire
  primary: async (config: SurrealConfig) => {
    await deployMaster(config, 'primary', 'LYXAL');
  },

  // Déploiement MASTER commercial restaurant
  restaurantPro: async (config: SurrealConfig) => {
    await deployMaster(config, 'restaurant_pro', 'LYXAL_RESTAURANT_PRO');
  },

  // Déploiement MASTER commercial e-commerce  
  ecommerceSuite: async (config: SurrealConfig) => {
    await deployMaster(config, 'ecommerce_suite', 'LYXAL_ECOMMERCE_SUITE');
  },

  // Déploiement multiple
  multipleCommercial: async (config: SurrealConfig) => {
    const deployer = new MasterDeployer(config);
    await deployer.deployMultipleMasters([
      { masterName: 'restaurant_pro', platformName: 'LYXAL_RESTAURANT_PRO' },
      { masterName: 'ecommerce_suite', platformName: 'LYXAL_ECOMMERCE_SUITE' },
      { masterName: 'legal_office', platformName: 'LYXAL_LEGAL_OFFICE' }
    ]);
  }
}; 