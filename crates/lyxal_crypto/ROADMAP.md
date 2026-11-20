# Feuille de route — `lyxal_crypto`

Évolutions prévues de la fondation cryptographique. L'état actuel (API figée, enveloppe `enc:v2`,
format de flux v1, TLS côté serveur, contrats, fixtures et fuzzing en CI) est décrit dans le
[`README.md`](README.md), [`API_CONTRACT.md`](API_CONTRACT.md) et [`SECURITY.md`](SECURITY.md).
Aucune étape ne démarre sans ordre du CTO et `implementation_plan.md` validé
(`.agents/AGENTS.md` §3).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Signatures RSA et Ed25519, génération de clés, DKIM ; passage des fonctions K8 de `ring` à `aws-lc-rs` (lot 2b du programme courrier, P6 b, c, d) | plan du lot 2 validé (décisions C1 à C6) ; débloque les lots 5 et 6 |
| 2 | Extensions du programme courrier demandées par les lots suivants | plan de chaque lot |
| 3 | Audit de sécurité externe | avant la première mise en production |

Les primitives hors périmètre (X25519, ChaCha20-Poly1305 et post-quantique comme primitives
offertes aux modules, KMS / HSM) ne sont pas des étapes de cette feuille de route : elles n'y
entrent que sur un besoin produit validé par le CTO
(`.agents/rules/lyxal_standards_and_checklist.md` §11.3). X25519, ChaCha20-Poly1305 et
X25519MLKEM768 sont déjà négociés **à l'intérieur** de TLS (décision C3).

---

## 1. Signatures, clés et DKIM (lot 2b)

Second volet du plan du lot 2 (`implementation_plan.md` du crate, décision C13) :

- [ ] vérification RSA PKCS#1 v1.5 SHA-256 et Ed25519, signature Ed25519, génération de clés RSA
      (2048, 3072, 4096 bits) et Ed25519, export PKCS#8 pour le coffre-fort ;
- [ ] DKIM (RFC 6376, 8301, 8463) : canonicalisation portée de `mail-auth` 0.16.0, empreinte du
      corps en flux, données signées, signature et vérification `rsa-sha256` / `ed25519-sha256` ;
- [ ] fonctions K8 (ES256, RS256, Web Push, HMAC-SHA1) calculées par `aws-lc-rs`, `ring` retiré
      des dépendances directes (API inchangée) ;
- [ ] `SOURCES.md`, vecteurs RFC 8032, RFC 8463 et Wycheproof (RSA, Ed25519), oracle
      différentiel DKIM, cibles de fuzzing `dkim_canonicalize` et `dkim_public_key`.

## 2. Extensions demandées par les lots suivants du programme courrier

Chacune entre par le plan de son lot, validé par le CTO :

- [ ] TLS côté client (envoi vers les serveurs de courrier : TLS opportuniste) — lot 6 (C8) ;
- [ ] ARC (P6 e) et vérificateur de certificat pour DANE et MTA-STS (P6 f) — lot 7 ;
- [ ] SCRAM-SHA-256 (P6 h) — lot 8 ;
- [ ] OpenPGP (P6 j) — lot 12 bis ;
- [ ] lecture des dates et des noms d'un certificat (alerte d'expiration), ACME (P6 g) — lot 13.

## 3. Audit de sécurité externe

La bibliothèque n'est pas certifiée. Elle protège les secrets applicatifs de tous les modules ;
elle est revue par un tiers avant la première mise en production (décision C14).

Critères d'acceptation :

- [ ] audit externe de l'API, de l'enveloppe `enc:v2`, du format de flux v1, de la configuration
      TLS côté serveur, de DKIM, de la gestion des clés et des dépendances (dont AWS-LC) ;
- [ ] chaque constat corrigé ou accepté par le CTO, avec justification ;
- [ ] `SECURITY.md` mis à jour (périmètre audité, limites connues).
