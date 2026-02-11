use lyxal_scheduler::retry::compute_backoff;

#[test]
fn backoff_grows_and_caps() {
    let first = compute_backoff(0);
    let second = compute_backoff(1);
    let large = compute_backoff(10);

    assert!(second > first);
    assert!(large.num_seconds() <= 300);
}
