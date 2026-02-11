# Lyxal_SVG Module

Module centralisé de gestion des icônes pour l'écosystème Lyxal.

## Structure

- **packs/** : Sources SVG brutes (Lucide, Tabler, etc.)
- **normalized/** : SVGs optimisés pour production (24x24, currentColor)
- **metadata/** : Index JSON pour usage rapide (UI/IA)
- **surreal/** : Structure Base de données (Tables, Fonctions, Seeds)
- **scripts/** : Outils d'automatisation (Import, Normalisation, Sync)
- **api/** : Serveur interne pour distribution
- **cdn/** : Manifestes pour CDN externe

## Installation

1. Remplir les packs : `bun scripts/importLucide.ts`
2. Normaliser : `bun scripts/normalize.ts`
3. Générer index : `bun scripts/generateMetadata.ts`
4. Sync DB : `bun scripts/importToSurreal.ts`

