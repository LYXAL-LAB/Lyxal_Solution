export interface ServiceInfo {
    name: string;
    icon: string;
    type: string;
    referrer: string;
}

export class ServiceDetector {
    static detectFromReferrer(referrerParam: string): ServiceInfo | null {
        if (!referrerParam) {
            return null;
        }

        switch (referrerParam) {
            case "google-docs":
                return { name: "Google Docs", icon: "https://cdn.simpleicons.org/googledocs", type: "docs", referrer: referrerParam };
            case "google-sheets":
                return { name: "Google Sheets", icon: "https://cdn.simpleicons.org/googlesheets", type: "sheets", referrer: referrerParam };
            case "google-slides":
                return { name: "Google Slides", icon: "https://cdn.simpleicons.org/googleslides", type: "presentation", referrer: referrerParam };
            case "google-drive":
                return { name: "Google Drive", icon: "https://cdn.simpleicons.org/googledrive", type: "storage", referrer: referrerParam };
            case "google":
                return { name: "Google", icon: "https://cdn.simpleicons.org/google", type: "google", referrer: referrerParam };
            case "notion":
                return { name: "Notion", icon: "https://cdn.simpleicons.org/notion", type: "notes", referrer: referrerParam };
            case "confluence":
                return { name: "Confluence", icon: "https://cdn.simpleicons.org/confluence", type: "wiki", referrer: referrerParam };
            case "microsoft":
                return { name: "Microsoft Office", icon: "https://cdn.simpleicons.org/microsoft", type: "office", referrer: referrerParam };
            case "github":
                return { name: "GitHub", icon: "https://cdn.simpleicons.org/github", type: "code", referrer: referrerParam };
            case "gitlab":
                return { name: "GitLab", icon: "https://cdn.simpleicons.org/gitlab", type: "code", referrer: referrerParam };
            case "outline":
                return { name: "Outline", icon: "https://cdn.simpleicons.org/outline", type: "wiki", referrer: referrerParam };
            case "slack":
                return { name: "Slack", icon: "https://cdn.simpleicons.org/slack", type: "chat", referrer: referrerParam };
            case "discord":
                return { name: "Discord", icon: "https://cdn.simpleicons.org/discord", type: "chat", referrer: referrerParam };
            case "trello":
                return { name: "Trello", icon: "https://cdn.simpleicons.org/trello", type: "boards", referrer: referrerParam };
            case "asana":
                return { name: "Asana", icon: "https://cdn.simpleicons.org/asana", type: "tasks", referrer: referrerParam };
            case "monday":
                return { name: "Monday.com", icon: "https://cdn.simpleicons.org/monday", type: "project", referrer: referrerParam };
            case "figma":
                return { name: "Figma", icon: "https://cdn.simpleicons.org/figma", type: "design", referrer: referrerParam };
            case "miro":
                return { name: "Miro", icon: "https://cdn.simpleicons.org/miro", type: "whiteboard", referrer: referrerParam };
            case "dropbox":
                return { name: "Dropbox", icon: "https://cdn.simpleicons.org/dropbox", type: "storage", referrer: referrerParam };

            default:
                return { name: referrerParam, icon: "https://cdn.simpleicons.org/link", type: "custom", referrer: referrerParam };
        }
    }
}
