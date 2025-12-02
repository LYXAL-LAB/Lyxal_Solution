export class AppError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "AppError";
    }
}

export const ErrSignatureNotFound = new AppError("signature not found");
export const ErrSignatureAlreadyExists = new AppError("signature already exists");
export const ErrInvalidUser = new AppError("invalid user");
export const ErrInvalidDocument = new AppError("invalid document ID");
export const ErrDatabaseConnection = new AppError("database connection error");
export const ErrUnauthorized = new AppError("unauthorized");
export const ErrDomainNotAllowed = new AppError("domain not allowed");
export const ErrDocumentModified = new AppError("document has been modified since creation");
export const ErrDocumentNotFound = new AppError("document not found");
