use leptos::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct MessageContent {
    pub text: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Message {
    pub id: Option<String>,
    pub role: String,
    pub content: Vec<MessageContent>,
    pub created: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Session {
    pub id: String,
    pub title: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Template {
    pub name: String,
    pub description: String,
    pub default_content: String,
    pub user_content: Option<String>,
    pub is_customized: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PromptsListResponse {
    pub prompts: Vec<Template>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PromptContentResponse {
    pub name: String,
    pub content: String,
    pub default_content: String,
    pub is_customized: bool,
}

fn get_secret_key() -> String {
    "test".to_string()
}

// ============================================================================
// Provider / Model types
// ============================================================================

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ProviderMetadata {
    pub display_name: String,
    #[serde(default)]
    pub description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ProviderDetails {
    pub name: String,
    pub metadata: ProviderMetadata,
    #[serde(default)]
    pub is_configured: bool,
    #[serde(default)]
    pub provider_type: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ConfigValue {
    pub value: String,
}

#[server]
pub async fn list_providers() -> Result<Vec<ProviderDetails>, ServerFnError> {
    let client = reqwest::Client::new();
    let res = client.get("http://localhost:3000/config/providers")
        .header("X-Secret-Key", get_secret_key())
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;

    let providers: Vec<ProviderDetails> = res.json()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;

    Ok(providers)
}

#[server]
pub async fn get_provider_models(provider_name: String) -> Result<Vec<String>, ServerFnError> {
    let client = reqwest::Client::new();
    let res = client.get(format!("http://localhost:3000/config/providers/{}/models", provider_name))
        .header("X-Secret-Key", get_secret_key())
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;

    let models: Vec<String> = res.json()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;

    Ok(models)
}

#[server]
pub async fn read_config(key: String) -> Result<Option<String>, ServerFnError> {
    let client = reqwest::Client::new();
    let res = client.get(format!("http://localhost:3000/config/read?key={}", key))
        .header("X-Secret-Key", get_secret_key())
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;

    if res.status().is_success() {
        let val: String = res.text()
            .await
            .map_err(|e| ServerFnError::new(e.to_string()))?;
        if val.is_empty() { Ok(None) } else { Ok(Some(val.trim_matches('"').to_string())) }
    } else {
        Ok(None)
    }
}

#[server]
pub async fn write_config(key: String, value: String) -> Result<(), ServerFnError> {
    let client = reqwest::Client::new();
    let body = serde_json::json!({ "value": value });
    client.post("http://localhost:3000/config/write")
        .header("X-Secret-Key", get_secret_key())
        .json(&body)
        .query(&[("key", key)])
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
    Ok(())
}

#[server]
pub async fn configure_provider(provider_name: String, api_key: String) -> Result<(), ServerFnError> {
    let client = reqwest::Client::new();
    let body = serde_json::json!({ "api_key": api_key });
    client.post(format!("http://localhost:3000/config/providers/{}/configure", provider_name))
        .header("X-Secret-Key", get_secret_key())
        .json(&body)
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
    Ok(())
}

#[server]
pub async fn set_provider_and_model(provider: String, model: String) -> Result<(), ServerFnError> {
    let client = reqwest::Client::new();
    let body = serde_json::json!({
        "provider": provider,
        "model": model
    });
    client.post("http://localhost:3000/config/provider")
        .header("X-Secret-Key", get_secret_key())
        .json(&body)
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
    Ok(())
}

#[server]
pub async fn list_sessions() -> Result<Vec<Session>, ServerFnError> {
    let client = reqwest::Client::new();
    let res = client.get("http://localhost:3000/sessions")
        .header("X-Secret-Key", get_secret_key())
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
    
    let sessions: Vec<Session> = res.json()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
        
    Ok(sessions)
}

#[server]
pub async fn get_session_messages(id: String) -> Result<Vec<Message>, ServerFnError> {
    let client = reqwest::Client::new();
    let res = client.get(format!("http://localhost:3000/sessions/{}/messages", id))
        .header("X-Secret-Key", get_secret_key())
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
    
    let messages: Vec<Message> = res.json()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
        
    Ok(messages)
}

#[server]
pub async fn get_prompts() -> Result<Vec<Template>, ServerFnError> {
    let client = reqwest::Client::new();
    let res = client.get("http://localhost:3000/config/prompts")
        .header("X-Secret-Key", get_secret_key())
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
    
    let wrapper: PromptsListResponse = res.json()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
        
    Ok(wrapper.prompts)
}

#[server]
pub async fn get_prompt(name: String) -> Result<PromptContentResponse, ServerFnError> {
    let client = reqwest::Client::new();
    let res = client.get(format!("http://localhost:3000/config/prompts/{}", name))
        .header("X-Secret-Key", get_secret_key())
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
    
    let prompt: PromptContentResponse = res.json()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
        
    Ok(prompt)
}

#[server]
pub async fn save_prompt(name: String, content: String) -> Result<(), ServerFnError> {
    let client = reqwest::Client::new();
    let body = serde_json::json!({ "content": content });
    
    client.put(format!("http://localhost:3000/config/prompts/{}", name))
        .header("X-Secret-Key", get_secret_key())
        .json(&body)
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
        
    Ok(())
}

#[server]
pub async fn reset_prompt(name: String) -> Result<(), ServerFnError> {
    let client = reqwest::Client::new();
    client.delete(format!("http://localhost:3000/config/prompts/{}", name))
        .header("X-Secret-Key", get_secret_key())
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
        
    Ok(())
}

#[server]
pub async fn create_session() -> Result<Session, ServerFnError> {
    let client = reqwest::Client::new();
    let res = client.post("http://localhost:3000/sessions")
        .header("X-Secret-Key", get_secret_key())
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
    
    let session: Session = res.json()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
        
    Ok(session)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SendMessageRequest {
    pub content: String,
}

#[server]
pub async fn send_message(session_id: String, content: String) -> Result<Vec<Message>, ServerFnError> {
    let client = reqwest::Client::new();
    let body = serde_json::json!({
        "content": content
    });
    
    let res = client.post(format!("http://localhost:3000/sessions/{}/messages", session_id))
        .header("X-Secret-Key", get_secret_key())
        .json(&body)
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
    
    let messages: Vec<Message> = res.json()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
        
    Ok(messages)
}

#[server]
pub async fn delete_session(id: String) -> Result<(), ServerFnError> {
    let client = reqwest::Client::new();
    client.delete(format!("http://localhost:3000/sessions/{}", id))
        .header("X-Secret-Key", get_secret_key())
        .send()
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))?;
        
    Ok(())
}
