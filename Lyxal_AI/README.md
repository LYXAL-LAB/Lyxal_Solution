# 🧠 Lyxal AI (Module)

**Le Cerveau et l'Orchestrateur d'Agents.**

## 🎯 Vision
`Lyxal_AI` est l'interface entre l'Humain et le Système. C'est ici que vit l'Assistant Lyxal.
Ce n'est pas un simple chatbot. C'est un **Système d'Exploitation Cognitif** capable de :
1.  Comprendre une intention complexe.
2.  Planifier une séquence d'actions.
3.  Utiliser les outils (`Lyxal_MCP`, `Lyxal_Connect`) pour agir sur le monde réel.

## 🏗 Architecture

### 1. Agent Runtime
Le moteur d'exécution qui fait tourner les agents. Il gère :
*   La mémoire (Court terme / Long terme).
*   Le RAG (Recherche vectorielle dans SurrealDB).
*   Le "Tool Use" (Appel aux fonctions MCP).

### 2. Chat Interface (UI/UX)
Une interface conversationnelle riche (Websocket/SSE) qui supporte non seulement du texte, mais aussi des "Generative UI" (formulaires, graphiques générés à la volée).

### 3. Agent Builder
Un outil pour que les administrateurs puissent créer des agents spécialisés ("Agent RH", "Agent Sales") avec des instructions et des accès spécifiques.

## 📚 Inspirations & Références
*   **Obot** : Pour l'architecture globale (Gateway MCP + Chat).
*   **LangGraph / LangChain** : Pour la logique de graphe d'exécution (Agents cycliques).
*   **Vercel AI SDK** : Pour le streaming fluide et les composants d'interface (Generative UI).

## 🛠 Stack Technique
*   **Langage** : TypeScript (Bun).
*   **Database** : SurrealDB (Vecteurs + Historique de chat).
*   **Protocole** : MCP (Client).

