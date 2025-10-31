export class HttpClient {
    constructor(private baseUrl: string = '/api') {}
  
    private async getToken(): Promise<string | null> {
      return localStorage.getItem('access_token'); // ou Logto.getAccessToken()
    }
  
    private async buildHeaders(): Promise<HeadersInit> {
      const token = await this.getToken();
      return {
        Authorization: token ? `Bearer ${token}` : '',
        'Content-Type': 'application/json',
      };
    }
  
    async get<T = any>(url: string): Promise<T> {
      const res = await fetch(`${this.baseUrl}${url}`, {
        method: 'GET',
        headers: await this.buildHeaders(),
      });
      return this.handle(res);
    }
  
    async post<T = any>(url: string, body: any): Promise<T> {
      const res = await fetch(`${this.baseUrl}${url}`, {
        method: 'POST',
        headers: await this.buildHeaders(),
        body: JSON.stringify(body),
      });
      return this.handle(res);
    }
  
    async put<T = any>(url: string, body: any): Promise<T> {
      const res = await fetch(`${this.baseUrl}${url}`, {
        method: 'PUT',
        headers: await this.buildHeaders(),
        body: JSON.stringify(body),
      });
      return this.handle(res);
    }
  
    async delete<T = any>(url: string): Promise<T> {
      const res = await fetch(`${this.baseUrl}${url}`, {
        method: 'DELETE',
        headers: await this.buildHeaders(),
      });
      return this.handle(res);
    }
  
    private async handle(res: Response) {
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`);
      return res.status !== 204 ? res.json() : undefined;
    }
  }
  