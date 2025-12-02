📘 Documentation — Lyxal_Surreal / utils (Version PRO)

Le dossier utils/ contient les outils transverses essentiels utilisés par tout le moteur SurrealDB de LYXAL.

Son rôle est central :
➡️ standardiser les erreurs
➡️ unifier les logs
➡️ fournir les types JSON/Surreal
➡️ offrir un système de retry intelligent

C’est la base commune utilisée par surrealConnection, surrealClient, et plus tard par les queries PRO et les modules SaaS.

📁 Structure du dossier utils/
utils/
   types.ts
   errors.ts
   logger.ts
   retry.ts


Chaque fichier joue un rôle bien distinct, décrit ci-dessous.

1️⃣ types.ts — Types fondamentaux du moteur

Fichier : src/utils/types.ts

🎯 Rôle

Définir les types JSON, les types Surreal et quelques utilitaires qui permettent au moteur d’être typé, strict, clair et extensible.

📌 Contenu

JsonPrimitive, JsonValue, JsonObject, JsonArray

SurrealRecord<T> : type standard pour les records Surreal (id, etc.)

DeepPartial<T> : pour les updates partiels

MaybePromise<T> : utile pour les callbacks synchrones ou async

StandardError : format interne des erreurs LYXAL

🧪 Exemple d’usage
import type { SurrealRecord, JsonValue } from "@lyxal/surreal";

function handleResponse(record: SurrealRecord) {
  console.log(record.id);
}

2️⃣ errors.ts — Gestion PRO des erreurs

Fichier : src/utils/errors.ts

🎯 Rôle

Créer un système d’erreur :

uniforme

typé

traçable

compatible SaaS

compatible edge / cloud

qui peut être étendu par les modules métiers (CRM, Auth…)

📌 Contenu
✔ Enum : LyxalErrorCode

Exemples :

CONNECTION_FAILED

QUERY_FAILED

INVALID_CONTEXT

CONFIG_MISSING

✔ Classe : SurrealError

Une erreur clairement identifiable dans tout le moteur.

✔ Fonctions utilitaires

isSurrealError()

wrapSurrealError() (pour transformer une erreur native en SurrealError PRO)

🧪 Exemple d’usage
import { wrapSurrealError, LyxalErrorCode } from "@lyxal/surreal";

throw wrapSurrealError(
  "Impossible d’exécuter la requête",
  LyxalErrorCode.QUERY_FAILED,
  err
);

3️⃣ logger.ts — Logger PRO structuré (JSON)

Fichier : src/utils/logger.ts

🎯 Rôle

Unifier tous les logs du moteur Surreal, avec un format JSON structuré, idéal pour :

SurrealDB Cloud

Bunny Edge

Workers

Logs centralisés

Monitoring LYXAL

📌 Contenu

4 fonctions :

logDebug(message, meta)

logInfo(message, meta)

logWarn(message, meta)

logError(message, meta)

Elles produisent toujours un log JSON comme :

{
  "ts": "2025-11-19T10:21:05.452Z",
  "level": "info",
  "message": "Connexion établie",
  "meta": null,
  "source": "Lyxal_Surreal"
}

🧪 Exemple d’usage
import { logInfo } from "@lyxal/surreal";

logInfo("Connexion Surreal réussie", { ns: "CRM", db: "Customer" });

4️⃣ retry.ts — Retry PRO (backoff exponentiel + jitter)

Fichier : src/utils/retry.ts

🎯 Rôle

Créer un mécanisme robuste pour :

réessayer une opération

avec un délai croissant (exponential backoff)

et un jitter (variation aléatoire)

Utilisé par :
✔ surrealConnection
✔ plus tard par les queries PRO
✔ utile pour les scripts, migrations, seeds…

📌 Options
export interface RetryOptions {
  attempts: number;      // nombre de tentatives
  delayMs: number;       // délai initial
  backoffFactor?: number; // facteur exponentiel (1.5 par défaut)
  jitter?: boolean;      // variation aléatoire (+/- 20%)
}

🧪 Exemple d’usage
import { withRetry } from "@lyxal/surreal";

const data = await withRetry(
  () => db.query("SELECT * FROM user"),
  { attempts: 4, delayMs: 200 }
);

🎓 Résumé PRO des utils
Fichier	Fonction	PRO ?
types.ts	Types JSON et utilitaires	✔ PRO
errors.ts	Erreurs uniformisées	✔ PRO
logger.ts	Logging JSON structuré	✔ PRO
retry.ts	Retry intelligent avec backoff	✔ PRO
🔧 Pourquoi ces utils sont indispensables ?

Parce qu’ils permettent :

une architecture cohérente

des logs fiables et uniformes

une gestion d’erreurs professionnelle et extensible

une couche de retry compatible réseau / edge / cloud

un moteur Surreal predictible, stable et déboggable

Sans ces utils PRO, impossible d’avoir :

un surrealClient PRO

un surrealConnection PRO

et demain → des query PRO