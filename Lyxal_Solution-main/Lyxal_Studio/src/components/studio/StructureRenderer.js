import { parseComponent } from '@/lib/studio/parser';
import { ContextManager } from '@/lib/studio/context/ContextManager';
import { useStudioState } from '@/lib/studio/store/useStudioState';
/**
 * Renderer récursif pour les structures définies en DB
 *
 * Rend une structure JSON définie dans SurrealDB en composant React.
 * Utilisé pour rendre des composants imbriqués ou des structures complexes.
 *
 * @example
 * ```tsx
 * <StructureRenderer
 *   structure={{
 *     type: "div",
 *     children: [
 *       { type: "text", content: "{{props.label}}" }
 *     ]
 *   }}
 *   componentProps={{ label: "Hello" }}
 * />
 * ```
 */
export const StructureRenderer = ({ structure, componentProps = {}, context = {}, }) => {
    // Récupérer le state global
    const globalState = useStudioState((state) => state.state);
    // Fusionner tous les contextes
    const mergedContext = ContextManager.merge({
        ...context,
        state: globalState,
        props: componentProps,
    }, componentProps);
    // Parser et rendre la structure
    const element = parseComponent(structure, componentProps, mergedContext);
    return element;
};
