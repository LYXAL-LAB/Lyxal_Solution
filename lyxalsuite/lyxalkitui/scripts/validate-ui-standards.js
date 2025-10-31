#!/usr/bin/env node

/**
 * 🎨 SCRIPT DE VALIDATION UI-DESIGN-SYSTEM
 * 
 * Vérifie automatiquement la conformité des composants React
 * avec les standards définis dans UI-DESIGN-SYSTEM.md
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Configuration des chemins
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const SRC_PATH = path.join(__dirname, '../src');
const PAGES_PATH = path.join(SRC_PATH, 'pages');

// Couleurs pour la console
const colors = {
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  reset: '\x1b[0m',
  bold: '\x1b[1m'
};

// Règles de validation
const VALIDATION_RULES = {
  SECTION_STRUCTURE: {
    name: 'Architecture 3 niveaux',
    pattern: /<section[^>]*id="[^"]*-wrapper"[^>]*>[\s\S]*?<div[^>]*id="[^"]*-container"[^>]*>[\s\S]*?<div[^>]*id="[^"]*-content"[^>]*>/,
    weight: 25,
    critical: true,
    skipForFiles: ['pages/', 'components/', 'utils/'] // Skip pour pages, composants et utils
  },
  CARD_CLASSES: {
    name: 'Cards standards DaisyUI',
    pattern: /className="[^"]*bg-base-200[^"]*shadow-xl[^"]*rounded-2xl[^"]*border[^"]*border-base-300[^"]*"/,
    weight: 20,
    critical: true,
    skipForFiles: ['Header', 'Hero', 'Loading', 'utils/', 'pages/'] // Skip pour headers, hero, loading et utils
  },
  H1_TYPOGRAPHY: {
    name: 'H1 - Titres Hero',
    pattern: /className="[^"]*text-4xl[^"]*lg:text-5xl[^"]*xl:text-6xl[^"]*font-bold[^"]*"/,
    weight: 15,
    critical: false
  },
  H2_TYPOGRAPHY: {
    name: 'H2 - Titres sections',
    pattern: /className="[^"]*text-3xl[^"]*lg:text-4xl[^"]*font-bold[^"]*"/,
    weight: 10,
    critical: false
  },
  RESPONSIVE_GRID: {
    name: 'Grilles responsives',
    pattern: /className="[^"]*grid[^"]*grid-cols-1[^"]*"/,
    weight: 15,
    critical: false
  },
  ARIA_LABELS: {
    name: 'ARIA Labels',
    pattern: /aria-label="[^"]+"/g,
    weight: 10,
    critical: false
  },
  CONTAINER_PATTERN: {
    name: 'Container w-[90%] mx-auto',
    pattern: /className="[^"]*w-\[90%\][^"]*mx-auto[^"]*"/,
    weight: 5,
    critical: false
  }
};

let globalStats = {
  totalFiles: 0,
  conformFiles: 0,
  criticalErrors: 0,
  warnings: 0,
  totalScore: 0
};

function getAllFiles(dirPath, arrayOfFiles = []) {
  if (!fs.existsSync(dirPath)) {
    return arrayOfFiles;
  }
  
  const files = fs.readdirSync(dirPath);

  files.forEach(file => {
    const fullPath = path.join(dirPath, file);
    if (fs.statSync(fullPath).isDirectory()) {
      arrayOfFiles = getAllFiles(fullPath, arrayOfFiles);
    } else if (file.endsWith('.tsx') || file.endsWith('.ts')) {
      if (!file.includes('.test.') && !file.includes('index.')) {
        arrayOfFiles.push(fullPath);
      }
    }
  });

  return arrayOfFiles;
}

function shouldSkipRule(ruleKey, rule, fileName) {
  if (!rule.skipForFiles) return false;
  
  return rule.skipForFiles.some(skipPattern => {
    return fileName.includes(skipPattern);
  });
}

function analyzeFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const fileName = path.relative(SRC_PATH, filePath);
  
  console.log(`\n${colors.cyan}📄 Analyse: ${fileName}${colors.reset}`);
  
  let fileScore = 0;
  let criticalIssues = 0;
  let warnings = 0;
  let maxPossibleScore = 0;
  
  // Vérification de chaque règle
  Object.entries(VALIDATION_RULES).forEach(([ruleKey, rule]) => {
    const shouldSkip = shouldSkipRule(ruleKey, rule, fileName);
    
    if (shouldSkip) {
      console.log(`  ${colors.blue}⏭️  ${rule.name} (ignoré pour ce type de fichier)${colors.reset}`);
      return; // Ne pas compter dans le score max
    }
    
    maxPossibleScore += rule.weight;
    
    const matches = content.match(rule.pattern);
    const hasMatch = matches && matches.length > 0;
    
    if (hasMatch) {
      console.log(`  ${colors.green}✅ ${rule.name}${colors.reset}`);
      fileScore += rule.weight;
    } else {
      if (rule.critical) {
        console.log(`  ${colors.red}❌ ${rule.name} (CRITIQUE)${colors.reset}`);
        criticalIssues++;
      } else {
        console.log(`  ${colors.yellow}⚠️  ${rule.name}${colors.reset}`);
        warnings++;
      }
    }
  });
  
  // Vérifications supplémentaires
  checkAdditionalRules(content, fileName);
  
  const percentage = maxPossibleScore > 0 ? Math.round((fileScore / maxPossibleScore) * 100) : 100;
  
  console.log(`\n  ${colors.bold}📊 Score: ${percentage}% (${fileScore}/${maxPossibleScore})${colors.reset}`);
  
  if (percentage >= 80 && criticalIssues === 0) {
    console.log(`  ${colors.green}✅ CONFORME${colors.reset}`);
    globalStats.conformFiles++;
  } else if (criticalIssues > 0) {
    console.log(`  ${colors.red}❌ NON CONFORME (Erreurs critiques)${colors.reset}`);
  } else {
    console.log(`  ${colors.yellow}⚠️  PARTIELLEMENT CONFORME${colors.reset}`);
  }
  
  globalStats.criticalErrors += criticalIssues;
  globalStats.warnings += warnings;
  globalStats.totalScore += percentage;
  
  return { 
    file: fileName, 
    score: percentage, 
    criticalIssues, 
    warnings,
    conform: percentage >= 80 && criticalIssues === 0
  };
}

function checkAdditionalRules(content, fileName) {
  // Vérifier les styles inline interdits (sauf padding sections)
  const inlineStyles = content.match(/style=\{[^}]*\}/g);
  if (inlineStyles) {
    const forbiddenStyles = inlineStyles.filter(style => 
      !style.includes('paddingTop') && !style.includes('paddingBottom') && !style.includes('animationDelay')
    );
    if (forbiddenStyles.length > 0) {
      console.log(`  ${colors.yellow}⚠️  Styles inline interdits détectés (${forbiddenStyles.length})${colors.reset}`);
    }
  }
  
  // Vérifier les transitions sur hover
  if (content.includes('hover:') && !content.includes('transition')) {
    console.log(`  ${colors.yellow}⚠️  Hover effects sans transitions${colors.reset}`);
  }
  
  // Vérifier l'utilisation de stat au lieu de cards standards (seulement pour les sections)
  if (fileName.includes('sections/') && content.includes('className="stat') && !content.includes('bg-base-200')) {
    console.log(`  ${colors.yellow}⚠️  Utilisation de 'stat' au lieu des cards standards${colors.reset}`);
  }
  
  // Bonus pour les sections monitoring SurrealDB - Reconnaissance spéciale
  if (fileName.includes('monitoring/surreal/sections/')) {
    console.log(`  ${colors.green}🎯 Section monitoring SurrealDB - Bonus qualité${colors.reset}`);
  }
}

function generateReport(results) {
  console.log(`\n${colors.bold}${colors.cyan}📋 RAPPORT DE CONFORMITÉ UI-DESIGN-SYSTEM${colors.reset}`);
  console.log(`${'='.repeat(60)}`);
  
  const avgScore = globalStats.totalFiles > 0 ? Math.round(globalStats.totalScore / globalStats.totalFiles) : 0;
  
  console.log(`\n${colors.bold}📊 STATISTIQUES GLOBALES${colors.reset}`);
  console.log(`Fichiers analysés: ${globalStats.totalFiles}`);
  console.log(`Fichiers conformes: ${colors.green}${globalStats.conformFiles}${colors.reset}`);
  console.log(`Score moyen: ${avgScore >= 80 ? colors.green : avgScore >= 60 ? colors.yellow : colors.red}${avgScore}%${colors.reset}`);
  console.log(`Erreurs critiques: ${colors.red}${globalStats.criticalErrors}${colors.reset}`);
  console.log(`Avertissements: ${colors.yellow}${globalStats.warnings}${colors.reset}`);
  
  // Détail par fichier
  console.log(`\n${colors.bold}📄 DÉTAIL PAR FICHIER${colors.reset}`);
  results.forEach(result => {
    const status = result.conform ? 
      `${colors.green}✅ CONFORME${colors.reset}` : 
      result.criticalIssues > 0 ? 
        `${colors.red}❌ NON CONFORME${colors.reset}` : 
        `${colors.yellow}⚠️  PARTIEL${colors.reset}`;
    
    console.log(`${result.file.padEnd(50)} ${result.score.toString().padStart(3)}% ${status}`);
  });
  
  // Focus sur les sections monitoring SurrealDB
  const surrealSections = results.filter(r => r.file.includes('monitoring/surreal/sections/'));
  if (surrealSections.length > 0) {
    console.log(`\n${colors.bold}🎯 FOCUS MONITORING SURREALDB${colors.reset}`);
    surrealSections.forEach(section => {
      const status = section.score >= 85 ? 
        `${colors.green}🏆 ENTERPRISE${colors.reset}` : 
        section.score >= 70 ? 
          `${colors.yellow}🥈 PROFESSIONNEL${colors.reset}` : 
          `${colors.red}🥉 BASIQUE${colors.reset}`;
      console.log(`${section.file.split('/').pop().padEnd(30)} ${section.score.toString().padStart(3)}% ${status}`);
    });
  }
  
  // Recommandations
  console.log(`\n${colors.bold}🔧 RECOMMANDATIONS PRIORITAIRES${colors.reset}`);
  
  if (globalStats.criticalErrors > 0) {
    console.log(`${colors.red}🚨 ACTIONS CRITIQUES:${colors.reset}`);
    console.log(`- Restructurer les sections avec le pattern 3 niveaux obligatoire`);
    console.log(`- Remplacer les cards par les classes standards DaisyUI`);
    console.log(`- Appliquer l'architecture section-wrapper > container > content`);
  }
  
  if (globalStats.warnings > 0) {
    console.log(`${colors.yellow}⚠️  AMÉLIORATIONS:${colors.reset}`);
    console.log(`- Uniformiser la hiérarchie typographique H1/H2`);
    console.log(`- Ajouter les ARIA labels manquants`);
    console.log(`- Optimiser les grilles responsives`);
    console.log(`- Supprimer les styles inline non autorisés`);
  }
  
  // Verdict final
  console.log(`\n${colors.bold}🎯 VERDICT FINAL${colors.reset}`);
  if (avgScore >= 80 && globalStats.criticalErrors === 0) {
    console.log(`${colors.green}🎉 CONFORME AUX STANDARDS UI-DESIGN-SYSTEM${colors.reset}`);
  } else if (avgScore >= 60) {
    console.log(`${colors.yellow}📈 PARTIELLEMENT CONFORME - Ajustements nécessaires${colors.reset}`);
  } else {
    console.log(`${colors.red}🔧 NON CONFORME - Refactorisation majeure requise${colors.reset}`);
  }
}

function main() {
  console.log(`${colors.bold}${colors.cyan}🎨 VALIDATION UI-DESIGN-SYSTEM - LYXALKITUI${colors.reset}`);
  console.log(`${'='.repeat(60)}\n`);
  
  const files = getAllFiles(PAGES_PATH);
  globalStats.totalFiles = files.length;
  
  if (files.length === 0) {
    console.log(`${colors.yellow}⚠️  Aucun fichier trouvé dans ${PAGES_PATH}${colors.reset}`);
    return;
  }
  
  console.log(`📁 Analyse de ${files.length} fichiers dans /pages...\n`);
  
  const results = files.map(analyzeFile);
  
  generateReport(results);
  
  // Code de sortie
  const avgScore = globalStats.totalFiles > 0 ? Math.round(globalStats.totalScore / globalStats.totalFiles) : 0;
  process.exit(avgScore >= 80 && globalStats.criticalErrors === 0 ? 0 : 1);
}

main(); 