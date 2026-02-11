use either::Either;
use lyxal_network_swarm::dummy;

pub(crate) mod dial_back;
pub(crate) mod dial_request;

pub(crate) type Handler<R> =
    Either<Either<dial_back::Handler, dummy::ConnectionHandler>, dial_request::Handler<R>>;
