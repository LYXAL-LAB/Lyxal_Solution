/**
 * Action de navigation pure
 * 
 * Navigue vers une URL donnée via react-router-dom
 */
export interface NavigateParams {
  url: string;
}

export interface NavigateContext {
  navigate: (url: string) => void;
}

export const navigateAction = (
  params: NavigateParams,
  context: NavigateContext
): void => {
  const { navigate } = context;
  const { url } = params;

  if (!url) {
    console.warn('[navigateAction] url is required');
    return;
  }

  navigate(url);
};

