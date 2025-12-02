import { createRemoteJWKSet, jwtVerify, type JWTPayload } from "jose";
import { ServerConfig } from "../config.js";

export class AuthService {
  private jwks: ReturnType<typeof createRemoteJWKSet>;
  private config: ServerConfig;

  constructor(config: ServerConfig) {
    this.config = config;
    // Crée un set de clés distant avec cache automatique (géré par jose)
    this.jwks = createRemoteJWKSet(new URL(config.authJwksUri));
  }

  /**
   * Valide un token Bearer (JWT)
   * @param authHeader Header complet "Bearer <token>"
   * @returns Le payload du token si valide, sinon throw error
   */
  async validateToken(authHeader?: string): Promise<JWTPayload> {
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new Error("Missing or invalid Authorization header");
    }

    const token = authHeader.split(" ")[1];

    try {
      const { payload } = await jwtVerify(token, this.jwks, {
        issuer: this.config.authServer,
        audience: this.config.authAudience,
        algorithms: ["RS256", "ES256"], // Algorithmes standards supportés
      });

      return payload;
    } catch (err: any) {
      throw new Error(`Token validation failed: ${err.message}`);
    }
  }

  /**
   * Génère la configuration de découverte pour le client
   */
  getDiscoveryConfig() {
    return {
      resource: this.config.serverUrl,
      bearer_methods_supported: ["header"],
      authorization_servers: [this.config.authServer],
      scopes_supported: ["openid", "profile", "email", "offline_access"],
      audience: [this.config.authAudience],
    };
  }
}

