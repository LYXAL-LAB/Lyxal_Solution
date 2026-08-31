/**
 * 🏛️ LYXAL OS — Client SDK Fortement Typé pour le Module 03 : Users & Settings
 */

import { HttpClient, httpClient } from '../client';
import {
  UserProfileResponse,
  UpdateUserProfileRequest,
  UpdateTimezoneRequest,
  UpdateTimezoneResponse,
  UploadAvatarResponse,
} from './users.types';

export class UsersClient {
  private client: HttpClient;

  constructor(client: HttpClient = httpClient) {
    this.client = client;
  }

  /**
   * Récupère le profil de l'utilisateur authentifié (GET /api/v1/users/me)
   */
  public async getProfile(): Promise<UserProfileResponse> {
    return this.client.get<UserProfileResponse>('/users/me');
  }

  /**
   * Met à jour le profil de l'utilisateur (PATCH /api/v1/users/me)
   */
  public async updateProfile(request: UpdateUserProfileRequest): Promise<UserProfileResponse> {
    return this.client.patch<UserProfileResponse>('/users/me', request);
  }

  /**
   * Met à jour le fuseau horaire IANA par défaut (PATCH /api/v1/settings)
   */
  public async updateTimezone(timeZone: string): Promise<UpdateTimezoneResponse> {
    const request: UpdateTimezoneRequest = { time_zone: timeZone };
    return this.client.patch<UpdateTimezoneResponse>('/settings', request);
  }

  /**
   * Envoie une image d'avatar binaire (POST /api/v1/users/me/avatar)
   */
  public async uploadAvatar(file: File): Promise<UploadAvatarResponse> {
    const formData = new FormData();
    formData.append('avatar', file);
    return this.client.post<UploadAvatarResponse>('/users/me/avatar', formData);
  }
}

export const usersClient = new UsersClient();
