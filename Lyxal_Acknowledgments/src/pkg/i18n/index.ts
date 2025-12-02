/**
 * I18n (Internationalization) module
 * Supports translation for multiple languages: en, fr, it, de, es
 */

export const LANG_COOKIE_NAME = "lang";
export const DEFAULT_LANG = "en";
export const SUPPORTED_LANGS = ["en", "fr", "it", "de", "es"];

export class I18n {
    private translations: Map<string, Record<string, string>> = new Map();

    constructor() {
        // Initialize with empty translations
        SUPPORTED_LANGS.forEach(lang => {
            this.translations.set(lang, {});
        });
    }

    /**
     * Load translations from JSON files
     */
    async loadTranslations(localesDir: string): Promise<void> {
        for (const lang of SUPPORTED_LANGS) {
            try {
                const filePath = `${localesDir}/${lang}.json`;
                const file = Bun.file(filePath);
                const data = await file.json();
                this.translations.set(lang, data);
            } catch (error) {
                console.warn(`Failed to load ${lang} translations, using empty object`);
                this.translations.set(lang, {});
            }
        }
    }

    /**
     * Load translations from objects (for testing or manual setup)
     */
    loadTranslationsFromObjects(translationsMap: Record<string, Record<string, string>>): void {
        Object.entries(translationsMap).forEach(([lang, translations]) => {
            this.translations.set(lang, translations);
        });
    }

    /**
     * Translate a key for a given language
     */
    t(lang: string, key: string): string {
        // Normalize language
        lang = normalizeLang(lang);

        // Try requested language
        const translations = this.translations.get(lang);
        if (translations && translations[key]) {
            return translations[key];
        }

        // Fallback to English
        if (lang !== "en") {
            const enTranslations = this.translations.get("en");
            if (enTranslations && enTranslations[key]) {
                return enTranslations[key];
            }
        }

        // Return key if translation not found
        return key;
    }

    /**
     * Get all translations for a language
     */
    getTranslations(lang: string): Record<string, string> {
        lang = normalizeLang(lang);
        return this.translations.get(lang) || this.translations.get(DEFAULT_LANG) || {};
    }
}

/**
 * Get language from Accept-Language header (simplified for Elysia)
 */
export function getLangFromHeader(acceptLanguage?: string): string {
    if (!acceptLanguage) return DEFAULT_LANG;

    // Parse Accept-Language header (simplified)
    // Format: "en-US,en;q=0.9,fr;q=0.8"
    const languages = acceptLanguage
        .split(",")
        .map(lang => {
            const parts = lang.trim().split(";");
            const code = parts[0];
            const q = parts[1] ? parseFloat(parts[1].split("=")[1]) : 1.0;
            return { code: normalizeLang(code), q };
        })
        .sort((a, b) => b.q - a.q);

    for (const { code } of languages) {
        if (isSupported(code)) {
            return code;
        }
    }

    return DEFAULT_LANG;
}

/**
 * Normalize language code (en-US -> en, fr-FR -> fr)
 */
export function normalizeLang(lang: string): string {
    if (!lang) return DEFAULT_LANG;

    lang = lang.toLowerCase();
    const idx = lang.indexOf("-") !== -1 ? lang.indexOf("-") : lang.indexOf("_");
    if (idx > 0) {
        return lang.substring(0, idx);
    }
    return lang;
}

/**
 * Check if a language is supported
 */
export function isSupported(lang: string): boolean {
    lang = normalizeLang(lang);
    return SUPPORTED_LANGS.includes(lang);
}

// Singleton instance
export const i18n = new I18n();
