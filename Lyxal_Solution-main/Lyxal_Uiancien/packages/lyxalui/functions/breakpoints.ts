// Types TypeScript pour les breakpoints
interface Breakpoints {
  sm: string;
  md: string;
  lg: string;
  xl: string;
  "2xl": string;
}

// Définition des breakpoints responsive
const breakpoints: Breakpoints = {
  sm: "640px",
  md: "768px",
  lg: "1024px",
  xl: "1280px",
  "2xl": "1536px",
};

export default breakpoints;
