// Importeur générique de fichiers .surql (ordre: system -> builder -> deploy)
// Utilise la lib 'surrealdb' (RPC WebSocket), sans modifier les fichiers importés

import Surreal from 'surrealdb';
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DEFAULTS = {
  URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  USER: 'admin',
  PASS: 'admin',
  NS: 'Lyxal_Solution',
  DB: 'Labs',
  ROOT: path.resolve(__dirname, 'Lyxal_Surreal'),
};

const CONFIG = {
  url: process.env.SURREALDB_URL || DEFAULTS.URL,
  user: process.env.SURREALDB_USER || DEFAULTS.USER,
  pass: process.env.SURREALDB_PASS || DEFAULTS.PASS,
  ns: process.env.SURREALDB_NS || DEFAULTS.NS,
  db: process.env.SURREALDB_DB || DEFAULTS.DB,
  root: process.env.ROOT_SURQL_DIR || DEFAULTS.ROOT,
};

const EXCLUDE_FILES = new Set(['system_log_live_queries.surql']);

async function listSurqlFiles(dir) {
  const out = [];
  async function walk(current) {
    const entries = await fs.readdir(current, { withFileTypes: true });
    for (const e of entries) {
      const p = path.join(current, e.name);
      if (e.isDirectory()) {
        await walk(p);
      } else if (e.isFile() && e.name.endsWith('.surql') && !EXCLUDE_FILES.has(e.name)) {
        out.push(p);
      }
    }
  }
  await walk(dir);
  return out.sort((a, b) => a.localeCompare(b));
}

async function main() {
  const db = new Surreal();
  try {
    console.log('Connexion à', CONFIG.url);
    await db.connect(CONFIG.url);
    await db.signin({ username: CONFIG.user, password: CONFIG.pass });

    // Sélection du mode (base|saas)
    const mode = (process.env.MODE || 'base').toLowerCase();
    console.log('Mode:', mode);

    // Génération stricte d'un namespace unique (mode saas) ou usage du namespace de base
    const makeRandomNs = () => `saas_${crypto.randomUUID().replace(/-/g, '')}`;
    let selectedNs = mode === 'saas' ? makeRandomNs() : CONFIG.ns;
    const nsLabel = mode === 'saas' ? 'SaaS' : 'Namespace';
    console.log(nsLabel + ' cible:', selectedNs, mode === 'saas' ? '(généré)' : '(config)');

    // Contrôle d'unicité fort: vérifier l'existence et régénérer si besoin (mode saas)
    async function namespaceExists(name) {
      try {
        const rootInfo = await db.query('INFO FOR ROOT;');
        const nsMap = rootInfo?.[0]?.result?.namespaces || {};
        return Object.prototype.hasOwnProperty.call(nsMap, name);
      } catch {
        return false;
      }
    }

    if (mode === 'saas') {
      // Tenter jusqu'à trouver un nom réellement inédit (collisions quasi impossibles, par sécurité)
      let attempts = 0;
      while (attempts < 10 && (await namespaceExists(selectedNs))) {
        selectedNs = makeRandomNs();
        attempts += 1;
      }
      if (await namespaceExists(selectedNs)) {
        throw new Error(`Impossible de générer un identifiant SaaS unique après ${attempts} tentatives`);
      }
    }

    // S'assurer que le namespace existe avant tout
    try {
      await db.query(`DEFINE NAMESPACE IF NOT EXISTS ${selectedNs};`);
    } catch (e) {
      console.warn('Impossible de définir le ' + nsLabel + ' (DEFINE NAMESPACE):', e?.message || e);
    }

    // Reconnexion pour valider la persistance du namespace côté serveur
    try {
      await db.close();
    } catch {}
    await db.connect(CONFIG.url);
    await db.signin({ username: CONFIG.user, password: CONFIG.pass });

    // Vérification après reconnexion
    try {
      const rootInfoAfter = await db.query('INFO FOR ROOT;');
      const nsMapAfter = rootInfoAfter?.[0]?.result?.namespaces || {};
      const existsAfter = Object.prototype.hasOwnProperty.call(nsMapAfter, selectedNs);
      console.log('Vérification (après reconnexion) ' + nsLabel + ':', selectedNs, '->', existsAfter ? 'EXISTE' : 'ABSENT');
    } catch (e) {
      console.warn('Impossible de vérifier INFO FOR ROOT après reconnexion:', e?.message || e);
    }

    // Optionnel: se positionner sur le namespace pour créer la DB si besoin
    try { await db.use({ namespace: selectedNs }); } catch {}

    // Base standard: en mode saas -> configuration_namespacedusaas ; en mode base -> CONFIG.db
    const selectedDb = mode === 'saas' ? 'configuration_namespacedusaas' : CONFIG.db;

    // S'assurer que la base existe avant d'essayer de la nettoyer
    try {
      // On supprime la base si elle existe pour garantir un état propre
      await db.query(`REMOVE DATABASE ${selectedDb};`);
      console.log(`Base de données '${selectedDb}' supprimée (si elle existait).`);
    } catch (e) {
      // Ignorer l'erreur si la base n'existe pas
    }
    try { await db.query(`CREATE DATABASE ${selectedDb};`); } catch {}

    // Sélection du namespace + database pour la suite des opérations
    await db.use({ namespace: selectedNs, database: selectedDb });

    // Vérification explicite de l'existence du namespace côté serveur
    try {
      const rootInfo = await db.query('INFO FOR ROOT;');
      const nsMap = rootInfo?.[0]?.result?.namespaces || {};
      const exists = Object.prototype.hasOwnProperty.call(nsMap, selectedNs);
      console.log('Vérification ' + nsLabel + ' dans INFO FOR ROOT:', exists ? 'EXISTE' : 'ABSENT');
      if (!exists) {
        console.warn('Le ' + nsLabel + ' attendu n\'apparaît pas dans INFO FOR ROOT.');
      }
      const nsInfo = await db.query('INFO FOR NS;');
      console.log('INFO FOR NS exécuté pour', nsLabel, selectedNs, '-> statut OK');
    } catch (e) {
      console.warn('Impossible d\'obtenir les informations du ' + nsLabel + ':', e?.message || e);
    }

    // Pas de nettoyage: base neuve attendue. On se contente de créer/sélectionner.

    const systemDir = path.join(CONFIG.root, 'system');
    const storageDir = path.join(CONFIG.root, 'storage');
    const baseDir = path.join(CONFIG.root, 'base');
    const i18nDir = path.join(CONFIG.root, 'i18n');
    const configurationDir = path.join(CONFIG.root, 'configuration');
    const integrationsDir = path.join(CONFIG.root, 'integrations');
    const builderDir = path.join(CONFIG.root, 'builder');
    const automationDir = path.join(CONFIG.root, 'automation');
    const deployDir = path.join(CONFIG.root, 'deploy');

    // Ordonnancement strict des sous-dossiers système pour les dépendances
    const systemSubOrder = ['system_validate', 'system_validate_rules', 'system_sanitize', 'system_tag', 'system_environment', 'system_log', 'system_app', 'system_core'];
    const systemFiles = [];
    for (const sub of systemSubOrder) {
      const subdir = path.join(systemDir, sub);
      try {
        const files = await listSurqlFiles(subdir);
        systemFiles.push(...files);
      } catch (e) {
        // sous-dossier absent: ignorer
      }
    }
    // Storage: database -> resources (et futurs sous-modules)
    const storageSubOrder = ['database', 'resources'];
    const storageFiles = [];
    for (const sub of storageSubOrder) {
      const subdir = path.join(storageDir, sub);
      try {
        const files = await listSurqlFiles(subdir);
        storageFiles.push(...files);
      } catch (e) {
        // sous-dossier absent
      }
    }
    // Fichiers à la racine de storage (le cas échéant)
    try {
      const rootEntriesStorage = await fs.readdir(storageDir, { withFileTypes: true });
      const rootStorageFiles = rootEntriesStorage
        .filter(e => e.isFile() && e.name.endsWith('.surql'))
        .map(e => path.join(storageDir, e.name))
        .sort((a, b) => a.localeCompare(b));
      storageFiles.push(...rootStorageFiles);
    } catch {}

    // Base: nouveau pattern database -> resources -> reference (hors i18n désormais)
    // Fallback: ancien dossier base/i18n si présent
    let baseFiles = [];
    const baseSubOrder = ['database', 'resources', 'reference'];
    let usedNewBasePattern = false;
    try {
      // Tenter le nouveau pattern d'abord
      for (const sub of baseSubOrder) {
        const subdir = path.join(baseDir, sub);
        try {
          const files = await listSurqlFiles(subdir);
          if (files.length > 0) {
            usedNewBasePattern = true;
          }
          baseFiles.push(...files);
        } catch {}
      }
    } catch {}
    // plus de repli base/i18n: i18n devient un module top-level
    // Ajouter d'éventuels fichiers .surql à la racine de base (après sous-dossiers)
    try {
      const rootEntriesBase = await fs.readdir(baseDir, { withFileTypes: true });
      const rootBaseFiles = rootEntriesBase
        .filter(e => e.isFile() && e.name.endsWith('.surql'))
        .map(e => path.join(baseDir, e.name))
        .sort((a, b) => a.localeCompare(b));
      baseFiles.push(...rootBaseFiles);
    } catch {}

    // i18n module: database -> resources -> reference
    const i18nSubOrder = ['database', 'resources', 'reference'];
    const i18nFiles = [];
    for (const sub of i18nSubOrder) {
      const subdir = path.join(i18nDir, sub);
      try {
        const files = await listSurqlFiles(subdir);
        i18nFiles.push(...files);
      } catch {}
    }

    // Configuration: database -> resources -> reference
    const configurationSubOrder = ['database', 'resources', 'reference'];
    const configurationFiles = [];
    for (const sub of configurationSubOrder) {
      const subdir = path.join(configurationDir, sub);
      try {
        const files = await listSurqlFiles(subdir);
        configurationFiles.push(...files);
      } catch (e) {
        // sous-dossier absent: ignorer
      }
    }
    // Fichiers à la racine de configuration (le cas échéant)
    try {
      const rootEntriesCfg = await fs.readdir(configurationDir, { withFileTypes: true });
      const rootCfgFiles = rootEntriesCfg
        .filter(e => e.isFile() && e.name.endsWith('.surql'))
        .map(e => path.join(configurationDir, e.name))
        .sort((a, b) => a.localeCompare(b));
      configurationFiles.push(...rootCfgFiles);
    } catch {}

    // Integrations: database -> resources -> reference
    const integrationsSubOrder = ['database', 'resources', 'reference'];
    const integrationsFiles = [];
    for (const sub of integrationsSubOrder) {
      const subdir = path.join(integrationsDir, sub);
      try {
        const files = await listSurqlFiles(subdir);
        integrationsFiles.push(...files);
      } catch (e) {
        // sous-dossier absent: ignorer
      }
    }
    // Fichiers à la racine de integrations (le cas échéant)
    try {
      const rootEntriesInt = await fs.readdir(integrationsDir, { withFileTypes: true });
      const rootIntFiles = rootEntriesInt
        .filter(e => e.isFile() && e.name.endsWith('.surql'))
        .map(e => path.join(integrationsDir, e.name))
        .sort((a, b) => a.localeCompare(b));
      integrationsFiles.push(...rootIntFiles);
    } catch {}

    const builderFilesAll = (await listSurqlFiles(builderDir)).filter(Boolean);
    // Exclure explicitement les sous-modules "system" sous builder (system_tag, system_log initialises)
    const builderFiles = builderFilesAll.filter(p => {
      const s = p.replace(/\\/g, '/').toLowerCase();
      if (s.includes('/database/system_tag/')) return false;
      if (s.includes('/resources/builder_log/') && /\/system_.+\.surql$/i.test(s)) return false;
      return true;
    });
    // Ordonnancement strict des sous-dossiers automation pour les dépendances
    const automationSubOrder = ['database', 'resources', 'reference'];
    const automationFiles = [];
    for (const sub of automationSubOrder) {
      const subdir = path.join(automationDir, sub);
      try {
        const files = await listSurqlFiles(subdir);
        automationFiles.push(...files);
      } catch (e) {
        // sous-dossier absent: ignorer
      }
    }
    // Ajouter les fichiers .surql à la racine de automation après les sous-dossiers
    try {
      const rootEntries = await fs.readdir(automationDir, { withFileTypes: true });
      const rootAutomationFiles = rootEntries
        .filter(e => e.isFile() && e.name.endsWith('.surql'))
        .map(e => path.join(automationDir, e.name))
        .sort((a, b) => a.localeCompare(b));
      automationFiles.push(...rootAutomationFiles);
    } catch (e) {
      // aucun fichier racine: ignorer
    }
    let deployFiles = [];
    try {
      deployFiles = (await listSurqlFiles(deployDir)).filter(Boolean);
    } catch (e) {
      // dossier deploy absent: ignorer
    }

    // Ordre d'import (temporaire): i18n puis builder
    const files = [...i18nFiles, ...builderFiles];
    console.log('Fichiers à importer:', files.length);

    const failures = [];
    let successCount = 0;
    for (const file of files) {
      try {
        const sql = await fs.readFile(file, 'utf8');
        console.log('Importing', file);
        await db.query(sql);
        successCount += 1;
      } catch (e) {
        console.error('Erreur fichier:', file);
        console.error('  ->', e?.message || e);
        failures.push({ file, error: e?.message || String(e) });
        // continuer malgré l'erreur
      }
    }

    console.log(`Import terminé. Succès: ${successCount} / ${files.length}, Echecs: ${failures.length}`);
    try {
      const infoDb = await db.query('INFO FOR DB;');
      const tables = Object.keys(infoDb?.[0]?.result?.tables || {});
      console.log(nsLabel + ' courant:', selectedNs, '| DB:', selectedDb, '| Tables:', tables.length);
    } catch (e) {
      console.warn('Impossible d\'obtenir INFO FOR DB:', e?.message || e);
    }

    // Déclenchement du déploiement général (désactivé temporairement)
    // try {
    //   const res = await db.query('RETURN fn::deploy_general();');
    //   console.log('deploy_general exécuté:', JSON.stringify(res?.[0] || res));
    // } catch (e) {
    //   console.warn('Échec deploy_general:', e?.message || e);
    // }

    if (failures.length > 0) {
      console.log('Fichiers en échec:');
      for (const f of failures) {
        console.log(' -', f.file);
      }
      // ne pas quitter en erreur; on laisse au pipeline/app le soin de décider
    }
  } catch (err) {
    console.error('Erreur import:', err?.message || err);
    process.exitCode = 1;
  } finally {
    try { await db.close(); } catch {}
  }
}

main();


