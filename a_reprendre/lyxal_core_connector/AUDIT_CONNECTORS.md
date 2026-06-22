# Audit : n8n Google Sheets Node vs Lyxal DEFINE CONNECTOR

## 1. Analyse du Node n8n
Le node Google Sheets de n8n repose sur :
- **Authentification** : OAuth2 (via credentials).
- **Opérations** : Append, Clear, Create, Delete, Get, Update.
- **Logique** : Basée sur des appels HTTP vers `https://sheets.googleapis.com/v4`.

## 2. Extraction des Points Clés
Les fichiers critiques à conserver avant suppression :
- `GoogleSheets.node.json` : Contient la structure des propriétés et des endpoints.
- `GoogleSheets.utils.ts` : Contient les helpers de formatage (ex: conversion de colonnes A1 notation).

## 3. Stratégie de Mapping Lyxal
Plutôt que d'utiliser une crate Rust spécifique, nous allons utiliser un moteur HTTP générique piloté par la définition `DEFINE CONNECTOR`.

### Structure de Données proposée :
```sql
DEFINE CONNECTOR google_sheets
    TYPE 'http'
    AUTHENTICATION $auth_google
    BASE_URL "https://sheets.googleapis.com/v4"
    OPERATIONS {
        append: {
            method: 'POST',
            path: "/spreadsheets/{spreadsheetId}/values/{range}:append",
            params: ["spreadsheetId", "range", "valueInputOption"],
            body: {
                values: "$values"
            }
        }
    };
```

## 4. Prochaines Étapes
- Développer le runtime Rust pour interpréter ce nouveau type de déclaration.
- Créer un script d'extraction automatique pour convertir les nodes n8n restants.