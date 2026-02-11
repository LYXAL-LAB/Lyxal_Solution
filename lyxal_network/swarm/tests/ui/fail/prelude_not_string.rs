use lyxal_network_ping as ping;

#[derive(lyxal_network_swarm::NetworkBehaviour)]
#[behaviour(prelude = lyxal_network_swarm::derive_prelude)]
struct Foo {
    ping: ping::Behaviour,
}

fn main() {

}
