import Handlebars from "handlebars";
import { logger } from "../pkg/logger";
import { i18n } from "../pkg/i18n";

export class EmailRenderer {
    private templates: Map<string, HandlebarsTemplateDelegate> = new Map();
    private layout?: HandlebarsTemplateDelegate;

    constructor() {
        // Register i18n helper
        Handlebars.registerHelper("t", function(key: string, options: any) {
            // Handle interpolation params (passed as hash in Handlebars)
            // e.g. {{t "key" param1=value1}}
            const params = options.hash || {};
            
            // In a real implementation, i18n.t would support interpolation
            // For now, we'll just return the translated string
            // TODO: Add interpolation support to i18n module if needed
            let text = i18n.t("en", key); // Default to EN for now, should pass locale
            
            // Simple interpolation replacement
            Object.keys(params).forEach(param => {
                text = text.replace(`{{${param}}}`, params[param]);
            });
            
            return text;
        });
    }

    async loadTemplates(templatesDir: string = "./templates") {
        try {
            // Load layout
            const layoutContent = await Bun.file(`${templatesDir}/base.hbs`).text();
            this.layout = Handlebars.compile(layoutContent);

            // Load templates
            const templates = ["magic_link", "signature_reminder"];
            for (const name of templates) {
                const content = await Bun.file(`${templatesDir}/${name}.hbs`).text();
                this.templates.set(name, Handlebars.compile(content));
            }
            logger.info("Email templates loaded");
        } catch (error) {
            logger.error("Failed to load email templates", error);
        }
    }

    render(templateName: string, data: any): string {
        try {
            const template = this.templates.get(templateName);
            if (!template) {
                throw new Error(`Template ${templateName} not found`);
            }

            // Render body
            const body = template(data);

            // Render layout with body
            if (this.layout) {
                return this.layout({ ...data, body });
            }

            return body;
        } catch (error) {
            logger.error(`Failed to render email template ${templateName}`, error);
            throw error;
        }
    }
}

export const emailRenderer = new EmailRenderer();

// Auto-load on import (async) - in real app, call this during startup
emailRenderer.loadTemplates();
