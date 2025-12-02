import { Elysia } from "elysia";
import { config } from "../config";

export const userController = new Elysia({ prefix: "/api/v1/users" })
    .get("/me", ({ request, set }) => {
        // In a real app, user is injected by auth middleware
        // Here we mock it or retrieve from header/token if we had the full auth stack ported
        // For this standalone version, we'll assume the user info is passed in headers or context
        // But since we don't have the full auth middleware from Go yet, we'll implement a basic version

        // Note: In the Go code, shared.GetUserFromContext retrieves user from context
        // We need to replicate how user gets there. 
        // For now, we'll return a placeholder or 401 if not authenticated

        // TODO: Implement proper auth middleware extraction
        // For now, let's assume we might have a user object in the request if we had auth

        const user = {
            id: "user_123",
            email: "admin@example.com", // Mock for dev
            name: "Admin User"
        };

        const adminEmails = config.admin.emails;
        const isAdmin = adminEmails.includes(user.email);

        return {
            id: user.id,
            email: user.email,
            name: user.name,
            isAdmin: isAdmin
        };
    });
