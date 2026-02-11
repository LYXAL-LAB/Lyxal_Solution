fn main() {
    lyxal_raft_macros::expand!(
        KEYED,
        (K, T, V) => {let K: T = V;},
    );
}
