/// <reference types="vite/client" />

// Déclaration pour les fichiers CSS importés avec ?raw
declare module '*.css?raw' {
  const content: string;
  export default content;
} 