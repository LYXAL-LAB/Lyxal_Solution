// Configuration centralisée avec validation au démarrage
// Portage 1:1 de backend/internal/infrastructure/config/config.go

interface AppConfig {
    baseURL: string;
    organisation: string;
    secureCookies: boolean;
    adminEmails: string[];
    onlyAdminCanCreate: boolean;
    smtpEnabled: boolean;
}

interface DatabaseConfig {
    url: string;
    namespace: string;
    database: string;
    username: string;
    password: string;
}

interface AuthConfig {
    oauthEnabled: boolean;
    magicLinkEnabled: boolean;
}

interface OAuthConfig {
    clientId: string;
    clientSecret: string;
    authUrl: string;
    tokenUrl: string;
    userInfoUrl: string;
    logoutUrl: string;
    scopes: string[];
    allowedDomain: string;
    cookieSecret: string;
    autoLogin: boolean;
}

interface ServerConfig {
    port: number;
}

interface LoggerConfig {
    level: string;
    format: string;
}

interface MailConfig {
    host: string;
    port: number;
    username: string;
    password: string;
    tls: boolean;
    startTLS: boolean;
    timeout: string;
    from: string;
    fromName: string;
    subjectPrefix: string;
    templateDir: string;
    defaultLocale: string;
}

interface ChecksumConfig {
    maxBytes: number;
    timeoutMs: number;
    maxRedirects: number;
    allowedContentTypes: string[];
}

interface Config {
    app: AppConfig;
    database: DatabaseConfig;
    auth: AuthConfig;
    oauth: OAuthConfig;
    server: ServerConfig;
    logger: LoggerConfig;
    mail: MailConfig;
    checksum: ChecksumConfig;
}

function mustGetEnv(key: string): string {
    const value = process.env[key]?.trim();
    if (!value) {
        throw new Error(`Missing required environment variable: ${key}`);
    }
    return value;
}

function getEnv(key: string, defaultValue: string): string {
    return process.env[key]?.trim() || defaultValue;
}

function getEnvBool(key: string, defaultValue: boolean): boolean {
    const value = process.env[key]?.trim().toLowerCase();
    if (!value) return defaultValue;
    return value === "true" || value === "1";
}

function getEnvInt(key: string, defaultValue: number): number {
    const value = process.env[key]?.trim();
    if (!value) return defaultValue;
    const parsed = parseInt(value, 10);
    return isNaN(parsed) ? defaultValue : parsed;
}

function loadConfig(): Config {
    // App Config
    const baseURL = mustGetEnv("BASE_URL");
    const app: AppConfig = {
        baseURL,
        organisation: mustGetEnv("ORGANISATION"),
        secureCookies: baseURL.toLowerCase().startsWith("https://"),
        adminEmails: getEnv("ADMIN_EMAILS", "")
            .split(",")
            .map(e => e.trim().toLowerCase())
            .filter(e => e),
        onlyAdminCanCreate: getEnvBool("ONLY_ADMIN_CAN_CREATE", false),
        smtpEnabled: false // Set later based on mail config
    };

    // Database Config
    const database: DatabaseConfig = {
        url: getEnv("DB_URL", "ws://localhost:8000/rpc"),
        namespace: getEnv("DB_NAMESPACE", "lyxal"),
        database: getEnv("DB_DATABASE", "acknowledgments"),
        username: getEnv("DB_USERNAME", "root"),
        password: getEnv("DB_PASSWORD", "root")
    };

    // OAuth Config
    const oauthClientId = getEnv("OAUTH_CLIENT_ID", "");
    const oauthClientSecret = getEnv("OAUTH_CLIENT_SECRET", "");
    const oauthConfigured = !!(oauthClientId && oauthClientSecret);

    const oauth: OAuthConfig = {
        clientId: oauthClientId,
        clientSecret: oauthClientSecret,
        authUrl: "",
        tokenUrl: "",
        userInfoUrl: "",
        logoutUrl: "",
        scopes: [],
        allowedDomain: getEnv("OAUTH_ALLOWED_DOMAIN", ""),
        cookieSecret: getEnv("OAUTH_COOKIE_SECRET", ""),
        autoLogin: getEnvBool("OAUTH_AUTO_LOGIN", false)
    };

    // Configure OAuth URLs based on provider
    const authOAuthEnabled = getEnv("AUTH_OAUTH_ENABLED", "")
        ? getEnvBool("AUTH_OAUTH_ENABLED", false)
        : oauthConfigured;

    if (authOAuthEnabled) {
        const provider = getEnv("OAUTH_PROVIDER", "").toLowerCase();
        switch (provider) {
            case "google":
                oauth.authUrl = "https://accounts.google.com/o/oauth2/auth";
                oauth.tokenUrl = "https://oauth2.googleapis.com/token";
                oauth.userInfoUrl = "https://openidconnect.googleapis.com/v1/userinfo";
                oauth.logoutUrl = "https://accounts.google.com/Logout";
                oauth.scopes = ["openid", "email", "profile"];
                break;
            case "github":
                oauth.authUrl = "https://github.com/login/oauth/authorize";
                oauth.tokenUrl = "https://github.com/login/oauth/access_token";
                oauth.userInfoUrl = "https://api.github.com/user";
                oauth.logoutUrl = "https://github.com/logout";
                oauth.scopes = ["user:email", "read:user"];
                break;
            case "gitlab":
                const gitlabUrl = getEnv("OAUTH_GITLAB_URL", "https://gitlab.com");
                oauth.authUrl = `${gitlabUrl}/oauth/authorize`;
                oauth.tokenUrl = `${gitlabUrl}/oauth/token`;
                oauth.userInfoUrl = `${gitlabUrl}/api/v4/user`;
                oauth.logoutUrl = `${gitlabUrl}/users/sign_out`;
                oauth.scopes = ["read_user", "profile"];
                break;
            default:
                // Custom provider
                oauth.authUrl = mustGetEnv("OAUTH_AUTH_URL");
                oauth.tokenUrl = mustGetEnv("OAUTH_TOKEN_URL");
                oauth.userInfoUrl = mustGetEnv("OAUTH_USERINFO_URL");
                oauth.logoutUrl = getEnv("OAUTH_LOGOUT_URL", "");
                oauth.scopes = getEnv("OAUTH_SCOPES", "openid,email,profile").split(",");
        }
    }

    // Mail Config
    const mailHost = getEnv("SMTP_HOST", "");
    const mail: MailConfig = {
        host: mailHost,
        port: getEnvInt("SMTP_PORT", 587),
        username: getEnv("SMTP_USER", ""),
        password: getEnv("SMTP_PASS", ""),
        tls: getEnvBool("SMTP_TLS", true),
        startTLS: getEnvBool("SMTP_STARTTLS", true),
        timeout: getEnv("SMTP_TIMEOUT", "10s"),
        from: getEnv("SMTP_FROM", ""),
        fromName: getEnv("SMTP_FROM_NAME", app.organisation),
        subjectPrefix: getEnv("SMTP_SUBJECT_PREFIX", ""),
        templateDir: getEnv("SMTP_TEMPLATE_DIR", "templates/emails"),
        defaultLocale: getEnv("SMTP_DEFAULT_LOCALE", "en")
    };

    app.smtpEnabled = !!mailHost;

    // Auth Config
    const auth: AuthConfig = {
        oauthEnabled: authOAuthEnabled,
        magicLinkEnabled: getEnvBool("AUTH_MAGICLINK_ENABLED", false) && app.smtpEnabled
    };

    // Validation: At least one auth method
    if (!auth.oauthEnabled && !auth.magicLinkEnabled) {
        throw new Error(
            "At least one authentication method must be enabled: set OAUTH_CLIENT_ID/CLIENT_SECRET for OAuth or SMTP_HOST for MagicLink"
        );
    }

    // Server Config
    const server: ServerConfig = {
        port: getEnvInt("PORT", 3000)
    };

    // Logger Config
    const logger: LoggerConfig = {
        level: getEnv("LOG_LEVEL", "info"),
        format: getEnv("LOG_FORMAT", "classic")
    };

    // Checksum Config
    const checksum: ChecksumConfig = {
        maxBytes: getEnvInt("CHECKSUM_MAX_BYTES", 10 * 1024 * 1024), // 10 MB
        timeoutMs: getEnvInt("CHECKSUM_TIMEOUT_MS", 5000),
        maxRedirects: getEnvInt("CHECKSUM_MAX_REDIRECTS", 3),
        allowedContentTypes: getEnv(
            "CHECKSUM_ALLOWED_TYPES",
            "application/pdf,image/*,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        ).split(",").map(t => t.trim()).filter(t => t)
    };

    return {
        app,
        database,
        auth,
        oauth,
        server,
        logger,
        mail,
        checksum
    };
}

// Load and validate config at module import
export const config = loadConfig();

// Log config summary at startup
console.log(`[CONFIG] Loaded configuration:`);
console.log(`  - Base URL: ${config.app.baseURL}`);
console.log(`  - Organisation: ${config.app.organisation}`);
console.log(`  - OAuth Enabled: ${config.auth.oauthEnabled}`);
console.log(`  - MagicLink Enabled: ${config.auth.magicLinkEnabled}`);
console.log(`  - SMTP Enabled: ${config.app.smtpEnabled}`);
console.log(`  - Server Port: ${config.server.port}`);
