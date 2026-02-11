import { apiClient } from './config';

/**
 * Récupère toutes les phrases personnalisées
 */
export const getAllPhrases = async (): Promise<Record<string, Record<string, string>>> => {
  return apiClient<Record<string, Record<string, string>>>('/phrases');
};

/**
 * Récupère les phrases personnalisées pour une langue spécifique
 */
export const getPhrasesByLanguage = async (language: string): Promise<Record<string, string>> => {
  return apiClient<Record<string, string>>(`/phrases/${language}`);
};

/**
 * Met à jour les phrases personnalisées pour une langue spécifique
 */
export const updatePhrasesByLanguage = async (
  language: string,
  phrases: Record<string, string>
): Promise<Record<string, string>> => {
  return apiClient<Record<string, string>>(`/phrases/${language}`, {
    method: 'PUT',
    body: JSON.stringify(phrases),
  });
};

/**
 * Supprime une phrase personnalisée
 */
export const deletePhrase = async (
  language: string,
  key: string
): Promise<void> => {
  return apiClient<void>(`/phrases/${language}/${key}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère toutes les phrases personnalisées
 */
export const getAllCustomPhrases = async (): Promise<Record<string, Record<string, string>>> => {
  return apiClient<Record<string, Record<string, string>>>('/custom-phrases');
};

/**
 * Récupère les phrases personnalisées pour une langue spécifique
 */
export const getCustomPhrasesByLanguage = async (language: string): Promise<Record<string, string>> => {
  return apiClient<Record<string, string>>(`/custom-phrases/${language}`);
};

/**
 * Met à jour les phrases personnalisées pour une langue spécifique
 */
export const updateCustomPhrasesByLanguage = async (
  language: string,
  phrases: Record<string, string>
): Promise<Record<string, string>> => {
  return apiClient<Record<string, string>>(`/custom-phrases/${language}`, {
    method: 'PUT',
    body: JSON.stringify(phrases),
  });
};

/**
 * Supprime une phrase personnalisée
 */
export const deleteCustomPhrase = async (
  language: string,
  key: string
): Promise<void> => {
  return apiClient<void>(`/custom-phrases/${language}/${key}`, {
    method: 'DELETE',
  });
}; 