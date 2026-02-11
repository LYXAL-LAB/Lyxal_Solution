interface Guard {
    type: 'auth' | 'role' | 'subscription' | 'feature';
    condition?: Record<string, any>;
}
interface GuardsEditorProps {
    guards: Guard[];
    onChange: (guards: Guard[]) => void;
    className?: string;
}
export declare const GuardsEditor: ({ guards, onChange, className }: GuardsEditorProps) => import("react/jsx-runtime").JSX.Element;
export {};
