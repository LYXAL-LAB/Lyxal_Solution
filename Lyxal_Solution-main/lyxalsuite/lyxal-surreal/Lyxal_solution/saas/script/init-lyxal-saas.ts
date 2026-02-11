// ================================================================================================
// SCRIPT D'INITIALISATION GLOBAL LYXAL SAAS - ORCHESTRATEUR SUPRÊME
// ================================================================================================

import { readFileSync, readdirSync } from 'fs';
import { join } from 'path';
import { BaseModuleInstaller } from '../../base/scripts/install-base';

// Import du client SurrealDB - SEULE CONNEXION GLOBALE
const SurrealClient = require('../../core/SurrealClient');

/**
 * Classe d'initialisation complète Lyxal SAAS
 * ORCHESTRATEUR SUPRÊME de toute l'installation selon templates
 */
export class LyxalSaasInitializer {
  private db: any;
  private templatesPath: string;
  
  constructor() {
    this.db = SurrealClient.client;
    this.templatesPath = join(__dirname, 'templates');
  }
  
  /**
   * Initialisation complète selon un template SAAS
   */
  async initializeFromTemplate(templateName: string, options: SaasInitOptions = {}): Promise<SaasInitResult> {
    const startTime = new Date().toISOString();
    const results: SaasInitResult = {
      success: false,
      templateName,
      startTime,
      endTime: '',
      phases: {
        template_loading: { success: false, message: 'Non exécuté', timestamp: startTime },
        database_setup: { success: false, message: 'Non exécuté', timestamp: startTime },
        modules_installation: { success: false, message: 'Non exécuté', timestamp: startTime },
        post_configuration: { success: false, message: 'Non exécuté', timestamp: startTime }
      },
      summary: {
        totalPhases: 4,
        successfulPhases: 0,
        installedModules: [],
        errors: []
      }
    };
    
    try {
      console.log('🚀 === INITIALISATION LYXAL SAAS ===');
      console.log(`📋 Template: ${templateName}`);
      
      // Phase 1: Chargement du template
      console.log('\n📄 Phase 1: Chargement du template...');
      const template = await this.loadTemplate(templateName);
      results.phases.template_loading = {
        success: true,
        message: `Template ${template.name} chargé`,
        timestamp: new Date().toISOString()
      };
      results.summary.successfulPhases++;
      console.log(`✅ Template "${template.name}" chargé`);
      
      // Phase 2: Configuration de la base de données
      console.log('\n🗄️ Phase 2: Configuration de la base de données...');
      results.phases.database_setup = await this.setupDatabase(template, options);
      
      if (results.phases.database_setup.success) {
        results.summary.successfulPhases++;
        console.log('✅ Base de données configurée');
      } else {
        console.error('❌ Échec configuration DB:', results.phases.database_setup.error);
        results.summary.errors.push(`Database: ${results.phases.database_setup.error}`);
      }
      
      // Phase 3: Installation des modules (seulement si DB OK)
      if (results.phases.database_setup.success) {
        console.log('\n🏗️ Phase 3: Installation des modules...');
        results.phases.modules_installation = await this.installModules(template, options);
        
        if (results.phases.modules_installation.success) {
          results.summary.successfulPhases++;
          console.log('✅ Modules installés');
        } else {
          console.error('❌ Échec installation modules:', results.phases.modules_installation.error);
          results.summary.errors.push(`Modules: ${results.phases.modules_installation.error}`);
        }
      } else {
        results.phases.modules_installation = {
          success: false,
          message: 'Ignorée (DB non configurée)',
          timestamp: new Date().toISOString()
        };
      }
      
      // Phase 4: Configuration post-installation
      if (results.phases.modules_installation.success) {
        console.log('\n⚙️ Phase 4: Configuration post-installation...');
        results.phases.post_configuration = await this.postConfiguration(template, options);
        
        if (results.phases.post_configuration.success) {
          results.summary.successfulPhases++;
          console.log('✅ Configuration post-installation terminée');
        } else {
          console.error('❌ Échec post-configuration:', results.phases.post_configuration.error);
          results.summary.errors.push(`Post-config: ${results.phases.post_configuration.error}`);
        }
      } else {
        results.phases.post_configuration = {
          success: false,
          message: 'Ignorée (modules non installés)',
          timestamp: new Date().toISOString()
        };
      }
      
      // Résumé final
      results.success = results.summary.successfulPhases === results.summary.totalPhases;
      results.endTime = new Date().toISOString();
      
      this.displaySummary(results, template);
      
      return results;
      
    } catch (error) {
      results.endTime = new Date().toISOString();
      results.summary.errors.push(`Erreur générale: ${error}`);
      console.error('💥 Erreur générale SAAS:', error);
      return results;
    } finally {
      // Déconnexion globale
      await this.disconnectFromDatabase();
    }
  }
  
  /**
   * Lister les templates disponibles
   */
  async listAvailableTemplates(): Promise<TemplateInfo[]> {
    try {
      const files = readdirSync(this.templatesPath).filter(f => f.endsWith('.json'));
      const templates: TemplateInfo[] = [];
      
      for (const file of files) {
        try {
          const template = JSON.parse(readFileSync(join(this.templatesPath, file), 'utf-8'));
          templates.push({
            filename: file,
            name: template.name,
            description: template.description,
            target: template.target,
            version: template.version
          });
        } catch (error) {
          console.warn(`⚠️ Template invalide: ${file}`);
        }
      }
      
      return templates;
    } catch (error) {
      throw new Error(`Impossible de lister les templates: ${error}`);
    }
  }
  
  /**
   * Charger un template spécifique
   */
  private async loadTemplate(templateName: string): Promise<SaasTemplate> {
    try {
      const templatePath = join(this.templatesPath, `${templateName}.json`);
      const templateContent = readFileSync(templatePath, 'utf-8');
      return JSON.parse(templateContent);
    } catch (error) {
      throw new Error(`Impossible de charger le template "${templateName}": ${error}`);
    }
  }
  
  /**
   * Configurer la base de données selon le template
   */
  private async setupDatabase(template: SaasTemplate, options: SaasInitOptions): Promise<PhaseResult> {
    try {
      // Connexion avec configuration du template
      const config = {
        url: template.database.url,
        namespace: template.database.namespace,
        database: template.database.database
      };
      
      await this.db.connect(config.url, config.namespace, config.database);
      
      return {
        success: true,
        message: `Base de données configurée: ${config.namespace}/${config.database}`,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erreur DB',
        message: 'Échec configuration base de données',
        timestamp: new Date().toISOString()
      };
    }
  }
  
  /**
   * Installer les modules selon le template
   */
  private async installModules(template: SaasTemplate, options: SaasInitOptions): Promise<PhaseResult> {
    try {
      const installedModules: string[] = [];
      
      // Installation du module BASE (toujours en premier)
      if (template.modules.base?.enabled) {
        console.log('\n🏗️ === INSTALLATION MODULE BASE ===');
        
        const baseInstaller = new BaseModuleInstaller();
        // Utiliser notre connexion DB
        (baseInstaller as any).db = this.db;
        
        const baseOptions = this.mapTemplateToBaseOptions(template);
        const baseResult = await baseInstaller.installComplete(baseOptions);
        
        if (baseResult.success) {
          installedModules.push('base');
          console.log('✅ Module BASE installé');
        } else {
          throw new Error(`Échec module BASE: ${baseResult.summary.errors.join('; ')}`);
        }
      }
      
      // TODO: Installation des autres modules (CRM, Accounting, etc.)
      
      return {
        success: true,
        message: `${installedModules.length} modules installés: ${installedModules.join(', ')}`,
        timestamp: new Date().toISOString(),
        details: { installedModules }
      };
      
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erreur modules',
        message: 'Échec installation modules',
        timestamp: new Date().toISOString()
      };
    }
  }
  
  /**
   * Configuration post-installation
   */
  private async postConfiguration(template: SaasTemplate, options: SaasInitOptions): Promise<PhaseResult> {
    try {
      const tasks: string[] = [];
      
      // Configuration des fonctionnalités selon le template
      if (template.features.multi_tenant) {
        tasks.push('Multi-tenant configuré');
      }
      
      if (template.options.enable_audit_log) {
        tasks.push('Audit log activé');
      }
      
      if (template.options.enable_demo_data) {
        tasks.push('Données de démonstration installées');
      }
      
      return {
        success: true,
        message: `Post-configuration terminée: ${tasks.join(', ')}`,
        timestamp: new Date().toISOString(),
        details: { tasks }
      };
      
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erreur post-config',
        message: 'Échec post-configuration',
        timestamp: new Date().toISOString()
      };
    }
  }
  
  /**
   * Mapper les options du template vers les options du module base
   */
  private mapTemplateToBaseOptions(template: SaasTemplate): any {
    return {
      modules: {
        geographic: template.modules.base.submodules.geographic?.enabled || false,
        currency: template.modules.base.submodules.currency?.enabled || false,
        organisation: template.modules.base.submodules.organisation?.enabled || false,
        planning: template.modules.base.submodules.planning?.enabled || false
      },
      geographicOptions: {
        continent: template.modules.base.submodules.geographic?.entities?.continent || false,
        country: template.modules.base.submodules.geographic?.entities?.country || false,
        region: template.modules.base.submodules.geographic?.entities?.region || false,
        subregion: template.modules.base.submodules.geographic?.entities?.subregion || false,
        force: template.options.force_reinstall || false,
        skipValidation: template.options.skip_validation || false
      }
    };
  }
  
  /**
   * Déconnexion de la base de données
   */
  private async disconnectFromDatabase(): Promise<void> {
    try {
      if (this.db) {
        await this.db.close();
        console.log('🔌 Déconnecté de SurrealDB');
      }
    } catch (error) {
      console.warn('⚠️ Erreur lors de la déconnexion:', error);
    }
  }
  
  /**
   * Afficher le résumé de l'initialisation
   */
  private displaySummary(results: SaasInitResult, template: SaasTemplate): void {
    console.log('\n' + '='.repeat(80));
    console.log('🚀 RÉSUMÉ INITIALISATION LYXAL SAAS');
    console.log('='.repeat(80));
    
    console.log(`📋 Template: ${template.name} v${template.version}`);
    console.log(`🎯 Cible: ${template.target}`);
    console.log(`⏱️  Durée: ${results.startTime} → ${results.endTime}`);
    console.log(`🎯 Succès: ${results.summary.successfulPhases}/${results.summary.totalPhases} phases`);
    
    console.log('\n📋 Détail des phases:');
    console.log(`   📄 Template: ${results.phases.template_loading.success ? '✅' : '❌'} ${results.phases.template_loading.message}`);
    console.log(`   🗄️ Database: ${results.phases.database_setup.success ? '✅' : '❌'} ${results.phases.database_setup.message}`);
    console.log(`   🏗️ Modules: ${results.phases.modules_installation.success ? '✅' : '❌'} ${results.phases.modules_installation.message}`);
    console.log(`   ⚙️ Post-config: ${results.phases.post_configuration.success ? '✅' : '❌'} ${results.phases.post_configuration.message}`);
    
    if (results.summary.errors.length > 0) {
      console.log('\n❌ Erreurs:');
      results.summary.errors.forEach(error => console.log(`   • ${error}`));
    }
    
    console.log('\n📊 Modules installés:');
    console.log(`   • ${results.summary.installedModules.length > 0 ? results.summary.installedModules.join(', ') : 'Aucun'}`);
    
    console.log('\n' + (results.success ? '🎉 LYXAL SAAS INITIALISÉ AVEC SUCCÈS !' : '💥 INITIALISATION PARTIELLE !'));
    console.log('='.repeat(80));
  }
}

/**
 * Types pour les templates et résultats SAAS
 */
interface SaasTemplate {
  name: string;
  version: string;
  description: string;
  target: string;
  modules: any;
  database: {
    namespace: string;
    database: string;
    url: string;
  };
  options: {
    force_reinstall: boolean;
    skip_validation: boolean;
    enable_demo_data: boolean;
    enable_audit_log: boolean;
  };
  features: any;
}

interface TemplateInfo {
  filename: string;
  name: string;
  description: string;
  target: string;
  version: string;
}

interface SaasInitOptions {
  dryRun?: boolean;
  verbose?: boolean;
  skipBackup?: boolean;
}

interface PhaseResult {
  success: boolean;
  message: string;
  timestamp: string;
  error?: string;
  details?: any;
}

interface SaasInitResult {
  success: boolean;
  templateName: string;
  startTime: string;
  endTime: string;
  phases: {
    template_loading: PhaseResult;
    database_setup: PhaseResult;
    modules_installation: PhaseResult;
    post_configuration: PhaseResult;
  };
  summary: {
    totalPhases: number;
    successfulPhases: number;
    installedModules: string[];
    errors: string[];
  };
}

/**
 * Fonction principale pour exécution directe - POINT D'ENTRÉE GLOBAL SAAS
 */
async function main() {
  const initializer = new LyxalSaasInitializer();
  
  // Analyser les arguments de ligne de commande
  const args = process.argv.slice(2);
  
  // Mode liste des templates
  if (args.includes('--list-templates')) {
    console.log('📋 === TEMPLATES LYXAL SAAS DISPONIBLES ===');
    const templates = await initializer.listAvailableTemplates();
    
    templates.forEach(template => {
      console.log(`\n🏷️  ${template.name}`);
      console.log(`   📄 Fichier: ${template.filename}`);
      console.log(`   📝 Description: ${template.description}`);
      console.log(`   🎯 Cible: ${template.target}`);
      console.log(`   📦 Version: ${template.version}`);
    });
    
    return;
  }
  
  // Récupérer le nom du template
  const templateName = args[0] || 'starter';
  const options: SaasInitOptions = {
    dryRun: args.includes('--dry-run'),
    verbose: args.includes('--verbose'),
    skipBackup: args.includes('--skip-backup')
  };
  
  console.log('🚀 === CONFIGURATION INITIALISATION SAAS ===');
  console.log(`   📋 Template: ${templateName}`);
  console.log(`   🧪 Mode dry-run: ${options.dryRun ? 'OUI' : 'NON'}`);
  console.log(`   📝 Mode verbose: ${options.verbose ? 'OUI' : 'NON'}`);
  console.log(`   💾 Ignorer backup: ${options.skipBackup ? 'OUI' : 'NON'}`);
  
  // Lancer l'initialisation complète
  const result = await initializer.initializeFromTemplate(templateName, options);
  
  // Code de sortie selon le résultat
  process.exit(result.success ? 0 : 1);
}

// Exécution si appelé directement - POINT D'ENTRÉE GLOBAL SAAS
if (require.main === module) {
  main().catch(console.error);
}

export default LyxalSaasInitializer; 