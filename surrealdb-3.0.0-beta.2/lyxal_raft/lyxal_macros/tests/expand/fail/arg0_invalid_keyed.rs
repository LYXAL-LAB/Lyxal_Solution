fn main() {
    lyxal_raft_macros::expand!(
        !FOO,
        (K, T, V) => {K; T; V;},
    );

    lyxal_raft_macros::expand!(
        FOO,
        (K, T, V) => {K; T; V;},
    );
}
