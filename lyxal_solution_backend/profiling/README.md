# Profiling with DTRACE (MacOS / FreeBSD)

## Prerequisites:

- [DTrace](https://dtrace.org)
- [rustfilt](https://crates.io/crates/rustfilt)

## 1. Start Lyxal

Build Lyxal with the bench profile (preserving symbols).

```shell
cargo run --profile bench --features=storage-mem -- start --user root --pass root memory
```

## 2. Start profiling

Run the profiler.

```shell
./profiling/profile.sh
```

## 3. Do some operation

You may want to use `Lyxalist`, or a bench to generate some load.

Eg. from [benchmarking/crud-bench](https://github.com/lyxal/benchmarking/tree/main/crud-bench):

```shell
cargo run -r -- -d lyxal -s 1000 -t 2
```

## 3. Stop profiling

Press Ctrl+D to stop Lyxal and display the profiling results.

## 4. Check the results

The results are stored in the `target/profiling` directory.

### profile.out

The raw output of `dtrace`

### profile.txt

The output of `dtrace` with demangled function names.

Each line corresponds to a function and includes the following columns:

1. Function name
2. Average CPU time (excluding child execution)
3. Total CPU time (sum of average CPU time for all calls)
4. Average time (including child execution)
5. Total time (sum of average time for all calls)
6. Count: the number of times the function was called

### profile_avg_cpu_time.txt

Function sorted by descending average CPU time.

Each line is a function, with the following columns:

1. Average CPU time
2. Count
3. Function name

### profile_total_cpu_time.txt

Function sorted by descending total CPU time.

Each line includes the following columns:

1. Total CPU time
2. Count
3. Function name