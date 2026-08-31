/**
 * 🏛️ LYXAL OS — Client SDK Fortement Typé pour le Module 08 : Teams
 */

import { HttpClient, httpClient } from '../client';
import {
  TeamResponse,
  CreateTeamRequest,
  UpdateTeamRequest,
  DeleteTeamResponse,
  TeamMemberResponse,
  AddTeamMemberRequest,
  UpdateTeamMemberRequest,
  RemoveTeamMemberResponse,
  LeaveTeamResponse,
} from './teams.types';

export class TeamsClient {
  private client: HttpClient;

  constructor(client: HttpClient = httpClient) {
    this.client = client;
  }

  /**
   * Liste les équipes auxquelles l'utilisateur appartient (GET /api/v1/teams)
   */
  public async listTeams(): Promise<TeamResponse[]> {
    return this.client.get<TeamResponse[]>('/teams');
  }

  /**
   * Récupère les détails d'une équipe (GET /api/v1/teams/{id})
   */
  public async getTeam(id: string): Promise<TeamResponse> {
    return this.client.get<TeamResponse>(`/teams/${encodeURIComponent(id)}`);
  }

  /**
   * Crée une nouvelle équipe (POST /api/v1/teams)
   */
  public async createTeam(request: CreateTeamRequest): Promise<TeamResponse> {
    return this.client.post<TeamResponse>('/teams', request);
  }

  /**
   * Met à jour une équipe (PATCH /api/v1/teams/{id})
   */
  public async updateTeam(id: string, request: UpdateTeamRequest): Promise<TeamResponse> {
    return this.client.patch<TeamResponse>(`/teams/${encodeURIComponent(id)}`, request);
  }

  /**
   * Supprime une équipe (DELETE /api/v1/teams/{id})
   */
  public async deleteTeam(id: string): Promise<DeleteTeamResponse> {
    return this.client.delete<DeleteTeamResponse>(`/teams/${encodeURIComponent(id)}`);
  }

  /**
   * Quitte une équipe (POST /api/v1/teams/{id}/leave)
   */
  public async leaveTeam(id: string): Promise<LeaveTeamResponse> {
    return this.client.post<LeaveTeamResponse>(`/teams/${encodeURIComponent(id)}/leave`);
  }

  /**
   * Récupère la liste des membres d'une équipe (GET /api/v1/teams/{id}/members)
   */
  public async getMembers(id: string): Promise<TeamMemberResponse[]> {
    return this.client.get<TeamMemberResponse[]>(`/teams/${encodeURIComponent(id)}/members`);
  }

  /**
   * Ajoute un membre dans une équipe (POST /api/v1/teams/{id}/members)
   */
  public async addMember(id: string, request: AddTeamMemberRequest): Promise<TeamMemberResponse> {
    return this.client.post<TeamMemberResponse>(`/teams/${encodeURIComponent(id)}/members`, request);
  }

  /**
   * Modifie le rôle d'un membre (PATCH /api/v1/teams/{id}/members/{user_id})
   */
  public async updateMember(id: string, userId: string, request: UpdateTeamMemberRequest): Promise<TeamMemberResponse> {
    return this.client.patch<TeamMemberResponse>(`/teams/${encodeURIComponent(id)}/members/${encodeURIComponent(userId)}`, request);
  }

  /**
   * Supprime un membre d'une équipe (DELETE /api/v1/teams/{id}/members/{user_id})
   */
  public async removeMember(id: string, userId: string): Promise<RemoveTeamMemberResponse> {
    return this.client.delete<RemoveTeamMemberResponse>(`/teams/${encodeURIComponent(id)}/members/${encodeURIComponent(userId)}`);
  }
}

export const teamsClient = new TeamsClient();
