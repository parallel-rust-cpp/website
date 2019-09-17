# Benchmark results

All 8 implementations have so far been benchmarked on three different Intel CPUs.
You can find the benchmark program on [GitHub][shortcut-comparison-github].

## Benchmark parameters

* All benchmarks use an input array containing `6000 * 6000 = 36M` elements, allocated and initialized before the benchmark timing starts, and destroyed after the timing has ended.
* All elements of the input array are single precision floating point numbers drawn uniformly at random from `[0, 1.0)`.
* Before compiling the single-threaded benchmark programs, all parallel libraries were explicitly disabled using compile time switches.
* When benchmarking in parallel, the parallel libraries were instructed to use 4 software threads and the benchmark process was bound with [`taskset`][taskset-manpage] to 4 physical cores.


## Benchmark 1: Intel Xeon E3-1230 v5

* Mid-range server/workstation CPU with 4 physical cores and 8 hardware threads (hyper-threading).
* Maximum clock speed **3.8 GHz**.
* [Intel specifications][ark-intel-xeon-e3-1230].
* [Wikichip][wikichip-xeon-e3-1230].

![CPU topology of Xeon E3 1230 v5][xeon-topology-img]

### Compiler versions

* C++ (GCC): `g++ 7.4.0-1ubuntu1`
* C++ (Clang): `clang 6.0.0-1ubuntu2`
* Rust: `rustc 1.38.0-nightly`

![][xeon-multi-core-img]

![][xeon-single-core-img]

## Benchmark 2: Intel i5-4690k

* Mid-range desktop CPU with 4 physical cores and 4 hardware threads (no hyper-threading).
* Overclocked to **4.3 GHz**.
* [Intel specifications][ark-intel-i5-4690k].

![CPU topology of i5 4690k][i5-4690k-topology-img]

### Compiler versions

* C++ (GCC): `g++ 9.1.0`
* C++ (Clang): `clang 8.0.1`
* Rust: `rustc 1.38.0-nightly`

![][i5-4690k-multi-core-img]

![][i5-4690k-single-core-img]

## Benchmark 3: Intel i5-8250U

* Mid-range laptop CPU with 4 physical cores and 8 hardware threads.
* Maximum clock speed **3.4 GHz**.
* [Intel specifications][ark-intel-i5-8250U].

![CPU topology of i5 8250U][i5-8250U-topology-img]

### Compiler versions

* C++ (GCC): `g++ 9.1.0`
* C++ (Clang): `clang 8.0.1`
* Rust: `rustc 1.38.0-nightly`

![][i5-8250U-multi-core-img]

![][i5-8250U-single-core-img]

{{#include LINKS.md}}
{{#include IMAGES.md}}
