import { StudioRoute } from '@/lib/studio/types/route';
interface RoutesTableProps {
    routes: StudioRoute[];
    loading: boolean;
    selectedRoutes: string[];
    onSelectionChange: (selected: string[]) => void;
    onRouteUpdate: () => void;
}
export declare const RoutesTable: ({ routes, loading, selectedRoutes, onSelectionChange, onRouteUpdate }: RoutesTableProps) => import("react/jsx-runtime").JSX.Element;
export {};
