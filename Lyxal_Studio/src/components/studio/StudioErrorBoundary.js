import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { Component } from 'react';
/**
 * Error Boundary pour capturer les erreurs dans le Studio Runtime
 */
export class StudioErrorBoundary extends Component {
    constructor(props) {
        super(props);
        this.state = { hasError: false };
    }
    static getDerivedStateFromError(error) {
        return { hasError: true, error };
    }
    componentDidCatch(error, errorInfo) {
        console.error('[StudioErrorBoundary] Error caught:', error);
        console.error('[StudioErrorBoundary] Error info:', errorInfo);
    }
    render() {
        if (this.state.hasError) {
            return this.props.fallback || (_jsxs("div", { className: "studio-error-boundary", style: { padding: '20px', border: '2px solid red' }, children: [_jsx("h3", { children: "Erreur dans le Studio Runtime" }), _jsx("p", { children: this.state.error?.message }), _jsxs("details", { children: [_jsx("summary", { children: "Stack trace" }), _jsx("pre", { children: this.state.error?.stack })] })] }));
        }
        return this.props.children;
    }
}
