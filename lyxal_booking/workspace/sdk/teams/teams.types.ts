/**
 * 🏛️ LYXAL OS — Types TypeScript pour le Module 08 : Teams
 * Dérivés des contrats Rust DTOs (engine/src/contracts/teams.rs)
 */

export interface TeamResponse {
  id: string;
  name: string;
  slug: string;
  role: string;
  member_count: number;
}

export interface CreateTeamRequest {
  name: string;
  slug: string;
}

export interface UpdateTeamRequest {
  name?: string | null;
  slug?: string | null;
}

export interface DeleteTeamResponse {
  deleted: boolean;
}

export interface TeamMemberResponse {
  team_id: string;
  user_id: string;
  role: 'owner' | 'admin' | 'member';
}

export interface AddTeamMemberRequest {
  user_id: string;
  role: 'owner' | 'admin' | 'member';
}

export interface UpdateTeamMemberRequest {
  role: 'owner' | 'admin' | 'member';
}

export interface RemoveTeamMemberResponse {
  removed: boolean;
}

export interface LeaveTeamResponse {
  left: boolean;
}
