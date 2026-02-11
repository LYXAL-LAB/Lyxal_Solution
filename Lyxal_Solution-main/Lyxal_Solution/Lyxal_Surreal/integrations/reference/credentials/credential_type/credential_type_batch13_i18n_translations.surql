-- =============================================================================================
-- |
-- | Fichier : credential_type_batch13_i18n_translations.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Traductions multilingues pour le Batch 13 des credential types.
-- |
-- | Batch 13 : AI, Analytics & Developer Tools (11 credentials)
-- | Providers : OpenAI, Perplexity, DeepL, Datadog, Linear, Figma, Miro, N8n, Ghost
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : 165 traductions (33 clés × 5 langues)
-- |
-- =============================================================================================

-- =====================================================
-- OPENAI API
-- =====================================================

RELATE i18n_key:credential_type_openai_api_name->translation->language:fr SET text = "OpenAI API";
RELATE i18n_key:credential_type_openai_api_name->translation->language:en SET text = "OpenAI API";
RELATE i18n_key:credential_type_openai_api_name->translation->language:it SET text = "OpenAI API";
RELATE i18n_key:credential_type_openai_api_name->translation->language:de SET text = "OpenAI API";
RELATE i18n_key:credential_type_openai_api_name->translation->language:es SET text = "OpenAI API";

RELATE i18n_key:credential_type_openai_api_description->translation->language:fr SET text = "Authentification par clé API pour OpenAI. Leader IA pour génération texte (GPT), images (DALL-E), audio (Whisper) et embeddings.";
RELATE i18n_key:credential_type_openai_api_description->translation->language:en SET text = "API key authentication for OpenAI. AI leader for text generation (GPT), images (DALL-E), audio (Whisper) and embeddings.";
RELATE i18n_key:credential_type_openai_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per OpenAI. Leader IA per generazione testo (GPT), immagini (DALL-E), audio (Whisper) ed embeddings.";
RELATE i18n_key:credential_type_openai_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für OpenAI. KI-Marktführer für Textgenerierung (GPT), Bilder (DALL-E), Audio (Whisper) und Embeddings.";
RELATE i18n_key:credential_type_openai_api_description->translation->language:es SET text = "Autenticación mediante clave API para OpenAI. Líder IA para generación texto (GPT), imágenes (DALL-E), audio (Whisper) y embeddings.";

RELATE i18n_key:credential_type_openai_api_tooltip->translation->language:fr SET text = "Pour OpenAI GPT, DALL-E, Whisper";
RELATE i18n_key:credential_type_openai_api_tooltip->translation->language:en SET text = "For OpenAI GPT, DALL-E, Whisper";
RELATE i18n_key:credential_type_openai_api_tooltip->translation->language:it SET text = "Per OpenAI GPT, DALL-E, Whisper";
RELATE i18n_key:credential_type_openai_api_tooltip->translation->language:de SET text = "Für OpenAI GPT, DALL-E, Whisper";
RELATE i18n_key:credential_type_openai_api_tooltip->translation->language:es SET text = "Para OpenAI GPT, DALL-E, Whisper";

-- =====================================================
-- PERPLEXITY API
-- =====================================================

RELATE i18n_key:credential_type_perplexity_api_name->translation->language:fr SET text = "Perplexity API";
RELATE i18n_key:credential_type_perplexity_api_name->translation->language:en SET text = "Perplexity API";
RELATE i18n_key:credential_type_perplexity_api_name->translation->language:it SET text = "Perplexity API";
RELATE i18n_key:credential_type_perplexity_api_name->translation->language:de SET text = "Perplexity API";
RELATE i18n_key:credential_type_perplexity_api_name->translation->language:es SET text = "Perplexity API";

RELATE i18n_key:credential_type_perplexity_api_description->translation->language:fr SET text = "Authentification par clé API pour Perplexity. IA conversationnelle avec recherche web temps réel pour réponses à jour.";
RELATE i18n_key:credential_type_perplexity_api_description->translation->language:en SET text = "API key authentication for Perplexity. Conversational AI with real-time web search for up-to-date answers.";
RELATE i18n_key:credential_type_perplexity_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per Perplexity. IA conversazionale con ricerca web in tempo reale per risposte aggiornate.";
RELATE i18n_key:credential_type_perplexity_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für Perplexity. Konversations-KI mit Echtzeit-Websuche für aktuelle Antworten.";
RELATE i18n_key:credential_type_perplexity_api_description->translation->language:es SET text = "Autenticación mediante clave API para Perplexity. IA conversacional con búsqueda web tiempo real para respuestas actualizadas.";

RELATE i18n_key:credential_type_perplexity_api_tooltip->translation->language:fr SET text = "Pour Perplexity recherche IA temps réel";
RELATE i18n_key:credential_type_perplexity_api_tooltip->translation->language:en SET text = "For Perplexity real-time AI search";
RELATE i18n_key:credential_type_perplexity_api_tooltip->translation->language:it SET text = "Per Perplexity ricerca IA tempo reale";
RELATE i18n_key:credential_type_perplexity_api_tooltip->translation->language:de SET text = "Für Perplexity Echtzeit-KI-Suche";
RELATE i18n_key:credential_type_perplexity_api_tooltip->translation->language:es SET text = "Para Perplexity búsqueda IA tiempo real";

-- =====================================================
-- DEEPL API
-- =====================================================

RELATE i18n_key:credential_type_deepl_api_name->translation->language:fr SET text = "DeepL API";
RELATE i18n_key:credential_type_deepl_api_name->translation->language:en SET text = "DeepL API";
RELATE i18n_key:credential_type_deepl_api_name->translation->language:it SET text = "DeepL API";
RELATE i18n_key:credential_type_deepl_api_name->translation->language:de SET text = "DeepL API";
RELATE i18n_key:credential_type_deepl_api_name->translation->language:es SET text = "DeepL API";

RELATE i18n_key:credential_type_deepl_api_description->translation->language:fr SET text = "Authentification par clé API pour DeepL. Leader traduction automatique haute qualité supportant 29 langues avec IA.";
RELATE i18n_key:credential_type_deepl_api_description->translation->language:en SET text = "API key authentication for DeepL. High-quality automatic translation leader supporting 29 languages with AI.";
RELATE i18n_key:credential_type_deepl_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per DeepL. Leader traduzione automatica alta qualità supportando 29 lingue con IA.";
RELATE i18n_key:credential_type_deepl_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für DeepL. Marktführer für hochwertige maschinelle Übersetzung mit Unterstützung für 29 Sprachen und KI.";
RELATE i18n_key:credential_type_deepl_api_description->translation->language:es SET text = "Autenticación mediante clave API para DeepL. Líder traducción automática alta calidad soportando 29 idiomas con IA.";

RELATE i18n_key:credential_type_deepl_api_tooltip->translation->language:fr SET text = "Pour DeepL traduction IA 29 langues";
RELATE i18n_key:credential_type_deepl_api_tooltip->translation->language:en SET text = "For DeepL AI translation 29 languages";
RELATE i18n_key:credential_type_deepl_api_tooltip->translation->language:it SET text = "Per DeepL traduzione IA 29 lingue";
RELATE i18n_key:credential_type_deepl_api_tooltip->translation->language:de SET text = "Für DeepL KI-Übersetzung 29 Sprachen";
RELATE i18n_key:credential_type_deepl_api_tooltip->translation->language:es SET text = "Para DeepL traducción IA 29 idiomas";

-- =====================================================
-- DATADOG API
-- =====================================================

RELATE i18n_key:credential_type_datadog_api_name->translation->language:fr SET text = "Datadog API";
RELATE i18n_key:credential_type_datadog_api_name->translation->language:en SET text = "Datadog API";
RELATE i18n_key:credential_type_datadog_api_name->translation->language:it SET text = "Datadog API";
RELATE i18n_key:credential_type_datadog_api_name->translation->language:de SET text = "Datadog API";
RELATE i18n_key:credential_type_datadog_api_name->translation->language:es SET text = "Datadog API";

RELATE i18n_key:credential_type_datadog_api_description->translation->language:fr SET text = "Authentification par clés API et Application pour Datadog. Plateforme monitoring et observabilité pour métriques, logs et APM.";
RELATE i18n_key:credential_type_datadog_api_description->translation->language:en SET text = "API and Application keys authentication for Datadog. Monitoring and observability platform for metrics, logs and APM.";
RELATE i18n_key:credential_type_datadog_api_description->translation->language:it SET text = "Autenticazione tramite chiavi API e Application per Datadog. Piattaforma monitoring e osservabilità per metriche, log e APM.";
RELATE i18n_key:credential_type_datadog_api_description->translation->language:de SET text = "API- und Anwendungsschlüssel-Authentifizierung für Datadog. Monitoring- und Observability-Plattform für Metriken, Logs und APM.";
RELATE i18n_key:credential_type_datadog_api_description->translation->language:es SET text = "Autenticación mediante claves API y Application para Datadog. Plataforma monitoring y observabilidad para métricas, logs y APM.";

RELATE i18n_key:credential_type_datadog_api_tooltip->translation->language:fr SET text = "Pour Datadog monitoring et observabilité";
RELATE i18n_key:credential_type_datadog_api_tooltip->translation->language:en SET text = "For Datadog monitoring and observability";
RELATE i18n_key:credential_type_datadog_api_tooltip->translation->language:it SET text = "Per Datadog monitoring e osservabilità";
RELATE i18n_key:credential_type_datadog_api_tooltip->translation->language:de SET text = "Für Datadog Monitoring und Observability";
RELATE i18n_key:credential_type_datadog_api_tooltip->translation->language:es SET text = "Para Datadog monitoring y observabilidad";

-- =====================================================
-- LINEAR API
-- =====================================================

RELATE i18n_key:credential_type_linear_api_name->translation->language:fr SET text = "Linear API";
RELATE i18n_key:credential_type_linear_api_name->translation->language:en SET text = "Linear API";
RELATE i18n_key:credential_type_linear_api_name->translation->language:it SET text = "Linear API";
RELATE i18n_key:credential_type_linear_api_name->translation->language:de SET text = "Linear API";
RELATE i18n_key:credential_type_linear_api_name->translation->language:es SET text = "Linear API";

RELATE i18n_key:credential_type_linear_api_description->translation->language:fr SET text = "Authentification par clé API (Personal Access Token) pour Linear. Outil moderne gestion projet et suivi issues pour équipes développement.";
RELATE i18n_key:credential_type_linear_api_description->translation->language:en SET text = "API key (Personal Access Token) authentication for Linear. Modern project management and issue tracking tool for development teams.";
RELATE i18n_key:credential_type_linear_api_description->translation->language:it SET text = "Autenticazione tramite chiave API (Personal Access Token) per Linear. Strumento moderno gestione progetti e tracking issue per team sviluppo.";
RELATE i18n_key:credential_type_linear_api_description->translation->language:de SET text = "API-Schlüssel (Personal Access Token)-Authentifizierung für Linear. Modernes Projektmanagement- und Issue-Tracking-Tool für Entwicklungsteams.";
RELATE i18n_key:credential_type_linear_api_description->translation->language:es SET text = "Autenticación mediante clave API (Personal Access Token) para Linear. Herramienta moderna gestión proyectos y seguimiento issues para equipos desarrollo.";

RELATE i18n_key:credential_type_linear_api_tooltip->translation->language:fr SET text = "Pour Linear gestion projet moderne";
RELATE i18n_key:credential_type_linear_api_tooltip->translation->language:en SET text = "For Linear modern project management";
RELATE i18n_key:credential_type_linear_api_tooltip->translation->language:it SET text = "Per Linear gestione progetti moderna";
RELATE i18n_key:credential_type_linear_api_tooltip->translation->language:de SET text = "Für Linear modernes Projektmanagement";
RELATE i18n_key:credential_type_linear_api_tooltip->translation->language:es SET text = "Para Linear gestión proyectos moderna";

-- =====================================================
-- LINEAR OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_linear_oauth2_api_name->translation->language:fr SET text = "Linear OAuth2";
RELATE i18n_key:credential_type_linear_oauth2_api_name->translation->language:en SET text = "Linear OAuth2";
RELATE i18n_key:credential_type_linear_oauth2_api_name->translation->language:it SET text = "Linear OAuth2";
RELATE i18n_key:credential_type_linear_oauth2_api_name->translation->language:de SET text = "Linear OAuth2";
RELATE i18n_key:credential_type_linear_oauth2_api_name->translation->language:es SET text = "Linear OAuth2";

RELATE i18n_key:credential_type_linear_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Linear. Pour applications tierces avec authentification utilisateur et accès multi-compte.";
RELATE i18n_key:credential_type_linear_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Linear. For third-party applications with user authentication and multi-account access.";
RELATE i18n_key:credential_type_linear_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Linear. Per applicazioni terze con autenticazione utente e accesso multi-account.";
RELATE i18n_key:credential_type_linear_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Linear. Für Drittanbieteranwendungen mit Benutzer-Authentifizierung und Multi-Account-Zugriff.";
RELATE i18n_key:credential_type_linear_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Linear. Para aplicaciones terceros con autenticación usuario y acceso multi-cuenta.";

RELATE i18n_key:credential_type_linear_oauth2_api_tooltip->translation->language:fr SET text = "Pour apps tierces Linear avec OAuth2";
RELATE i18n_key:credential_type_linear_oauth2_api_tooltip->translation->language:en SET text = "For third-party Linear apps with OAuth2";
RELATE i18n_key:credential_type_linear_oauth2_api_tooltip->translation->language:it SET text = "Per app terze Linear con OAuth2";
RELATE i18n_key:credential_type_linear_oauth2_api_tooltip->translation->language:de SET text = "Für Drittanbieter-Linear-Apps mit OAuth2";
RELATE i18n_key:credential_type_linear_oauth2_api_tooltip->translation->language:es SET text = "Para apps terceros Linear con OAuth2";

-- =====================================================
-- FIGMA API
-- =====================================================

RELATE i18n_key:credential_type_figma_api_name->translation->language:fr SET text = "Figma API";
RELATE i18n_key:credential_type_figma_api_name->translation->language:en SET text = "Figma API";
RELATE i18n_key:credential_type_figma_api_name->translation->language:it SET text = "Figma API";
RELATE i18n_key:credential_type_figma_api_name->translation->language:de SET text = "Figma API";
RELATE i18n_key:credential_type_figma_api_name->translation->language:es SET text = "Figma API";

RELATE i18n_key:credential_type_figma_api_description->translation->language:fr SET text = "Authentification par token d'accès personnel pour Figma. Plateforme design collaboratif leader pour interfaces utilisateur et prototypes.";
RELATE i18n_key:credential_type_figma_api_description->translation->language:en SET text = "Personal access token authentication for Figma. Leading collaborative design platform for user interfaces and prototypes.";
RELATE i18n_key:credential_type_figma_api_description->translation->language:it SET text = "Autenticazione tramite token accesso personale per Figma. Piattaforma design collaborativo leader per interfacce utente e prototipi.";
RELATE i18n_key:credential_type_figma_api_description->translation->language:de SET text = "Personal Access Token-Authentifizierung für Figma. Führende kollaborative Designplattform für Benutzeroberflächen und Prototypen.";
RELATE i18n_key:credential_type_figma_api_description->translation->language:es SET text = "Autenticación mediante token acceso personal para Figma. Plataforma diseño colaborativo líder para interfaces usuario y prototipos.";

RELATE i18n_key:credential_type_figma_api_tooltip->translation->language:fr SET text = "Pour Figma design collaboratif";
RELATE i18n_key:credential_type_figma_api_tooltip->translation->language:en SET text = "For Figma collaborative design";
RELATE i18n_key:credential_type_figma_api_tooltip->translation->language:it SET text = "Per Figma design collaborativo";
RELATE i18n_key:credential_type_figma_api_tooltip->translation->language:de SET text = "Für Figma kollaboratives Design";
RELATE i18n_key:credential_type_figma_api_tooltip->translation->language:es SET text = "Para Figma diseño colaborativo";

-- =====================================================
-- MIRO OAUTH2 API
-- =====================================================

RELATE i18n_key:credential_type_miro_oauth2_api_name->translation->language:fr SET text = "Miro OAuth2";
RELATE i18n_key:credential_type_miro_oauth2_api_name->translation->language:en SET text = "Miro OAuth2";
RELATE i18n_key:credential_type_miro_oauth2_api_name->translation->language:it SET text = "Miro OAuth2";
RELATE i18n_key:credential_type_miro_oauth2_api_name->translation->language:de SET text = "Miro OAuth2";
RELATE i18n_key:credential_type_miro_oauth2_api_name->translation->language:es SET text = "Miro OAuth2";

RELATE i18n_key:credential_type_miro_oauth2_api_description->translation->language:fr SET text = "Authentification OAuth2 pour Miro. Plateforme tableau blanc collaboratif pour brainstorming, planning et collaboration visuelle.";
RELATE i18n_key:credential_type_miro_oauth2_api_description->translation->language:en SET text = "OAuth2 authentication for Miro. Collaborative whiteboard platform for brainstorming, planning and visual collaboration.";
RELATE i18n_key:credential_type_miro_oauth2_api_description->translation->language:it SET text = "Autenticazione OAuth2 per Miro. Piattaforma whiteboard collaborativa per brainstorming, planning e collaborazione visuale.";
RELATE i18n_key:credential_type_miro_oauth2_api_description->translation->language:de SET text = "OAuth2-Authentifizierung für Miro. Kollaborative Whiteboard-Plattform für Brainstorming, Planung und visuelle Zusammenarbeit.";
RELATE i18n_key:credential_type_miro_oauth2_api_description->translation->language:es SET text = "Autenticación OAuth2 para Miro. Plataforma pizarra colaborativa para brainstorming, planning y colaboración visual.";

RELATE i18n_key:credential_type_miro_oauth2_api_tooltip->translation->language:fr SET text = "Pour Miro tableau blanc collaboratif";
RELATE i18n_key:credential_type_miro_oauth2_api_tooltip->translation->language:en SET text = "For Miro collaborative whiteboard";
RELATE i18n_key:credential_type_miro_oauth2_api_tooltip->translation->language:it SET text = "Per Miro whiteboard collaborativa";
RELATE i18n_key:credential_type_miro_oauth2_api_tooltip->translation->language:de SET text = "Für Miro kollaboratives Whiteboard";
RELATE i18n_key:credential_type_miro_oauth2_api_tooltip->translation->language:es SET text = "Para Miro pizarra colaborativa";

-- =====================================================
-- N8N API
-- =====================================================

RELATE i18n_key:credential_type_n8n_api_name->translation->language:fr SET text = "n8n API";
RELATE i18n_key:credential_type_n8n_api_name->translation->language:en SET text = "n8n API";
RELATE i18n_key:credential_type_n8n_api_name->translation->language:it SET text = "n8n API";
RELATE i18n_key:credential_type_n8n_api_name->translation->language:de SET text = "n8n API";
RELATE i18n_key:credential_type_n8n_api_name->translation->language:es SET text = "n8n API";

RELATE i18n_key:credential_type_n8n_api_description->translation->language:fr SET text = "Authentification par clé API pour n8n. Plateforme automatisation workflows open-source extensible pour connecter applications.";
RELATE i18n_key:credential_type_n8n_api_description->translation->language:en SET text = "API key authentication for n8n. Open-source extensible workflow automation platform to connect applications.";
RELATE i18n_key:credential_type_n8n_api_description->translation->language:it SET text = "Autenticazione tramite chiave API per n8n. Piattaforma automazione workflow open-source estensibile per connettere applicazioni.";
RELATE i18n_key:credential_type_n8n_api_description->translation->language:de SET text = "API-Schlüssel-Authentifizierung für n8n. Open-Source-erweiterbare Workflow-Automatisierungsplattform zum Verbinden von Anwendungen.";
RELATE i18n_key:credential_type_n8n_api_description->translation->language:es SET text = "Autenticación mediante clave API para n8n. Plataforma automatización workflows open-source extensible para conectar aplicaciones.";

RELATE i18n_key:credential_type_n8n_api_tooltip->translation->language:fr SET text = "Pour n8n automatisation workflows";
RELATE i18n_key:credential_type_n8n_api_tooltip->translation->language:en SET text = "For n8n workflow automation";
RELATE i18n_key:credential_type_n8n_api_tooltip->translation->language:it SET text = "Per n8n automazione workflow";
RELATE i18n_key:credential_type_n8n_api_tooltip->translation->language:de SET text = "Für n8n Workflow-Automatisierung";
RELATE i18n_key:credential_type_n8n_api_tooltip->translation->language:es SET text = "Para n8n automatización workflows";

-- =====================================================
-- GHOST ADMIN API
-- =====================================================

RELATE i18n_key:credential_type_ghost_admin_api_name->translation->language:fr SET text = "Ghost Admin API";
RELATE i18n_key:credential_type_ghost_admin_api_name->translation->language:en SET text = "Ghost Admin API";
RELATE i18n_key:credential_type_ghost_admin_api_name->translation->language:it SET text = "Ghost Admin API";
RELATE i18n_key:credential_type_ghost_admin_api_name->translation->language:de SET text = "Ghost Admin API";
RELATE i18n_key:credential_type_ghost_admin_api_name->translation->language:es SET text = "Ghost Admin API";

RELATE i18n_key:credential_type_ghost_admin_api_description->translation->language:fr SET text = "Authentification JWT pour Ghost Admin API. CMS open-source pour publications et blogs avec accès administration complet.";
RELATE i18n_key:credential_type_ghost_admin_api_description->translation->language:en SET text = "JWT authentication for Ghost Admin API. Open-source CMS for publications and blogs with full administration access.";
RELATE i18n_key:credential_type_ghost_admin_api_description->translation->language:it SET text = "Autenticazione JWT per Ghost Admin API. CMS open-source per pubblicazioni e blog con accesso amministrazione completo.";
RELATE i18n_key:credential_type_ghost_admin_api_description->translation->language:de SET text = "JWT-Authentifizierung für Ghost Admin API. Open-Source-CMS für Publikationen und Blogs mit vollem Administratorzugriff.";
RELATE i18n_key:credential_type_ghost_admin_api_description->translation->language:es SET text = "Autenticación JWT para Ghost Admin API. CMS open-source para publicaciones y blogs con acceso administración completo.";

RELATE i18n_key:credential_type_ghost_admin_api_tooltip->translation->language:fr SET text = "Pour Ghost CMS accès admin complet";
RELATE i18n_key:credential_type_ghost_admin_api_tooltip->translation->language:en SET text = "For Ghost CMS full admin access";
RELATE i18n_key:credential_type_ghost_admin_api_tooltip->translation->language:it SET text = "Per Ghost CMS accesso admin completo";
RELATE i18n_key:credential_type_ghost_admin_api_tooltip->translation->language:de SET text = "Für Ghost CMS voller Admin-Zugriff";
RELATE i18n_key:credential_type_ghost_admin_api_tooltip->translation->language:es SET text = "Para Ghost CMS acceso admin completo";

-- =====================================================
-- GHOST CONTENT API
-- =====================================================

RELATE i18n_key:credential_type_ghost_content_api_name->translation->language:fr SET text = "Ghost Content API";
RELATE i18n_key:credential_type_ghost_content_api_name->translation->language:en SET text = "Ghost Content API";
RELATE i18n_key:credential_type_ghost_content_api_name->translation->language:it SET text = "Ghost Content API";
RELATE i18n_key:credential_type_ghost_content_api_name->translation->language:de SET text = "Ghost Content API";
RELATE i18n_key:credential_type_ghost_content_api_name->translation->language:es SET text = "Ghost Content API";

RELATE i18n_key:credential_type_ghost_content_api_description->translation->language:fr SET text = "Authentification par clé API publique pour Ghost Content API. Accès lecture seule contenu publié pour intégrations externes.";
RELATE i18n_key:credential_type_ghost_content_api_description->translation->language:en SET text = "Public API key authentication for Ghost Content API. Read-only access to published content for external integrations.";
RELATE i18n_key:credential_type_ghost_content_api_description->translation->language:it SET text = "Autenticazione tramite chiave API pubblica per Ghost Content API. Accesso sola lettura contenuto pubblicato per integrazioni esterne.";
RELATE i18n_key:credential_type_ghost_content_api_description->translation->language:de SET text = "Öffentliche API-Schlüssel-Authentifizierung für Ghost Content API. Nur-Lese-Zugriff auf veröffentlichte Inhalte für externe Integrationen.";
RELATE i18n_key:credential_type_ghost_content_api_description->translation->language:es SET text = "Autenticación mediante clave API pública para Ghost Content API. Acceso solo lectura contenido publicado para integraciones externas.";

RELATE i18n_key:credential_type_ghost_content_api_tooltip->translation->language:fr SET text = "Pour Ghost CMS lecture contenu public";
RELATE i18n_key:credential_type_ghost_content_api_tooltip->translation->language:en SET text = "For Ghost CMS read public content";
RELATE i18n_key:credential_type_ghost_content_api_tooltip->translation->language:it SET text = "Per Ghost CMS lettura contenuto pubblico";
RELATE i18n_key:credential_type_ghost_content_api_tooltip->translation->language:de SET text = "Für Ghost CMS öffentlichen Inhalt lesen";
RELATE i18n_key:credential_type_ghost_content_api_tooltip->translation->language:es SET text = "Para Ghost CMS lectura contenido público";

-- =============================================================================================
