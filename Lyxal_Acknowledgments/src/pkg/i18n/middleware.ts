import { Elysia } from "elysia";
import { i18n, getLangFromHeader, LANG_COOKIE_NAME } from "./index";

export const i18nPlugin = new Elysia({ name: "i18n" })
    .derive(({ request, cookie }) => {
        // 1. Check cookie
        let lang = cookie[LANG_COOKIE_NAME]?.value;

        // 2. Check Accept-Language header if no cookie
        if (!lang) {
            const acceptLang = request.headers.get("accept-language");
            if (acceptLang) {
                lang = getLangFromHeader(acceptLang);
            }
        }

        // 3. Default fallback handled by i18n module
        if (!lang) {
            lang = "en";
        }

        return {
            lang,
            t: (key: string) => i18n.t(lang!, key),
            translations: i18n.getTranslations(lang!)
        };
    });
