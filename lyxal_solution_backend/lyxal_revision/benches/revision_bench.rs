use criterion::{black_box, criterion_group, criterion_main, Criterion};
use lyxal_revision::{lyxal_revisioned, to_vec, from_slice};

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Debug, PartialEq, Clone)]
struct BenchStruct {
    a: u32,
    b: String,
    c: Vec<u8>,
}

fn bench_serialization(c: &mut Criterion) {
    let data = BenchStruct {
        a: 12345,
        b: "Benchmark string".to_string(),
        c: vec![0u8; 1024],
    };

    let mut group = c.benchmark_group("lyxal_revision");

    group.bench_function("serialize_struct", |b| {
        b.iter(|| to_vec(black_box(&data)).unwrap())
    });

    let encoded = to_vec(&data).unwrap();
    group.bench_function("deserialize_struct", |b| {
        b.iter(|| from_slice::<BenchStruct>(black_box(&encoded)).unwrap())
    });

    group.finish();
}

criterion_group!(benches, bench_serialization);
criterion_main!(benches);