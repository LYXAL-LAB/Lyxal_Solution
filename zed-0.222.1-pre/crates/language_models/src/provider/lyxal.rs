use anyhow::{Result, anyhow};
use futures::{FutureExt, StreamExt, io::BufReader, AsyncBufReadExt, future::BoxFuture};
use gpui::{AnyView, App, AsyncApp, Entity, Task, Window};
use http_client::{AsyncBody, HttpClient, Method, Request as HttpRequest};
use language_model::{
    AuthenticateError, IconOrSvg, LanguageModel, LanguageModelCompletionError,
    LanguageModelCompletionEvent, LanguageModelId, LanguageModelName,
    LanguageModelProvider, LanguageModelProviderId, LanguageModelProviderName,
    LanguageModelProviderState, LanguageModelRequest, RateLimiter, Role,
    LanguageModelToolChoice,
};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use ui::prelude::*;

const PROVIDER_ID: &str = "lyxal";
const PROVIDER_NAME: &str = "Lyxal Agent";

#[derive(Default, Clone, Debug, PartialEq, Deserialize, Serialize)]
pub struct LyxalSettings {
    pub api_url: String,
}

pub struct LyxalLanguageModelProvider {
    http_client: Arc<dyn HttpClient>,
    state: Entity<State>,
}

pub struct State {
    authenticated: bool,
}

impl State {
    fn authenticate(&mut self) -> Task<Result<(), AuthenticateError>> {
        self.authenticated = true;
        Task::ready(Ok(()))
    }
}

impl LyxalLanguageModelProvider {
    pub fn new(http_client: Arc<dyn HttpClient>, cx: &mut App) -> Self {
        let state = cx.new(|_| State {
            authenticated: true, // Always authenticated for local agent
        });

        Self { http_client, state }
    }

    fn api_url() -> String {
        // TODO: Load from settings
        "http://localhost:10001/reply".to_string()
    }
}

impl LanguageModelProviderState for LyxalLanguageModelProvider {
    type ObservableEntity = State;

    fn observable_entity(&self) -> Option<Entity<Self::ObservableEntity>> {
        Some(self.state.clone())
    }
}

impl LanguageModelProvider for LyxalLanguageModelProvider {
    fn id(&self) -> LanguageModelProviderId {
        LanguageModelProviderId(PROVIDER_ID.into())
    }

    fn name(&self) -> LanguageModelProviderName {
        LanguageModelProviderName(PROVIDER_NAME.into())
    }

    fn icon(&self) -> IconOrSvg {
        IconOrSvg::Icon(IconName::AiAnthropic) // Placeholder icon
    }

    fn default_model(&self, _cx: &App) -> Option<Arc<dyn LanguageModel>> {
        Some(Arc::new(LyxalLanguageModel {
            id: LanguageModelId("lyxal-default".into()),
            http_client: self.http_client.clone(),
            request_limiter: RateLimiter::new(4),
        }))
    }

    fn default_fast_model(&self, _cx: &App) -> Option<Arc<dyn LanguageModel>> {
        self.default_model(_cx)
    }

    fn provided_models(&self, _cx: &App) -> Vec<Arc<dyn LanguageModel>> {
        vec![self.default_model(_cx).unwrap()]
    }

    fn is_authenticated(&self, cx: &App) -> bool {
        self.state.read(cx).authenticated
    }

    fn authenticate(&self, cx: &mut App) -> Task<Result<(), AuthenticateError>> {
        self.state.update(cx, |state, _| state.authenticate())
    }

    fn configuration_view(
        &self,
        _target_agent: language_model::ConfigurationViewTargetAgent,
        _window: &mut Window,
        cx: &mut App,
    ) -> AnyView {
        cx.new(|_| gpui::Empty).into()
    }

    fn reset_credentials(&self, _cx: &mut App) -> Task<Result<()>> {
        Task::ready(Ok(()))
    }
}

pub struct LyxalLanguageModel {
    id: LanguageModelId,
    http_client: Arc<dyn HttpClient>,
    request_limiter: RateLimiter,
}

impl LanguageModel for LyxalLanguageModel {
    fn id(&self) -> LanguageModelId {
        self.id.clone()
    }

    fn name(&self) -> LanguageModelName {
        LanguageModelName("Lyxal Agent".into())
    }

    fn provider_id(&self) -> LanguageModelProviderId {
        LanguageModelProviderId(PROVIDER_ID.into())
    }

    fn provider_name(&self) -> LanguageModelProviderName {
        LanguageModelProviderName(PROVIDER_NAME.into())
    }

    fn telemetry_id(&self) -> String {
        "lyxal_agent".to_string()
    }

    fn max_token_count(&self) -> u64 {
        128_000 // Arbitrary high limit
    }

    fn count_tokens(
        &self,
        _request: LanguageModelRequest,
        _cx: &App,
    ) -> BoxFuture<'static, Result<u64>> {
        async { Ok(0) }.boxed()
    }

    fn supports_images(&self) -> bool {
        false
    }

    fn supports_tools(&self) -> bool {
        true // Lyxal Agent should support tools
    }

    fn supports_tool_choice(&self, _choice: LanguageModelToolChoice) -> bool {
        true
    }

    fn stream_completion(
        &self,
        request: LanguageModelRequest,
        _cx: &AsyncApp,
    ) -> BoxFuture<
        'static,
        Result<
            futures::stream::BoxStream<
                'static,
                Result<LanguageModelCompletionEvent, LanguageModelCompletionError>,
            >,
            LanguageModelCompletionError,
        >,
    > {
        let http_client = self.http_client.clone();
        let api_url = LyxalLanguageModelProvider::api_url();

        let future = self.request_limiter.stream(async move {
            let body = serde_json::to_string(&LyxalRequest::from(request))
                .map_err(|e| LanguageModelCompletionError::Other(anyhow!(e)))?;

            let request_builder = HttpRequest::builder()
                .method(Method::POST)
                .uri(api_url)
                .header("Content-Type", "application/json");

            let request = request_builder
                .body(AsyncBody::from(body))
                .map_err(|e| LanguageModelCompletionError::Other(anyhow!(e)))?;

            let response = http_client.send(request).await
                .map_err(|e| LanguageModelCompletionError::Other(anyhow!(e)))?;

            if !response.status().is_success() {
                return Err(LanguageModelCompletionError::Other(anyhow!("HTTP Error: {}", response.status())));
            }

            let reader = BufReader::new(response.into_body());
            Ok(reader
                .lines()
                .filter_map(|line| async move {
                    match line {
                        Ok(line) => {
                            let line = line.strip_prefix("data: ").or_else(|| line.strip_prefix("data:"))?;
                            if line == "[DONE]" {
                                return None;
                            }
                            match serde_json::from_str::<LyxalResponseEvent>(line) {
                                Ok(event) => {
                                    if let Some(content) = event.choices.first().and_then(|c| c.delta.content.clone()) {
                                         Some(Ok(LanguageModelCompletionEvent::Text(content)))
                                    } else {
                                        None
                                    }
                                }
                                Err(e) => Some(Err(LanguageModelCompletionError::Other(anyhow!(e)))),
                            }
                        }
                        Err(e) => Some(Err(LanguageModelCompletionError::Other(anyhow!(e)))),
                    }
                })
                .boxed())
        });

        async move { Ok(future.await?.boxed()) }.boxed()
    }
}

// Structs for Lyxal API

#[derive(Serialize)]
struct LyxalRequest {
    messages: Vec<LyxalMessage>,
    stream: bool,
}

#[derive(Serialize)]
struct LyxalMessage {
    role: String,
    content: String,
}

#[derive(Deserialize)]
struct LyxalResponseEvent {
    choices: Vec<LyxalChoice>,
}

#[derive(Deserialize)]
struct LyxalChoice {
    delta: LyxalDelta,
}

#[derive(Deserialize)]
struct LyxalDelta {
    content: Option<String>,
}

impl From<LanguageModelRequest> for LyxalRequest {
    fn from(req: LanguageModelRequest) -> Self {
        let messages = req.messages.into_iter().map(|m| {
            let content = m.content.into_iter().map(|c| match c {
                language_model::MessageContent::Text(t) => t,
                _ => "".to_string(), // Ignore other content for now
            }).collect::<Vec<_>>().join("\n");
            
            LyxalMessage {
                role: match m.role {
                    Role::User => "user".to_string(),
                    Role::Assistant => "assistant".to_string(),
                    Role::System => "system".to_string(),
                },
                content,
            }
        }).collect();

        LyxalRequest { 
            messages,
            stream: true,
        }
    }
}
