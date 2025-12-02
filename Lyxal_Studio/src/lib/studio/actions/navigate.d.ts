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
export declare const navigateAction: (params: NavigateParams, context: NavigateContext) => void;
