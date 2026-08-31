use futures::Stream;
use parking_lot::Mutex;
use smol::lock::{Semaphore, SemaphoreGuardArc};
use std::{
    future::Future,
    pin::Pin,
    sync::Arc,
    task::{Context, Poll},
    time::{Duration, Instant},
};

use crate::LanguageModelCompletionError;

#[derive(Clone)]
pub struct RateLimiter {
    semaphore: Arc<Semaphore>,
    state: Option<Arc<Mutex<RateLimiterState>>>,
}

struct RateLimiterState {
    last_request_at: Option<Instant>,
    min_delay: Duration,
}

pub struct RateLimitGuard<T> {
    inner: T,
    _guard: SemaphoreGuardArc,
}

impl<T> Stream for RateLimitGuard<T>
where
    T: Stream,
{
    type Item = T::Item;

    fn poll_next(self: Pin<&mut Self>, cx: &mut Context) -> Poll<Option<Self::Item>> {
        unsafe { Pin::map_unchecked_mut(self, |this| &mut this.inner).poll_next(cx) }
    }
}

impl RateLimiter {
    pub fn new(limit: usize) -> Self {
        Self {
            semaphore: Arc::new(Semaphore::new(limit)),
            state: None,
        }
    }

    pub fn new_with_throttle(limit: usize, min_delay: Duration) -> Self {
        Self {
            semaphore: Arc::new(Semaphore::new(limit)),
            state: Some(Arc::new(Mutex::new(RateLimiterState {
                last_request_at: None,
                min_delay,
            }))),
        }
    }

    async fn wait_for_throttle(&self) {
        if let Some(state) = &self.state {
            let delay = {
                let state = state.lock();
                if let Some(last_request_at) = state.last_request_at {
                    let elapsed = last_request_at.elapsed();
                    if elapsed < state.min_delay {
                        Some(state.min_delay - elapsed)
                    } else {
                        None
                    }
                } else {
                    None
                }
            };

            if let Some(delay) = delay {
                smol::Timer::after(delay).await;
            }

            state.lock().last_request_at = Some(Instant::now());
        }
    }

    pub fn run<'a, Fut, T>(
        &self,
        future: Fut,
    ) -> impl 'a + Future<Output = Result<T, LanguageModelCompletionError>>
    where
        Fut: 'a + Future<Output = Result<T, LanguageModelCompletionError>>,
    {
        let this = self.clone();
        let guard = self.semaphore.acquire_arc();
        async move {
            let guard = guard.await;
            this.wait_for_throttle().await;
            let result = future.await?;
            drop(guard);
            Ok(result)
        }
    }

    pub fn stream<'a, Fut, T>(
        &self,
        future: Fut,
    ) -> impl 'a
    + Future<
        Output = Result<impl Stream<Item = T::Item> + use<Fut, T>, LanguageModelCompletionError>,
    >
    where
        Fut: 'a + Future<Output = Result<T, LanguageModelCompletionError>>,
        T: Stream,
    {
        let this = self.clone();
        let guard = self.semaphore.acquire_arc();
        async move {
            let guard = guard.await;
            this.wait_for_throttle().await;
            let inner = future.await?;
            Ok(RateLimitGuard {
                inner,
                _guard: guard,
            })
        }
    }
}
