# Migration vers API V1 / enc:v2

Changement de contrat avant première production, autorisé par le CTO. Aucun consommateur,
donnée, clé, coffre ou registre extérieur au crate n'est modifié par cette implémentation.

| Ancien usage | Remplacement explicite |
|---|---|
| alias Zeroizing, accès via Deref/AsRef | SecretBytes/SecretString::new retourne Result ; expose_secret pour emprunt intentionnel |
| EncryptionKey::from_bytes / try_from_slice | import(SecretBytes) ; generate retourne Result |
| SecretContext::new avec tenant default | with_tenant exige l'identité exacte autorisée |
| encrypt_unbound/decrypt_unbound, AAD vide | global(purpose) et seal/open, domaine global authentifié |
| CryptoEngine encrypt_secret/decrypt_secret avec String | seal/open avec EncryptedEnvelope privé, encode/parse explicites |
| champs publics/new arbitraire d'enveloppe | parse strict ; key_id est seulement une métadonnée avant open |
| CompositeKeyResolver mutable | KeyRingBuilder, KeyRing immuable, StaticKeyResolver ou resolver hôte snapshot |
| active_key_id puis resolve | snapshot unique par opération |
| add_historical_key écrasant un ID | insert(..., DecryptOnly) refuse tout doublon |
| sauvegarde implicite du trousseau | registre durable hôte, restauration insert_revoked sans anciennes clés |
| needs_rehash(&str) | PasswordHash::parse(...)? puis .needs_rehash() |
| mots de passe/hashes en String ordinaire | SecretString / PasswordHash, export PHC nommé |
| clés HMAC arbitraires | HmacKey 32 bytes ; ne pas transformer silencieusement une clé externe incompatible |
| HKDF sortie brute dans buffer / helper32 | hkdf_sha256(...,len) retourne SecretBytes ; info explicite non vide |

Les formats enc:v1 et son AAD restent des archives identifiables, jamais réinterprétés
comme V2. V1 retourne UnsupportedVersion, sans tentative legacy/AAD vide. Recréer les
données de développement ou concevoir une migration séparée autorisée ; ne pas réutiliser
un ID pour une clé régénérée ni supprimer les historiques sans inventaire de dépendances.

Les builds et tests du crate ne prouvent pas la compilation de Booking ou du workspace
complet après ces ruptures. L'adaptation des consommateurs nécessite un mandat distinct.
