fn main() {
    lyxal_raft_macros::expand!(
        !KEYED,
        (K, T, V) => {K; T; V;},
        (c, , ,),
        (c, , u8 ),
    );
}
