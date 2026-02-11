# 🔍 Requêtes Utiles – Lyxal Knowledge System

Ce document regroupe les **requêtes essentielles SurrealDB** pour exploiter efficacement le Knowledge System.

Elles sont classées par niveau d’usage : Base, Intermédiaire, Avancé, IA.

---

## ✅ 1. Requêtes de Base

### 📂 Obtenir tous les domaines actifs
```sql
SELECT * FROM knowledge_domain WHERE metadata.is_active = true;

🧠 Obtenir tous les topics d’un domaine

SELECT * FROM knowledge_topic WHERE domain = knowledge_domain:<ID>;

📚 Obtenir tous les types de contenus actifs

SELECT * FROM knowledge_content_type WHERE metadata.is_active = true ORDER BY metadata.display_order ASC;

🏷️ 2. Tags & Keywords
🔎 Obtenir les mots-clés d’un domaine

SELECT ->knowledge_domain_keyword->out AS keywords FROM knowledge_domain:<ID>;

🧵 Obtenir les mots-clés d’un topic

SELECT ->knowledge_topic_keyword->out AS keywords FROM knowledge_topic:<ID>;

🏷️ Filtrer les topics par tag

SELECT * FROM knowledge_topic WHERE tags CONTAINS knowledge_tag:<ID>;

📌 3. Recherche Full-Text
🔥 Rechercher un mot-clé dans tous les domaines

SELECT *, search::score() AS score
FROM knowledge_domain_keyword
WHERE out @@ <mot>
ORDER BY score DESC;

🧠 Rechercher un topic via keywords

SELECT in AS topic_id, search::score() AS score
FROM knowledge_topic_keyword
WHERE out @@ <mot>
ORDER BY score DESC;

🧩 4. Requêtes Combinées
📍 Obtenir un domaine + ses topics + leurs contenus

SELECT {
    domain: *,
    topics: (
        SELECT {
            topic: *,
            contents: (SELECT * FROM knowledge_content WHERE topic = id AND metadata.is_active = true)
        }
        FROM knowledge_topic WHERE domain = id
    )
}
FROM knowledge_domain WHERE id = knowledge_domain:<ID>;

🧱 Obtenir les contenus d’un topic groupés par type

SELECT identity.content_type, array::group(*)
FROM knowledge_content
WHERE topic = knowledge_topic:<ID> AND metadata.is_active = true
GROUP BY identity.content_type;

🤖 5. Requêtes Optimisées IA
🧠 Trouver le meilleur contenu pour répondre à une question (IA scoring)

SELECT *, (
    SELECT metadata.ai.weight FROM knowledge_content_type WHERE identity.code = identity.content_type
) AS type_weight
FROM knowledge_content
WHERE topic = knowledge_topic:<ID>
ORDER BY type_weight DESC, metadata.priority DESC;


🔥 Sélection automatique du meilleur contenu pour débutant

SELECT *
FROM knowledge_content
WHERE topic = knowledge_topic:<ID>
ORDER BY (SELECT metadata.ai.level.level FROM knowledge_content_type WHERE identity.code = identity.content_type) ASC
LIMIT 1;

🧪 6. Admin & Validation
🚦 Voir les contenus inactifs
SELECT * FROM knowledge_content WHERE metadata.is_active = false;

🚧 Voir les contenus nécessitant amélioration (IA Quality Score)

champ futur (dans roadmap)

SELECT * FROM knowledge_content WHERE metadata.ai.quality_score < 0.5;

🧵 7. Export & Audit
🗂️ Exporter toute la base Knowledge (version humaine)

SELECT * FROM knowledge_domain;
SELECT * FROM knowledge_topic;
SELECT * FROM knowledge_content_type;
SELECT * FROM knowledge_content;

🧠 Export IA (format compact pour entraînement)

Exemple futur, dépend du module Auto-Learning

🏁 Conclusion

Ces requêtes couvrent 95% des besoins humains & IA pour exploiter le Knowledge System Lyxal.
Elles peuvent être utilisées dans l’UI, l’API, les outils internes ou par les IA Lyxal