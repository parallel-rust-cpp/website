# Calling Rust functions from C++

Before we begin implementing our Rust versions of the `step` function, we need to create some kind of interface the C++ benchmark program can interact with.
We'll be using the [C-language foreign function interface][unsafe-rust-calling-extern] to define a small wrapper function through which the C++ code can pass data by raw pointers to the Rust-program.

## C interface

Now, consider the following C++ declaration of the `step` function:
```cpp,no_run,noplaypen
{{#include ../../shortcut-comparison/src/main/step.hpp:step}}
```
We would like to implement a Rust function with a matching signature and name, such that when we compile our implementation as a static library, the linker will happily use our Rust `step` function as if it was originally written in C or C++.
Since Rust provides safer primitives built on raw pointers, we would prefer to use these primitives and avoid handling raw pointers where possible.
Therefore, we implement the algorithm logic in a private Rust function called `_step`, which we'll define shortly,  and expose its functionality through a public, thin C wrapper:
```rust,no_run,noplaypen
{{#include rs/step_c_abi.rs}}
```
Let's break that down.

We use the compile-time `no_mangle` attribute to instruct the compiler to retain the symbol name of the function so that the linker can find it in the static library:
```rust,no_run,noplaypen
{{#include rs/step_c_abi.rs:1}}
```

We declare a Rust function called `step` with public visibility, using the C-language ABI, that accepts 3 arguments:
```rust,no_run,noplaypen
{{#include rs/step_c_abi.rs:2}}
```
The arguments are one mutable and one immutable raw pointer to single precision floating point numbers, and one [32-bit integer][rust-types-layout].
We expect `r_raw` and `d_raw` to be non-null, aligned to the size of `f32` and initialized with `n * n` elements.
Proper alignment will be [asserted at runtime][rust-slice-align-assert] when we run all our implementations in debug mode, before doing the actual benchmarking.

In order to dereference the raw pointers, we need to use [`unsafe`][rust-unsafe-ref] blocks to tell the Rust compiler we expect the pointers to always be valid.
The compiler cannot know if the pointers are null, uninitialized or whether the underlying memory might even be deallocated by someone else, before the `step` call terminates.
However, we know that none of these should be possible, since the parent program will properly initialize the data and block on the [`step` call][cpp-step-call] before the vectors go out of scope and get destroyed along with the data.
We can now rest assured that the given data will always be properly allocated and initialized.

Preferably, we would let the Rust compiler take care of this kind of memory safety analysis for us, which we can do by wrapping the pointers into [slices][rust-slice-docs].
Slices are Rust primitive types which provide a dynamically-sized view into a block of memory, basically a pointer with a length.
This plays a fundamental part in the array access bounds checks the compiler will be inserting every time it is unable to check index values at compile time.
If the compiler can assert at compile time that no access can be out of bounds, e.g. if we are using an iterator to access all elements of the slice, the compiler will (should) elide all bounds checks.

Now, back to converting the raw pointers into slices.

First, we construct an immutable slice of length `n * n`, starting at the address pointed by `d_raw`:
```rust,no_run,noplaypen
{{#include rs/step_c_abi.rs:3}}
```

Then, we wrap `r_raw` also into a slice, but declare it mutable to allow writing into its memory block:
```rust,no_run,noplaypen
{{#include rs/step_c_abi.rs:4}}
```
Now we have two "not-unsafe" Rust primitive types that point to the same memory blocks as the pointers passed down by the C++ program calling our `step` function.
We can proceed by calling the actual Rust implementation of the `step` algorithm:
```rust,no_run,noplaypen
{{#include rs/step_c_abi.rs:5}}
```
The implementation of `_step` is what we will be heavily working on.
We'll take a look at the first version in the next chapter.

## C++ does not know how to panic

We are almost done, but need to take care of one more thing.
Rust runtime exceptions are called [panics][rust-panic-book], and a common implementation is stack unwinding, which results in a stack trace.
Letting a panic unwind across the ABI into foreign code is [**undefined behaviour**][rust-panic-unwind], which we naturally want to avoid whenever possible.
If an unwinding panic occurs during a call to `_step`, we try to catch the panic and instead print a small error message to the standard error stream, before we return control to the parent program:
```rust,no_run,noplaypen
    #[no_mangle]
    pub extern "C" fn step(r_raw: *mut f32, d_raw: *const f32, n: i32) {
        let result = std::panic::catch_unwind(|| {
            let d = unsafe { std::slice::from_raw_parts(d_raw, (n * n) as usize) };
            let mut r = unsafe { std::slice::from_raw_parts_mut(r_raw, (n * n) as usize) };
            _step(&mut r, d, n as usize);
        });
        if result.is_err() {
            eprintln!("error: rust panicked");
        }
    }
```
The `|| { }` expression is Rust for an [anonymous function][rust-closure-ref] that takes no arguments.

Our Rust program now has a C interface that the C++ benchmark program can call.
To avoid repetition, we wrap it into a Rust macro [`create_extern_c_wrapper`][rust-c-api-macro].
To create a C interface named `step` that wraps a Rust implementation named `_step`, we simply evaluate the macro:
```rust,no_run,noplaypen
{{#include ../../shortcut-comparison/src/rust/v0_baseline/src/lib.rs:extern_macro_call}}
```
Notice the exclamation mark, which is Rust syntax for evaluation compile-time macros.

Catching a panic here is also important for debugging.
During testing, we will compile all implementations using the `-C debug-assertions` flag, which enables [`debug_assert`][rust-debug-assert-docs] macros at runtime, even in optimized build.
Specifically, this allows us e.g. to [check][rust-slice-align-assert] that the given raw pointers are always properly aligned to `f32`, before we wrap then into Rust slices.

{{#include LINKS.md}}
