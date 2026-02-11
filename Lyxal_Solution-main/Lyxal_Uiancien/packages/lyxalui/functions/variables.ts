// Types TypeScript
interface ColorVariables {
  "base-100": string;
  "base-200": string;
  "base-300": string;
  "base-content": string;
  primary: string;
  "primary-content": string;
  secondary: string;
  "secondary-content": string;
  accent: string;
  "accent-content": string;
  neutral: string;
  "neutral-content": string;
  info: string;
  "info-content": string;
  success: string;
  "success-content": string;
  warning: string;
  "warning-content": string;
  error: string;
  "error-content": string;
}

interface BorderRadiusVariables {
  selector: string;
  field: string;
  box: string;
}

interface TailwindVariables {
  colors: ColorVariables;
  borderRadius: BorderRadiusVariables;
}

// Définition des variables Tailwind pour LyxalUI
const variables: TailwindVariables = {
  colors: {
    "base-100": "var(--color-base-100)",
    "base-200": "var(--color-base-200)",
    "base-300": "var(--color-base-300)",
    "base-content": "var(--color-base-content)",
    primary: "var(--color-primary)",
    "primary-content": "var(--color-primary-content)",
    secondary: "var(--color-secondary)",
    "secondary-content": "var(--color-secondary-content)",
    accent: "var(--color-accent)",
    "accent-content": "var(--color-accent-content)",
    neutral: "var(--color-neutral)",
    "neutral-content": "var(--color-neutral-content)",
    info: "var(--color-info)",
    "info-content": "var(--color-info-content)",
    success: "var(--color-success)",
    "success-content": "var(--color-success-content)",
    warning: "var(--color-warning)",
    "warning-content": "var(--color-warning-content)",
    error: "var(--color-error)",
    "error-content": "var(--color-error-content)",
  },
  borderRadius: {
    selector: "var(--radius-selector)",
    field: "var(--radius-field)",
    box: "var(--radius-box)",
  },
};

export default variables;
