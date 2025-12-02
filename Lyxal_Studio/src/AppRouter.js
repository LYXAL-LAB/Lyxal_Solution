import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import App from './App';
import { RoutesDashboard } from './pages/admin/routes';
import { NewRoute } from './pages/admin/routes/new';
import { RouteDetails } from './pages/admin/routes/[id]';
const AppRouter = () => {
    return (_jsx(BrowserRouter, { children: _jsxs(Routes, { children: [_jsx(Route, { path: "/", element: _jsx(App, {}) }), _jsx(Route, { path: "/app", element: _jsx(App, {}) }), _jsx(Route, { path: "/admin/routes", element: _jsx(RoutesDashboard, {}) }), _jsx(Route, { path: "/admin/routes/new", element: _jsx(NewRoute, {}) }), _jsx(Route, { path: "/admin/routes/:id", element: _jsx(RouteDetails, {}) })] }) }));
};
export default AppRouter;
