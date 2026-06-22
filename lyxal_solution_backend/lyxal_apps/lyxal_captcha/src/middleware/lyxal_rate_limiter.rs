use actix_governor::{Governor, GovernorConfigBuilder, PeerIpKeyExtractor};

pub fn get_rate_limiter() -> Governor<PeerIpKeyExtractor, actix_governor::governor::middleware::StateInformationMiddleware> {
    let config = GovernorConfigBuilder::default()
        .per_second(10)
        .burst_size(10)
        .use_headers()
        .finish()
        .unwrap();

    Governor::new(&config)
}
