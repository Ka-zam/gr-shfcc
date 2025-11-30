# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

gr-shfcc is a GNU Radio Out-of-Tree (OOT) module for signal processing, particularly focused on sinusoidal signal estimation, phase noise simulation, and tape transport emulation. The name stands for "Super High Fidelity Compact Cassette".

## Build Commands

```bash
# Create build directory and configure
mkdir build && cd build
cmake ..

# Build
make

# Run tests
make test

# Install (may require sudo)
make install
```

## Dependencies

- GNU Radio 3.7.2+
- Boost 1.35+
- Armadillo 7.300+ (linear algebra library)
- CppUnit (for testing)
- SWIG (for Python bindings)

## Architecture

This is a standard GNU Radio OOT module following gr_modtool conventions:

- **`include/shfcc/`** - Public C++ headers defining block interfaces
- **`lib/`** - C++ implementation files (*_impl.cc) and unit tests (qa_*.cc, test_shfcc.cc)
- **`python/`** - Python modules and unit tests (qa_*.py)
- **`swig/`** - SWIG interface files for Python bindings
- **`grc/`** - GNU Radio Companion block definitions (XML files)

## Signal Processing Blocks

| Block | Type | Purpose |
|-------|------|---------|
| `sine_est` | sync_decimator | Estimate parameters from sinusoidal signal in AWGN |
| `ncosest_fc` | sync_decimator | Estimate multiple sinusoids (NLS estimator) |
| `cexp_est` | - | Complex exponential estimation |
| `phase_noise_mixer_cc` | sync_block | Mixer with configurable phase noise impairment |
| `tape_speed_ff` | block | Variable speed tape transport simulation (wow/flutter) |
| `vaverage_ff` | - | Vector averaging |
| `map_ss` | - | Signal mapping |
| `pack_bs` | - | Bit packing |

## Running Individual Tests

```bash
# C++ unit tests (from build directory)
./lib/test-shfcc

# Python unit tests (from build directory)
ctest -R qa_sine_est
ctest -R qa_phase_noise_mixer_cc
# etc.
```

## Code Style

- C++ files use `*_impl.cc` suffix for implementation
- Block classes inherit from `gr::sync_block`, `gr::sync_decimator`, or `gr::block`
- Factory pattern via static `make()` methods
- Boost shared_ptr (`boost::shared_ptr<T>`) for memory management
