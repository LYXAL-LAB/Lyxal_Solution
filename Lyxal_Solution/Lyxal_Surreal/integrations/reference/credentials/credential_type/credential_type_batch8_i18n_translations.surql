-- =============================================================================================
-- |
-- | Fichier : credential_type_batch8_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 8 des credential types.
-- |
-- | Batch 8 : Cloud, Storage & Infrastructure (17 credentials)
-- | Providers : AWS, S3, Cloudflare, Netlify, Supabase, Dropbox, Box, FTP, SSH, Webflow, WooCommerce, WordPress
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 255 traductions (51 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- AWS
-- =====================================================

RELATE i18n_key:credential_type_aws_name->translation->language:fr SET text = "AWS (Amazon Web Services)";
RELATE i18n_key:credential_type_aws_name->translation->language:en SET text = "AWS (Amazon Web Services)";
RELATE i18n_key:credential_type_aws_name->translation->language:it SET text = "AWS (Amazon Web Services)";
RELATE i18n_key:credential_type_aws_name->translation->language:de SET text = "AWS (Amazon Web Services)";
RELATE i18n_key:credential_type_aws_name->translation->language:es SET text = "AWS (Amazon Web Services)";

RELATE i18n_key:credential_type_aws_description->translation->language:fr SET text = "Authentification pour AWS. Plateforme cloud leader mondial pour compute, stockage, databases, ML, IoT et 200+ services cloud.";
RELATE i18n_key:credential_type_aws_description->translation->language:en SET text = "Authentication for AWS. Global cloud platform leader for compute, storage, databases, ML, IoT, and 200+ cloud services.";
RELATE i18n_key:credential_type_aws_description->translation->language:it SET text = "Autenticazione per AWS. Leader mondiale piattaforma cloud per compute, storage, database, ML, IoT e oltre 200 servizi cloud.";
RELATE i18n_key:credential_type_aws_description->translation->language:de SET text = "Authentifizierung für AWS. Weltweiter Cloud-Plattform-Marktführer für Compute, Storage, Datenbanken, ML, IoT und über 200 Cloud-Services.";
RELATE i18n_key:credential_type_aws_description->translation->language:es SET text = "Autenticación para AWS. Líder mundial plataforma cloud para compute, almacenamiento, bases datos, ML, IoT y más de 200 servicios cloud.";

RELATE i18n_key:credential_type_aws_tooltip->translation->language:fr SET text = "Pour services AWS (S3, Lambda, DynamoDB, etc.)";
RELATE i18n_key:credential_type_aws_tooltip->translation->language:en SET text = "For AWS services (S3, Lambda, DynamoDB, etc.)";
RELATE i18n_key:credential_type_aws_tooltip->translation->language:it SET text = "Per servizi AWS (S3, Lambda, DynamoDB, ecc.)";
RELATE i18n_key:credential_type_aws_tooltip->translation->language:de SET text = "Für AWS-Services (S3, Lambda, DynamoDB usw.)";
RELATE i18n_key:credential_type_aws_tooltip->translation->language:es SET text = "Para servicios AWS (S3, Lambda, DynamoDB, etc.)";

-- =====================================================
-- S3
-- =====================================================

RELATE i18n_key:credential_type_s3_name->translation->language:fr SET text = "Amazon S3";
RELATE i18n_key:credential_type_s3_name->translation->language:en SET text = "Amazon S3";
RELATE i18n_key:credential_type_s3_name->translation->language:it SET text = "Amazon S3";
RELATE i18n_key:credential_type_s3_name->translation->language:de SET text = "Amazon S3";
RELATE i18n_key:credential_type_s3_name->translation->language:es SET text = "Amazon S3";

RELATE i18n_key:credential_type_s3_description->translation->language:fr SET text = "Authentification pour Amazon S3. Service stockage objet scalable pour fichiers, backups, data lakes et hébergement statique.";
RELATE i18n_key:credential_type_s3_description->translation->language:en SET text = "Authentication for Amazon S3. Scalable object storage service for files, backups, data lakes, and static hosting.";
RELATE i18n_key:credential_type_s3_description->translation->language:it SET text = "Autenticazione per Amazon S3. Servizio storage oggetti scalabile per file, backup, data lake e hosting statico.";
RELATE i18n_key:credential_type_s3_description->translation->language:de SET text = "Authentifizierung für Amazon S3. Skalierbarer Objektspeicherdienst für Dateien, Backups, Data Lakes und statisches Hosting.";
RELATE i18n_key:credential_type_s3_description->translation->language:es SET text = "Autenticación para Amazon S3. Servicio almacenamiento objetos escalable para archivos, backups, data lakes y hosting estático.";

RELATE i18n_key:credential_type_s3_tooltip->translation->language:fr SET text = "Pour stockage fichiers Amazon S3";
RELATE i18n_key:credential_type_s3_tooltip->translation->language:en SET text = "For Amazon S3 file storage";
RELATE i18n_key:credential_type_s3_tooltip->translation->language:it SET text = "Per storage file Amazon S3";
RELATE i18n_key:credential_type_s3_tooltip->translation->language:de SET text = "Für Amazon S3 Dateispeicherung";
RELATE i18n_key:credential_type_s3_tooltip->translation->language:es SET text = "Para almacenamiento archivos Amazon S3";

-- =====================================================
-- CLOUDFLARE API
-- =====================================================

RELATE i18n_key:credential_type_cloudflare_api_name->translation->language:fr SET text = "Cloudflare API";
RELATE i18n_key:credential_type_cloudflare_api_name->translation->language:en SET text = "Cloudflare API";
RELATE i18n_key:credential_type_cloudflare_api_name->translation->language:it SET text = "Cloudflare API";
RELATE i18n_key:credential_type_cloudflare_api_name->translation->language:de SET text = "Cloudflare API";
RELATE i18n_key:credential_type_cloudflare_api_name->translation->language:es SET text = "Cloudflare API";

RELATE i18n_key:credential_type_cloudflare_api_description->translation->language:fr SET text = "Authentification pour Cloudflare. CDN global, sécurité DDoS, DNS, Workers edge computing et optimisation performance web.";
RELATE i18n_key:credential_type_cloudflare_api_description->translation->language:en SET text = "Authentication for Cloudflare. Global CDN, DDoS security, DNS, Workers edge computing, and web performance optimization.";
RELATE i18n_key:credential_type_cloudflare_api_description->translation->language:it SET text = "Autenticazione per Cloudflare. CDN globale, sicurezza DDoS, DNS, Workers edge computing e ottimizzazione performance web.";
RELATE i18n_key:credential_type_cloudflare_api_description->translation->language:de SET text = "Authentifizierung für Cloudflare. Globales CDN, DDoS-Sicherheit, DNS, Workers Edge Computing und Web-Performance-Optimierung.";
RELATE i18n_key:credential_type_cloudflare_api_description->translation->language:es SET text = "Autenticación para Cloudflare. CDN global, seguridad DDoS, DNS, Workers edge computing y optimización rendimiento web.";

RELATE i18n_key:credential_type_cloudflare_api_tooltip->translation->language:fr SET text = "Pour CDN Cloudflare et gestion DNS";
RELATE i18n_key:credential_type_cloudflare_api_tooltip->translation->language:en SET text = "For Cloudflare CDN and DNS management";
RELATE i18n_key:credential_type_cloudflare_api_tooltip->translation->language:it SET text = "Per CDN Cloudflare e gestione DNS";
RELATE i18n_key:credential_type_cloudflare_api_tooltip->translation->language:de SET text = "Für Cloudflare CDN und DNS-Verwaltung";
RELATE i18n_key:credential_type_cloudflare_api_tooltip->translation->language:es SET text = "Para CDN Cloudflare y gestión DNS";

-- =====================================================
-- NETLIFY API
-- =====================================================

RELATE i18n_key:credential_type_netlify_api_name->translation->language:fr SET text = "Netlify API";
RELATE i18n_key:credential_type_netlify_api_name->translation->language:en SET text = "Netlify API";
RELATE i18n_key:credential_type_netlify_api_name->translation->language:it SET text = "Netlify API";
RELATE i18n_key:credential_type_netlify_api_name->translation->language:de SET text = "Netlify API";
RELATE i18n_key:credential_type_netlify_api_name->translation->language:es SET text = "Netlify API";

RELATE i18n_key:credential_type_netlify_api_description->translation->language:fr SET text = "Authentification pour Netlify. Plateforme hébergement JAMstack pour sites statiques, serverless functions et déploiements automatisés Git.";
RELATE i18n_key:credential_type_netlify_api_description->translation->language:en SET text = "Authentication for Netlify. JAMstack hosting platform for static sites, serverless functions, and automated Git deployments.";
RELATE i18n_key:credential_type_netlify_api_description->translation->language:it SET text = "Autenticazione per Netlify. Piattaforma hosting JAMstack per siti statici, serverless functions e deploy automatizzati Git.";
RELATE i18n_key:credential_type_netlify_api_description->translation->language:de SET text = "Authentifizierung für Netlify. JAMstack-Hosting-Plattform für statische Websites, Serverless-Funktionen und automatisierte Git-Deployments.";
RELATE i18n_key:credential_type_netlify_api_description->translation->language:es SET text = "Autenticación para Netlify. Plataforma hosting JAMstack para sitios estáticos, serverless functions y despliegues automatizados Git.";

RELATE i18n_key:credential_type_netlify_api_tooltip->translation->language:fr SET text = "Pour hébergement Netlify et déploiements";
RELATE i18n_key:credential_type_netlify_api_tooltip->translation->language:en SET text = "For Netlify hosting and deployments";
RELATE i18n_key:credential_type_netlify_api_tooltip->translation->language:it SET text = "Per hosting Netlify e deploy";
RELATE i18n_key:credential_type_netlify_api_tooltip->translation->language:de SET text = "Für Netlify-Hosting und Deployments";
RELATE i18n_key:credential_type_netlify_api_tooltip->translation->language:es SET text = "Para hosting Netlify y despliegues";

-- =====================================================
-- SUPABASE API
-- =====================================================

RELATE i18n_key:credential_type_supabase_api_name->translation->language:fr SET text = "Supabase API";
RELATE i18n_key:credential_type_supabase_api_name->translation->language:en SET text = "Supabase API";
RELATE i18n_key:credential_type_supabase_api_name->translation->language:it SET text = "Supabase API";
RELATE i18n_key:credential_type_supabase_api_name->translation->language:de SET text = "Supabase API";
RELATE i18n_key:credential_type_supabase_api_name->translation->language:es SET text = "Supabase API";

RELATE i18n_key:credential_type_supabase_api_description->translation->language:fr SET text = "Authentification pour Supabase. Alternative Firebase open-source avec PostgreSQL, auth, storage, realtime et edge functions.";
RELATE i18n_key:credential_type_supabase_api_description->translation->language:en SET text = "Authentication for Supabase. Open-source Firebase alternative with PostgreSQL, auth, storage, realtime, and edge functions.";
RELATE i18n_key:credential_type_supabase_api_description->translation->language:it SET text = "Autenticazione per Supabase. Alternativa Firebase open-source con PostgreSQL, auth, storage, realtime ed edge functions.";
RELATE i18n_key:credential_type_supabase_api_description->translation->language:de SET text = "Authentifizierung für Supabase. Open-Source-Firebase-Alternative mit PostgreSQL, Auth, Storage, Realtime und Edge Functions.";
RELATE i18n_key:credential_type_supabase_api_description->translation->language:es SET text = "Autenticación para Supabase. Alternativa Firebase open-source con PostgreSQL, auth, storage, realtime y edge functions.";

RELATE i18n_key:credential_type_supabase_api_tooltip->translation->language:fr SET text = "Pour backend Supabase et database PostgreSQL";
RELATE i18n_key:credential_type_supabase_api_tooltip->translation->language:en SET text = "For Supabase backend and PostgreSQL database";
RELATE i18n_key:credential_type_supabase_api_tooltip->translation->language:it SET text = "Per backend Supabase e database PostgreSQL";
RELATE i18n_key:credential_type_supabase_api_tooltip->translation->language:de SET text = "Für Supabase-Backend und PostgreSQL-Datenbank";
RELATE i18n_key:credential_type_supabase_api_tooltip->translation->language:es SET text = "Para backend Supabase y base datos PostgreSQL";

-- =====================================================
-- DROPBOX API
-- =====================================================

RELATE i18n_key:credential_type_dropbox_api_name->translation->language:fr SET text = "Dropbox API";
RELATE i18n_key:credential_type_dropbox_api_name->translation->language:en SET text = "Dropbox API";
RELATE i18n_key:credential_type_dropbox_api_name->translation->language:it SET text = "Dropbox API";
RELATE i18n_key:credential_type_dropbox_api_name->translation->language:de SET text = "Dropbox API";
RELATE i18n_key:credential_type_dropbox_api_name->translation->language:es SET text = "Dropbox API";

RELATE i18n_key:credential_type_dropbox_api_description->translation->language:fr SET text = "Authentification par Access Token pour Dropbox. Service stockage cloud et partage fichiers pour collaboration équipe.";
RELATE i18n_key:credential_type_dropbox_api_description->translation->language:en SET text = "Access Token authentication for Dropbox. Cloud storage and file sharing service for team collaboration.";
RELATE i18n_key:credential_type_dropbox_api_description->translation->language:it SET text = "Autenticazione tramite Access Token per Dropbox. Servizio storage cloud e condivisione file per collaborazione team.";
RELATE i18n_key:credential_type_dropbox_api_description->translation->language:de SET text = "Access Token-Authentifizierung für Dropbox. Cloud-Speicher- und Dateifreigabedienst für Team-Zusammenarbeit.";
RELATE i18n_key:credential_type_dropbox_api_description->translation->language:es SET text = "Autenticación mediante Access Token para Dropbox. Servicio almacenamiento cloud y compartir archivos para colaboración equipo.";

RELATE i18n_key:credential_type_dropbox_api_tooltip->translation->language:fr SET text = "Pour stockage fichiers Dropbox";
RELATE i18n_key:credential_type_dropbox_api_tooltip->translation->language:en SET text = "For Dropbox file storage";
RELATE i18n_key:credential_type_dropbox_api_tooltip->translation->language:it SET text = "Per storage file Dropbox";
RELATE i18n_key:credential_type_dropbox_api_tooltip->translation->language:de SET text = "Für Dropbox-Dateispeicherung";
RELATE i18n_key:credential_type_dropbox_api_tooltip->translation->language:es SET text = "Para almacenamiento archivos Dropbox";

-- =====================================================
-- DROPBOX OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_dropbox_oauth2_api_name->translation->language:fr SET text = "Dropbox OAuth2";
RELATE i18n_key:credential_type_dropbox_oauth2_api_name->translation->language:en SET text = "Dropbox OAuth2";
RELATE i18n_key:credential_type_dropbox_oauth2_api_name->translation->language:it SET text = "Dropbox OAuth2";
RELATE i18n_key:credential_type_dropbox_oauth2_api_name->translation->language:de SET text = "Dropbox OAuth2";
RELATE i18n_key:credential_type_dropbox_oauth2_api_name->translation->language:es SET text = "Dropbox OAuth2";

RELATE i18n_key:credential_type_dropbox_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Dropbox. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_dropbox_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Dropbox. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_dropbox_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Dropbox. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_dropbox_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Dropbox. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_dropbox_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Dropbox. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_dropbox_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Dropbox avec OAuth2";
RELATE i18n_key:credential_type_dropbox_oauth2_api_tooltip->translation->language:en SET text = "For third-party Dropbox apps with OAuth2";
RELATE i18n_key:credential_type_dropbox_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Dropbox con OAuth2";
RELATE i18n_key:credential_type_dropbox_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Dropbox-Apps mit OAuth2";
RELATE i18n_key:credential_type_dropbox_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Dropbox con OAuth2";

-- =====================================================
-- BOX OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_box_oauth2_api_name->translation->language:fr SET text = "Box OAuth2";
RELATE i18n_key:credential_type_box_oauth2_api_name->translation->language:en SET text = "Box OAuth2";
RELATE i18n_key:credential_type_box_oauth2_api_name->translation->language:it SET text = "Box OAuth2";
RELATE i18n_key:credential_type_box_oauth2_api_name->translation->language:de SET text = "Box OAuth2";
RELATE i18n_key:credential_type_box_oauth2_api_name->translation->language:es SET text = "Box OAuth2";

RELATE i18n_key:credential_type_box_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Box. Plateforme stockage cloud entreprise pour collaboration sécurisée et gestion contenu.";
RELATE i18n_key:credential_type_box_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Box. Enterprise cloud storage platform for secure collaboration and content management.";
RELATE i18n_key:credential_type_box_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Box. Piattaforma storage cloud enterprise per collaborazione sicura e gestione contenuti.";
RELATE i18n_key:credential_type_box_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Box. Unternehmens-Cloud-Speicherplattform für sichere Zusammenarbeit und Content-Management.";
RELATE i18n_key:credential_type_box_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Box. Plataforma almacenamiento cloud empresarial para colaboración segura y gestión contenido.";

RELATE i18n_key:credential_type_box_oauth2_api_tooltip->translation->language:fr SET text = "Pour stockage entreprise Box et collaboration";
RELATE i18n_key:credential_type_box_oauth2_api_tooltip->translation->language:en SET text = "For Box enterprise storage and collaboration";
RELATE i18n_key:credential_type_box_oauth2_api_tooltip->translation->language:it SET text = "Per storage enterprise Box e collaborazione";
RELATE i18n_key:credential_type_box_oauth2_api_tooltip->translation->language:de SET text = "Für Box-Unternehmensspeicher und Zusammenarbeit";
RELATE i18n_key:credential_type_box_oauth2_api_tooltip->translation->language:es SET text = "Para almacenamiento empresarial Box y colaboración";

-- =====================================================
-- FTP
-- =====================================================

RELATE i18n_key:credential_type_ftp_name->translation->language:fr SET text = "FTP";
RELATE i18n_key:credential_type_ftp_name->translation->language:en SET text = "FTP";
RELATE i18n_key:credential_type_ftp_name->translation->language:it SET text = "FTP";
RELATE i18n_key:credential_type_ftp_name->translation->language:de SET text = "FTP";
RELATE i18n_key:credential_type_ftp_name->translation->language:es SET text = "FTP";

RELATE i18n_key:credential_type_ftp_description->translation->language:fr SET text = "Authentification pour FTP. Protocole standard transfert fichiers pour upload/download fichiers sur serveurs distants.";
RELATE i18n_key:credential_type_ftp_description->translation->language:en SET text = "Authentication for FTP. Standard file transfer protocol for uploading/downloading files to remote servers.";
RELATE i18n_key:credential_type_ftp_description->translation->language:it SET text = "Autenticazione per FTP. Protocollo standard trasferimento file per upload/download file su server remoti.";
RELATE i18n_key:credential_type_ftp_description->translation->language:de SET text = "Authentifizierung für FTP. Standard-Dateiübertragungsprotokoll zum Hochladen/Herunterladen von Dateien auf entfernte Server.";
RELATE i18n_key:credential_type_ftp_description->translation->language:es SET text = "Autenticación para FTP. Protocolo estándar transferencia archivos para subir/descargar archivos en servidores remotos.";

RELATE i18n_key:credential_type_ftp_tooltip->translation->language:fr SET text = "Pour transfert fichiers FTP classique";
RELATE i18n_key:credential_type_ftp_tooltip->translation->language:en SET text = "For classic FTP file transfer";
RELATE i18n_key:credential_type_ftp_tooltip->translation->language:it SET text = "Per trasferimento file FTP classico";
RELATE i18n_key:credential_type_ftp_tooltip->translation->language:de SET text = "Für klassische FTP-Dateiübertragung";
RELATE i18n_key:credential_type_ftp_tooltip->translation->language:es SET text = "Para transferencia archivos FTP clásico";

-- =====================================================
-- SFTP
-- =====================================================

RELATE i18n_key:credential_type_sftp_name->translation->language:fr SET text = "SFTP";
RELATE i18n_key:credential_type_sftp_name->translation->language:en SET text = "SFTP";
RELATE i18n_key:credential_type_sftp_name->translation->language:it SET text = "SFTP";
RELATE i18n_key:credential_type_sftp_name->translation->language:de SET text = "SFTP";
RELATE i18n_key:credential_type_sftp_name->translation->language:es SET text = "SFTP";

RELATE i18n_key:credential_type_sftp_description->translation->language:fr SET text = "Authentification pour SFTP. Protocole transfert fichiers sécurisé via SSH pour connexions chiffrées et authentification forte.";
RELATE i18n_key:credential_type_sftp_description->translation->language:en SET text = "Authentication for SFTP. Secure file transfer protocol over SSH for encrypted connections and strong authentication.";
RELATE i18n_key:credential_type_sftp_description->translation->language:it SET text = "Autenticazione per SFTP. Protocollo trasferimento file sicuro tramite SSH per connessioni cifrate e autenticazione forte.";
RELATE i18n_key:credential_type_sftp_description->translation->language:de SET text = "Authentifizierung für SFTP. Sicheres Dateiübertragungsprotokoll über SSH für verschlüsselte Verbindungen und starke Authentifizierung.";
RELATE i18n_key:credential_type_sftp_description->translation->language:es SET text = "Autenticación para SFTP. Protocolo transferencia archivos seguro vía SSH para conexiones cifradas y autenticación fuerte.";

RELATE i18n_key:credential_type_sftp_tooltip->translation->language:fr SET text = "Pour transfert fichiers sécurisé SSH";
RELATE i18n_key:credential_type_sftp_tooltip->translation->language:en SET text = "For secure SSH file transfer";
RELATE i18n_key:credential_type_sftp_tooltip->translation->language:it SET text = "Per trasferimento file sicuro SSH";
RELATE i18n_key:credential_type_sftp_tooltip->translation->language:de SET text = "Für sichere SSH-Dateiübertragung";
RELATE i18n_key:credential_type_sftp_tooltip->translation->language:es SET text = "Para transferencia archivos segura SSH";

-- =====================================================
-- SSH PASSWORD
-- =====================================================

RELATE i18n_key:credential_type_ssh_password_name->translation->language:fr SET text = "SSH Password";
RELATE i18n_key:credential_type_ssh_password_name->translation->language:en SET text = "SSH Password";
RELATE i18n_key:credential_type_ssh_password_name->translation->language:it SET text = "SSH Password";
RELATE i18n_key:credential_type_ssh_password_name->translation->language:de SET text = "SSH Password";
RELATE i18n_key:credential_type_ssh_password_name->translation->language:es SET text = "SSH Password";

RELATE i18n_key:credential_type_ssh_password_description->translation->language:fr SET text = "Authentification SSH par mot de passe. Pour connexions SSH serveurs distants avec authentification username/password.";
RELATE i18n_key:credential_type_ssh_password_description->translation->language:en SET text = "SSH password authentication. For SSH connections to remote servers with username/password authentication.";
RELATE i18n_key:credential_type_ssh_password_description->translation->language:it SET text = "Autenticazione SSH tramite password. Per connessioni SSH a server remoti con autenticazione username/password.";
RELATE i18n_key:credential_type_ssh_password_description->translation->language:de SET text = "SSH-Passwort-Authentifizierung. Für SSH-Verbindungen zu entfernten Servern mit Benutzername/Passwort-Authentifizierung.";
RELATE i18n_key:credential_type_ssh_password_description->translation->language:es SET text = "Autenticación SSH mediante contraseña. Para conexiones SSH a servidores remotos con autenticación usuario/contraseña.";

RELATE i18n_key:credential_type_ssh_password_tooltip->translation->language:fr SET text = "Pour connexion SSH avec mot de passe";
RELATE i18n_key:credential_type_ssh_password_tooltip->translation->language:en SET text = "For SSH connection with password";
RELATE i18n_key:credential_type_ssh_password_tooltip->translation->language:it SET text = "Per connessione SSH con password";
RELATE i18n_key:credential_type_ssh_password_tooltip->translation->language:de SET text = "Für SSH-Verbindung mit Passwort";
RELATE i18n_key:credential_type_ssh_password_tooltip->translation->language:es SET text = "Para conexión SSH con contraseña";

-- =====================================================
-- SSH PRIVATE KEY
-- =====================================================

RELATE i18n_key:credential_type_ssh_private_key_name->translation->language:fr SET text = "SSH Private Key";
RELATE i18n_key:credential_type_ssh_private_key_name->translation->language:en SET text = "SSH Private Key";
RELATE i18n_key:credential_type_ssh_private_key_name->translation->language:it SET text = "SSH Private Key";
RELATE i18n_key:credential_type_ssh_private_key_name->translation->language:de SET text = "SSH Private Key";
RELATE i18n_key:credential_type_ssh_private_key_name->translation->language:es SET text = "SSH Private Key";

RELATE i18n_key:credential_type_ssh_private_key_description->translation->language:fr SET text = "Authentification SSH par clé privée. Méthode sécurisée recommandée pour connexions SSH avec authentification cryptographique.";
RELATE i18n_key:credential_type_ssh_private_key_description->translation->language:en SET text = "SSH private key authentication. Recommended secure method for SSH connections with cryptographic authentication.";
RELATE i18n_key:credential_type_ssh_private_key_description->translation->language:it SET text = "Autenticazione SSH tramite chiave privata. Metodo sicuro consigliato per connessioni SSH con autenticazione crittografica.";
RELATE i18n_key:credential_type_ssh_private_key_description->translation->language:de SET text = "SSH-Privatschlüssel-Authentifizierung. Empfohlene sichere Methode für SSH-Verbindungen mit kryptografischer Authentifizierung.";
RELATE i18n_key:credential_type_ssh_private_key_description->translation->language:es SET text = "Autenticación SSH mediante clave privada. Método seguro recomendado para conexiones SSH con autenticación criptográfica.";

RELATE i18n_key:credential_type_ssh_private_key_tooltip->translation->language:fr SET text = "Pour connexion SSH sécurisée avec clé privée";
RELATE i18n_key:credential_type_ssh_private_key_tooltip->translation->language:en SET text = "For secure SSH connection with private key";
RELATE i18n_key:credential_type_ssh_private_key_tooltip->translation->language:it SET text = "Per connessione SSH sicura con chiave privata";
RELATE i18n_key:credential_type_ssh_private_key_tooltip->translation->language:de SET text = "Für sichere SSH-Verbindung mit Privatschlüssel";
RELATE i18n_key:credential_type_ssh_private_key_tooltip->translation->language:es SET text = "Para conexión SSH segura con clave privada";

-- =====================================================
-- WEBFLOW API
-- =====================================================

RELATE i18n_key:credential_type_webflow_api_name->translation->language:fr SET text = "Webflow API";
RELATE i18n_key:credential_type_webflow_api_name->translation->language:en SET text = "Webflow API";
RELATE i18n_key:credential_type_webflow_api_name->translation->language:it SET text = "Webflow API";
RELATE i18n_key:credential_type_webflow_api_name->translation->language:de SET text = "Webflow API";
RELATE i18n_key:credential_type_webflow_api_name->translation->language:es SET text = "Webflow API";

RELATE i18n_key:credential_type_webflow_api_description->translation->language:fr SET text = "Authentification par Access Token pour Webflow. Plateforme no-code pour créer sites web professionnels avec CMS intégré.";
RELATE i18n_key:credential_type_webflow_api_description->translation->language:en SET text = "Access Token authentication for Webflow. No-code platform for creating professional websites with integrated CMS.";
RELATE i18n_key:credential_type_webflow_api_description->translation->language:it SET text = "Autenticazione tramite Access Token per Webflow. Piattaforma no-code per creare siti web professionali con CMS integrato.";
RELATE i18n_key:credential_type_webflow_api_description->translation->language:de SET text = "Access Token-Authentifizierung für Webflow. No-Code-Plattform zur Erstellung professioneller Websites mit integriertem CMS.";
RELATE i18n_key:credential_type_webflow_api_description->translation->language:es SET text = "Autenticación mediante Access Token para Webflow. Plataforma no-code para crear sitios web profesionales con CMS integrado.";

RELATE i18n_key:credential_type_webflow_api_tooltip->translation->language:fr SET text = "Pour CMS Webflow et gestion sites no-code";
RELATE i18n_key:credential_type_webflow_api_tooltip->translation->language:en SET text = "For Webflow CMS and no-code site management";
RELATE i18n_key:credential_type_webflow_api_tooltip->translation->language:it SET text = "Per CMS Webflow e gestione siti no-code";
RELATE i18n_key:credential_type_webflow_api_tooltip->translation->language:de SET text = "Für Webflow CMS und No-Code-Website-Verwaltung";
RELATE i18n_key:credential_type_webflow_api_tooltip->translation->language:es SET text = "Para CMS Webflow y gestión sitios no-code";

-- =====================================================
-- WEBFLOW OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_webflow_oauth2_api_name->translation->language:fr SET text = "Webflow OAuth2";
RELATE i18n_key:credential_type_webflow_oauth2_api_name->translation->language:en SET text = "Webflow OAuth2";
RELATE i18n_key:credential_type_webflow_oauth2_api_name->translation->language:it SET text = "Webflow OAuth2";
RELATE i18n_key:credential_type_webflow_oauth2_api_name->translation->language:de SET text = "Webflow OAuth2";
RELATE i18n_key:credential_type_webflow_oauth2_api_name->translation->language:es SET text = "Webflow OAuth2";

RELATE i18n_key:credential_type_webflow_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Webflow. Pour applications tierces avec authentification utilisateur et accès multi-site.";
RELATE i18n_key:credential_type_webflow_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Webflow. For third-party applications with user authentication and multi-site access.";
RELATE i18n_key:credential_type_webflow_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Webflow. Per applicazioni terze con autenticazione utente e accesso multi-sito.";
RELATE i18n_key:credential_type_webflow_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Webflow. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Site-Zugriff.";
RELATE i18n_key:credential_type_webflow_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Webflow. Para aplicaciones terceros con autenticación usuario y acceso multi-sitio.";

RELATE i18n_key:credential_type_webflow_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Webflow avec OAuth2";
RELATE i18n_key:credential_type_webflow_oauth2_api_tooltip->translation->language:en SET text = "For third-party Webflow apps with OAuth2";
RELATE i18n_key:credential_type_webflow_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Webflow con OAuth2";
RELATE i18n_key:credential_type_webflow_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Webflow-Apps mit OAuth2";
RELATE i18n_key:credential_type_webflow_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Webflow con OAuth2";

-- =====================================================
-- WOOCOMMERCE API
-- =====================================================

RELATE i18n_key:credential_type_woocommerce_api_name->translation->language:fr SET text = "WooCommerce API";
RELATE i18n_key:credential_type_woocommerce_api_name->translation->language:en SET text = "WooCommerce API";
RELATE i18n_key:credential_type_woocommerce_api_name->translation->language:it SET text = "WooCommerce API";
RELATE i18n_key:credential_type_woocommerce_api_name->translation->language:de SET text = "WooCommerce API";
RELATE i18n_key:credential_type_woocommerce_api_name->translation->language:es SET text = "WooCommerce API";

RELATE i18n_key:credential_type_woocommerce_api_description->translation->language:fr SET text = "Authentification pour WooCommerce. Plugin e-commerce WordPress leader pour créer boutiques en ligne et gérer produits/commandes.";
RELATE i18n_key:credential_type_woocommerce_api_description->translation->language:en SET text = "Authentication for WooCommerce. Leading WordPress e-commerce plugin for creating online stores and managing products/orders.";
RELATE i18n_key:credential_type_woocommerce_api_description->translation->language:it SET text = "Autenticazione per WooCommerce. Plugin e-commerce WordPress leader per creare negozi online e gestire prodotti/ordini.";
RELATE i18n_key:credential_type_woocommerce_api_description->translation->language:de SET text = "Authentifizierung für WooCommerce. Führendes WordPress-E-Commerce-Plugin zum Erstellen von Online-Shops und Verwalten von Produkten/Bestellungen.";
RELATE i18n_key:credential_type_woocommerce_api_description->translation->language:es SET text = "Autenticación para WooCommerce. Plugin e-commerce WordPress líder para crear tiendas online y gestionar productos/pedidos.";

RELATE i18n_key:credential_type_woocommerce_api_tooltip->translation->language:fr SET text = "Pour e-commerce WooCommerce et boutiques WordPress";
RELATE i18n_key:credential_type_woocommerce_api_tooltip->translation->language:en SET text = "For WooCommerce e-commerce and WordPress stores";
RELATE i18n_key:credential_type_woocommerce_api_tooltip->translation->language:it SET text = "Per e-commerce WooCommerce e negozi WordPress";
RELATE i18n_key:credential_type_woocommerce_api_tooltip->translation->language:de SET text = "Für WooCommerce E-Commerce und WordPress-Shops";
RELATE i18n_key:credential_type_woocommerce_api_tooltip->translation->language:es SET text = "Para e-commerce WooCommerce y tiendas WordPress";

-- =====================================================
-- WORDPRESS API
-- =====================================================

RELATE i18n_key:credential_type_wordpress_api_name->translation->language:fr SET text = "WordPress API";
RELATE i18n_key:credential_type_wordpress_api_name->translation->language:en SET text = "WordPress API";
RELATE i18n_key:credential_type_wordpress_api_name->translation->language:it SET text = "WordPress API";
RELATE i18n_key:credential_type_wordpress_api_name->translation->language:de SET text = "WordPress API";
RELATE i18n_key:credential_type_wordpress_api_name->translation->language:es SET text = "WordPress API";

RELATE i18n_key:credential_type_wordpress_api_description->translation->language:fr SET text = "Authentification pour WordPress. CMS open-source leader mondial pour créer sites web, blogs et applications avec plugins extensibles.";
RELATE i18n_key:credential_type_wordpress_api_description->translation->language:en SET text = "Authentication for WordPress. Global leading open-source CMS for creating websites, blogs, and applications with extensible plugins.";
RELATE i18n_key:credential_type_wordpress_api_description->translation->language:it SET text = "Autenticazione per WordPress. CMS open-source leader mondiale per creare siti web, blog e applicazioni con plugin estensibili.";
RELATE i18n_key:credential_type_wordpress_api_description->translation->language:de SET text = "Authentifizierung für WordPress. Weltweit führendes Open-Source-CMS zum Erstellen von Websites, Blogs und Anwendungen mit erweiterbaren Plugins.";
RELATE i18n_key:credential_type_wordpress_api_description->translation->language:es SET text = "Autenticación para WordPress. CMS open-source líder mundial para crear sitios web, blogs y aplicaciones con plugins extensibles.";

RELATE i18n_key:credential_type_wordpress_api_tooltip->translation->language:fr SET text = "Pour CMS WordPress et gestion contenu";
RELATE i18n_key:credential_type_wordpress_api_tooltip->translation->language:en SET text = "For WordPress CMS and content management";
RELATE i18n_key:credential_type_wordpress_api_tooltip->translation->language:it SET text = "Per CMS WordPress e gestione contenuti";
RELATE i18n_key:credential_type_wordpress_api_tooltip->translation->language:de SET text = "Für WordPress CMS und Content-Management";
RELATE i18n_key:credential_type_wordpress_api_tooltip->translation->language:es SET text = "Para CMS WordPress y gestión contenido";

-- =====================================================
-- KOBOTOOLBOX API
-- =====================================================

RELATE i18n_key:credential_type_kobotoolbox_api_name->translation->language:fr SET text = "KoBoToolbox API";
RELATE i18n_key:credential_type_kobotoolbox_api_name->translation->language:en SET text = "KoBoToolbox API";
RELATE i18n_key:credential_type_kobotoolbox_api_name->translation->language:it SET text = "KoBoToolbox API";
RELATE i18n_key:credential_type_kobotoolbox_api_name->translation->language:de SET text = "KoBoToolbox API";
RELATE i18n_key:credential_type_kobotoolbox_api_name->translation->language:es SET text = "KoBoToolbox API";

RELATE i18n_key:credential_type_kobotoolbox_api_description->translation->language:fr SET text = "Authentification pour KoBoToolbox. Plateforme collecte données terrain pour enquêtes humanitaires et recherche en zones difficiles.";
RELATE i18n_key:credential_type_kobotoolbox_api_description->translation->language:en SET text = "Authentication for KoBoToolbox. Field data collection platform for humanitarian surveys and research in challenging areas.";
RELATE i18n_key:credential_type_kobotoolbox_api_description->translation->language:it SET text = "Autenticazione per KoBoToolbox. Piattaforma raccolta dati campo per sondaggi umanitari e ricerca in aree difficili.";
RELATE i18n_key:credential_type_kobotoolbox_api_description->translation->language:de SET text = "Authentifizierung für KoBoToolbox. Felddatenerhebungsplattform für humanitäre Umfragen und Forschung in herausfordernden Gebieten.";
RELATE i18n_key:credential_type_kobotoolbox_api_description->translation->language:es SET text = "Autenticación para KoBoToolbox. Plataforma recolección datos campo para encuestas humanitarias e investigación en áreas difíciles.";

RELATE i18n_key:credential_type_kobotoolbox_api_tooltip->translation->language:fr SET text = "Pour collecte données terrain et enquêtes";
RELATE i18n_key:credential_type_kobotoolbox_api_tooltip->translation->language:en SET text = "For field data collection and surveys";
RELATE i18n_key:credential_type_kobotoolbox_api_tooltip->translation->language:it SET text = "Per raccolta dati campo e sondaggi";
RELATE i18n_key:credential_type_kobotoolbox_api_tooltip->translation->language:de SET text = "Für Felddatenerhebung und Umfragen";
RELATE i18n_key:credential_type_kobotoolbox_api_tooltip->translation->language:es SET text = "Para recolección datos campo y encuestas";

-- =============================================================================================

