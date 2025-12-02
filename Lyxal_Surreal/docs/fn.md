📘 LYXAL SURREAL ENGINE — Guide PRO des Fonctions SurrealDB (fn)

Les fonctions SurrealDB (définies via DEFINE FUNCTION) permettent d’encapsuler :

de la logique métier

du nettoyage de données

des calculs

des règles métiers complexes

des operations atomiques

des enrichissements intelligents

Elles sont essentielles pour l’architecture LYXAL, car elles permettent :

✔ un backend ultra-minimal
✔ une logique métier côté SurrealDB
✔ des micro-modules réutilisables
✔ des performances élevées
✔ une isolation multi-SaaS naturelle

🧠 1. Définition d'une fonction Surreal (fn)

Syntaxe :

DEFINE FUNCTION fn::<namespace>_<name>(<params>) {
    <bloc SurrealQL / expressions>
};


Exemples :

DEFINE FUNCTION fn::crm_compute_score($id, $revenue) {
    RETURN $revenue * 1.2;
};

DEFINE FUNCTION fn::auth_hash_password($plain) {
    RETURN crypto::argon2::generate($plain);
};

Règles internes LYXAL
Règle	Exemple	Explication
Préfixe obligatoire fn::	fn::crm_compute_score	Standardise tout l’écosystème
Namespace métier avant le nom	crm_, auth_, ai_, erp_	Évite les collisions
Snake_case obligatoire	compute_score	Cohérence système
Paramètres $param	$id, $email	SurrealQL standard
RETURN explicite	RETURN …	Lisibilité + homogénéité
🧩 2. Appeler une fonction Surreal depuis LYXAL_Surreal

Toutes les fonctions Surreal s’appellent via le moteur PRO :

✔ Avec rawQuery
const [score] = await rawQuery(
  "RETURN fn::crm_compute_score($id, $rev);",
  { id: "company:123", rev: 80000 },
  CRM_CTX,
  { label: "crm:compute_score" }
);

✔ Avec transactional
await transactional(CRM_CTX, async (db) => {
  const [score] = await db.query(
    "RETURN fn::crm_compute_score($id, $rev)",
    { id: "company:123", rev: 90000 }
  );

  await db.merge("company:123", { score });
});

🛠 3. Organisation des fonctions Surreal — Architecture LYXAL
📁 Structure recommandée par module
<module>/
  script/
    functions/
      crm_compute_score.surql
      crm_normalize_name.surql
      crm_validate_company.surql


Chaque fichier contient :

DEFINE FUNCTION fn::crm_compute_score($company, $revenue) {
    RETURN $revenue * 1.4;
};

📁 Structure globale dans Lyxal_Surreal
scripts/
  functions/
    crm/
    auth/
    ai/
    erp/
    marketing/

🔁 4. Versioning des fonctions

SurrealDB ne versionne pas nativement ses fonctions.
LYXAL introduit un système simple et robuste :

👉 Convention : suffixe _vN

Exemples :

fn::crm_compute_score_v1
fn::crm_compute_score_v2
fn::auth_hash_password_v3

Pourquoi ?

permet d’éviter les breaking changes entre apps SaaS

permet à chaque namespace de choisir une version

facilite la compatibilité ascendante

🛡 5. Sécurité des fonctions

Points de vigilance PRO :

✔ Toujours valider les entrées
DEFINE FUNCTION fn::crm_score($rev) {
    IF $rev < 0 {
        RETURN 0;
    };
    RETURN $rev * 1.3;
}

✔ Éviter l’accès direct non filtré

Mauvais :

SELECT * FROM user;


Correct :

SELECT id, email, name FROM user;

✔ Utiliser value / assertions si nécessaire
IF $email IS NONE {
    RETURN false;
};

🔥 6. Meilleures pratiques LYXAL (fn PRO)
1. Une fn = une seule responsabilité

Pas de gros blocs qui font tout.

2. Pas d’accès à des tables externes si possible

Une fn doit rester pur calcul ou simple transformation.

3. Pas de logique complexe dans les queries front

→ Toujours mettre dans une fn pour éviter la duplication.

4. Noms toujours préfixés par module :
Module	Préfixe
CRM	crm_
Auth	auth_
AI	ai_
ERP	erp_
Marketing	mkt_
5. Documenter chaque fn

Dans un fichier functions.md local au module.

🧪 7. Exemples concrets — Niveau PRO
7.1 Calcul métier pour le CRM
DEFINE FUNCTION fn::crm_calculate_risk_score($years, $incidents) {
    LET base = $years >= 5 ? 100 : 60;
    LET penalty = $incidents * 20;
    RETURN base - penalty;
};


Appel :

const [risk] = await rawQuery(
  "RETURN fn::crm_calculate_risk_score($y, $i)",
  { y: 7, i: 1 },
  CRM_CTX
);

7.2 Nettoyage de données pour le module BTP
DEFINE FUNCTION fn::btp_normalize_surface($value) {
    RETURN math::round($value, 2);
};

7.3 Hash mot de passe (auth)
DEFINE FUNCTION fn::auth_hash_password($plain) {
    RETURN crypto::argon2::generate($plain);
};

🏗 8. Organisation multi-SaaS (clé dans LYXAL)

Chaque namespace va contenir sa propre version des fonctions, permettant :

des évolutions indépendantes

des personnalisations par client

des business rules exclusives

Ton moteur étant dynamiquement attaché à un namespace, tout est automatiquement isolé.

🗂 9. Appeler des fonctions via un module JS “fn/” (optionnel)

(Si tu le veux, je te le génère plus tard)

Structure :

import { crm } from "@lyxal/surreal/fn";

await crm.computeScore(companyId, revenue);

🧩 Conclusion

Ce fichier fn.md :

explique ce qu’est une fn Surreal

comment l’écrire, organiser, versionner

comment l’appeler via le moteur Query PRO

donne des conventions strictes LYXAL

fournit des exemples concrets