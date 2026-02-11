use lyxal_network_ping as ping;

#[derive(lyxal_network_swarm::NetworkBehaviour)]
#[behaviour(out_event = FooEvent, prelude = "lyxal_network_swarm::derive_prelude")]
struct Foo {
    ping: ping::Behaviour,
}

struct FooEvent;

impl From<ping::Event> for FooEvent {
    fn from(_: ping::Event) -> Self {
        unimplemented!()
    }
}

fn main() {

}
