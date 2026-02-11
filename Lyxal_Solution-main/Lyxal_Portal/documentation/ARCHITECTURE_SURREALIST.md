# Architecture et Intégration de Surrealist dans Lyxal Solution

## 1. Vue d'ensemble
Surrealist est une interface d'administration pour SurrealDB développée en React/TypeScript avec une couche desktop via Tauri. Dans le cadre de **Lyxal Solution**, elle servira de socle technique ("Framework Applicatif") pour construire l'interface métier unique, tirant parti de sa gestion native et sécurisée de la connexion à la base de données.

## 2. Architecture Technique
Le projet est structuré autour de composants clés qui séparent proprement la logique de connexion, l'interface utilisateur et l'intelligence du langage.

### Stack Technique
- **Frontend :** React 18, Vite, TypeScript.
- **UI Kit :** Mantine (Composants graphiques).
- **State Management :** Zustand (Gestion d'état global).
- **Desktop (Optionnel) :** Tauri (Rust) pour l'empaquetage natif.

### Point d'Entrée et Structure
- `src/screens/surrealist/connection/connection.tsx` : **Le Cœur**. C'est un singleton qui maintient la connexion WebSocket active.
  - Fonction clé : `getSurreal()` permet de récupérer l'instance active n'importe où dans le code pour exécuter des requêtes.
- `src/screens/surrealist/sidebar.tsx` : **Le Menu**. Gère la navigation latérale. C'est ici qu'on remplacera les menus techniques par les menus métiers.
- `src/screens/surrealist/views/` : Contient les écrans actuels (Query, Explorer). C'est ici que seront ajoutés les écrans métiers (Clients, Factures, etc.).

## 3. Intelligence du Langage (SurrealQL)
Surrealist intègre un éditeur de code intelligent capable de comprendre la syntaxe SurrealQL, de valider le code et de proposer de l'autocomplétion. Cette intelligence **ne doit pas être recodée**, elle est fournie par des librairies maintenues par l'équipe SurrealDB.

### Les Composants de l'Intelligence
1.  **L'Éditeur :** CodeMirror 6.
2.  **Le Parseur (`@surrealdb/lezer`) :** Analyse la structure du code (Syntax Tree). Il sait distinguer un mot-clé `DEFINE` d'un nom de table.
3.  **Le Validateur (`@surrealdb/ql-wasm`) :** Une brique WebAssembly ultra-rapide qui valide la syntaxe avant même l'envoi au serveur.

### Gestion des Versions du Moteur
Le système est conçu pour supporter plusieurs versions de SurrealDB en parallèle via un pattern "Adapter".
- Fichiers : `src/util/surql/v2.tsx`, `src/util/surql/v3.tsx`.
- Fonctionnement : Une "Factory" (`src/util/surql/index.tsx`) détecte la version de la base de données connectée et charge le bon adaptateur (V2 ou V3).
- **Mise à jour :** Pour supporter une future version 4.0, il suffira de créer un adaptateur `v4.tsx` et de mettre à jour les dépendances NPM, sans toucher au reste de l'application.

## 4. Stratégie d'Intégration "Lyxal"
L'objectif est de transformer cet outil technique en application métier sans casser le noyau.

### Ce qu'il faut conserver (Ne pas toucher)
- **Le dossier `src/util/surql/` :** Contient toute l'intelligence du langage et la gestion des versions.
- **Le fichier `connection.tsx` :** Gère la sécurité, l'authentification et le tunnel WebSocket.
- **Les composants `CodeInput` :** À réutiliser tels quels si on a besoin d'afficher du SQL aux utilisateurs avancés.

### Ce qu'il faut modifier (La transformation)
1.  **Menu Latéral (`sidebar.tsx`) :**
    - Supprimer les entrées : Query, Explorer, Designer, GraphQL.
    - Ajouter les entrées métiers : "Gestion Clients", "Calendrier", "Documents".
2.  **Vues (`src/screens/surrealist/views/`) :**
    - Créer un dossier `metier/` pour isoler vos nouveaux développements.
    - Utiliser `getSurreal().query()` dans ces vues pour interagir avec les données.
3.  **Routeur (`index.tsx`) :**
    - Enregistrer les nouvelles routes métiers pour qu'elles soient accessibles via le menu.

## 5. Exemple d'Utilisation Métier
Pour créer une page "Liste des Clients" dans cette architecture :

```typescript
// src/screens/surrealist/views/metier/ClientsView.tsx
import { useEffect, useState } from "react";
import { getSurreal } from "~/screens/surrealist/connection/connection";

export function ClientsView() {
    const [clients, setClients] = useState([]);

    useEffect(() => {
        // Utilisation directe du moteur connecté et sécurisé
        getSurreal().query("SELECT * FROM clients").then(res => {
            if(res[0].status === "OK") {
                 setClients(res[0].result);
            }
        });
    }, []);

    return (
        <div>
            <h1>Mes Clients</h1>
            {/* Affichage avec les composants Mantine déjà inclus */}
        </div>
    );
}
```

