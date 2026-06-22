use std::future::{ready, Ready};

use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error,
};
use futures::future::LocalBoxFuture;

pub struct PrivacyPassVerifier;

impl<S, B> Transform<S, ServiceRequest> for PrivacyPassVerifier
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type InitError = ();
    type Transform = PrivacyPassVerifierMiddleware<S>;
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ready(Ok(PrivacyPassVerifierMiddleware { service }))
    }
}

pub struct PrivacyPassVerifierMiddleware<S> {
    service: S,
}

impl<S, B> Service<ServiceRequest> for PrivacyPassVerifierMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        // Here we would implement the logic to check if the request has a valid Privacy Pass token
        // For example, checking the "Authorization" or custom "Privacy-Pass" header.
        
        // If a valid token is found, we might verify its signature with the `blind-rsa-signatures` crate.
        
        // For now, it passes everything through
        let fut = self.service.call(req);
        Box::pin(async move {
            let res = fut.await?;
            Ok(res)
        })
    }
}
