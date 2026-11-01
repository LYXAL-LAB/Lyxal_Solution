# Sécurité — garanties locales et préconditions de déploiement

Cette bibliothèque n'est pas certifiée. RustCrypto fournit les primitives ; le crate
encadre leurs contrats. Aucun code unsafe propre n'est autorisé ; les dépendances
peuvent comporter des backends unsafe/assembleur, dont les garanties sont distinctes.

## Frontières de confiance

Les enveloppes et PHC peuvent être hostiles. Le contexte vient de l'identité autorisée
par l'hôte : la bibliothèque n'authentifie pas un utilisateur et ne vérifie pas ses droits.
L'AAD V2 lie suite/version/key_id/mode/identité/usage. Une ancienne enveloppe valide au même
contexte peut être rejouée : anti-rollback, révisions et transactions appartiennent à l'hôte.
La clé compromise permet de déchiffrer/forger ; aucun wrapper ne protège un processus
entièrement compromis ou un administrateur contrôlant sa mémoire.

## Budgets de clés — aucune protection distribuée automatique

Nonces OS aléatoires96, tags128. Pour q nonces uniformes indépendants,
Pr[collision] <= q(q-1)/2^97. À q=2^24, cette borne est <2^-49 ; elle ne constitue
pas la sécurité globale GCM, qui dépend aussi des blocs traités et tentatives de falsification.
Politique opérationnelle proposée au CTO/hôte : <=2^24 scellements par matériel,
<=2^20 authentifications AEAD échouées avant blocage/rotation/investigation.
Le crate NE COMPTE PAS ces budgets globalement et ne fournit pas de compteur durable.
Renommage d'ID, alias de matériel, restart et réactivation ne réinitialisent jamais le budget.
L'hôte réserve les invocations avant usage, conserve les réservations au résultat inconnu,
agrège les instances et refuse une active épuisée. La taille d'un plaintext est bornée à1Mio.
Aucun quota documentaire ne doit être annoncé comme automatiquement imposé par le crate.

L'admission doit viser le snapshot réellement utilisé : capturer S, réserver durablement
une invocation de son matériel actif, puis exécuter un seul scellement (ou rechiffrement
potentiel) avec StaticKeyResolver(S). Ne pas réserver pour un ID puis laisser un resolver
dynamique en choisir un autre. Une réservation couvre au plus un scellement possible ;
si l'issue est inconnue, elle reste consommée. Le résultat Current peut être facturé
conservativement. L'hôte peut aussi intégrer une admission conservatrice dans son resolver,
mais aucune admission globale n'est fournie automatiquement par la bibliothèque.

## Clés et snapshots

L'hôte conserve un registre durable ID/matériel/états/tombstones et les budgets, puis le
restaure avant admission du trafic. insert_revoked importe les tombstones sans la clé
retirée. Ne pas publier un registre restauré sans en garantir l'authenticité/intégrité.
Construire hors verrou, puis comparer au snapshot courant avec validate_successor et
échanger l'Arc dans une même section critique/CAS. Ne jamais oublier un tombstone ;
capacité64 IDs, y compris révoqués, sans compaction automatique.
Une opération capture exactement une génération. Current authentifie et n'est relatif
qu'à cette génération ; il ne prouve pas une migration complète de la base.
Utiliser transactions/CAS pour enregistrer un rechiffrement sans écraser une modification
concurrente. Migration, révocation et destruction sont trois actions distinctes.
Les anciens Arc/opérations peuvent encore fonctionner : arrêter les anciennes instances
si la révocation doit être immédiate. Sauvegardes/rétention/destruction restent à l'hôte.

## Fichier : profil Linux x86_64 et répertoire de confiance

Profil cible à qualifier sur ext4/XFS locaux ; pas de promesse NFS/SMB/FUSE/overlay.
Un succès sur overlay cloud ne prouve pas la durabilité après panne électrique.
Parent absolu précréé, propriétaire administré par l'hôte, mode0700 (ou0500 pour lecture),
fichier régulier0600/0400 et même propriétaire. Aucune réparation automatique de droits.
Les liens et objets spéciaux observés sont refusés ; comparaison d'identité et metadata
avant/après ouverture ; contenu Base64 canonique borné44 bytes, éventuel LF unique.
Ces contrôles std NE SONT PAS un parcours anti-TOCTOU universel : un acteur pouvant
modifier les parents, agir comme le même UID hostile ou contrôler le processus est hors
modèle. Si ces préconditions ne sont pas assurées, ne pas utiliser ce backend ; un backend
OS no-follow/descripteur-relatif requiert conception et autorisation distinctes.

AllowGenerateDevelopment ne convient pas à la politique production : l'hôte doit l'interdire.
Création exclusive d'un temporaire privé dans le même répertoire, écriture complète et
sync_all, hard_link sans remplacement, sync répertoire, nettoyage du seul temporaire propre
et nouvelle sync. Le gagnant concurrent est rechargé et synchronisé. Un final corrompu,
tronqué, manquant en strict ou insecure n'est jamais remplacé pour « réparer » une clé.
Tout lecteur synchronise fichier/répertoire avant succès sur le profil qualifié.

Atomicité : le nom final apparaît absent ou complet. Durabilité : dépend des sync et du
filesystem/contrôleur qualifiés. Nettoyage : concerne les noms temporaires, distinct de la clé.
Avant publication, erreur sans nouveau final ; un temporaire orphelin reste possible après crash.
Après publication et avant durabilité confirmée : DurabilityUncertain, aucune clé rendue,
final conservé pour relecture/validation/synchronisation explicite. Après confirmation mais
nettoyage échoué : CleanupFailed, final conservé ; aucune régénération ni suppression du final.
Ne jamais promouvoir automatiquement un temporaire trouvé au redémarrage. Une clé perdue
n'est pas récupérable en générant d'autres bytes sous le même identifiant.

## Mémoire et ressources

Buffers possédés protégés avant remplissage ; sorties AES déchiffrées et workspace Argon2
entourés de zeroize sur succès et erreurs. Base64/PHC temporaires contrôlés protégés.
SecretBytes/String refusent longueur ou capacité >1Mio ; PHC et coûts bornés avant Argon2.
Le coût d'effacer un buffer externe déjà excessif ne peut être borné rétroactivement.
Limiter les calculs concurrents et utiliser un dispatch bloquant approprié à l'hôte.

Zeroize ne promet pas d'effacer toutes copies/transferts de pile, registres, états internes
HMAC/HKDF, anciens buffers OS, environnement source, swap, dumps ou sauvegardes. Features
AES/GHASH/POLYVAL/Argon2 vérifiées sur le backend visé ; cela ne qualifie pas tous les
backends ARM ou autres. mem::forget, ManuallyDrop, fuite d'Arc, abort ou processus tué
peuvent empêcher l'exécution des destructeurs. Aucune lecture après free ne sert de preuve.
L'exposition explicite de plaintext/PHC rend l'appelant responsable de ses copies et logs.

## Validation et signalement

Les tests, campagnes et dépendances réellement contrôlés figurent dans IMPLEMENTATION_REPORT.md.
Les scans RustSec sont datés ; l'absence d'alerte connue ne prouve pas l'absence de vulnérabilité.
Signaler tout incident au responsable sécurité/CTO LYXAL OS ; ne jamais joindre une clé réelle
ou un secret dans une trace publique. Aucune journalisation de contenu sensible n'est offerte.
