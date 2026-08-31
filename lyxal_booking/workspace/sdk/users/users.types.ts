/**
 * 🏛️ LYXAL OS — Types TypeScript pour le Module 03 : Users & Settings
 * Dérivés des contrats Rust DTOs (engine/src/contracts/users.rs & settings.rs)
 */

export interface UserProfileResponse {
  id: string;
  user_id: string;
  name: string;
  email: string;
  booking_email?: string | null;
  time_zone: string;
  avatar_path?: string | null;
  role: string;
  enabled: boolean;
}

export interface UpdateUserProfileRequest {
  name?: string | null;
  booking_email?: string | null;
}

export interface UpdateTimezoneRequest {
  time_zone: string;
}

export interface UpdateTimezoneResponse {
  user_id: string;
  time_zone: string;
  updated: boolean;
}

export interface UploadAvatarResponse {
  user_id: string;
  avatar_url: string;
  uploaded: boolean;
}
