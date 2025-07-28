# CPMpy WASM Build

This repository provides a `Makefile` and supporting files to build a WebAssembly (WASM) version of the [CPMPy](https://github.com/CPMpy/cpmpy) constraint programming library, suitable for running in the browser via [Pyodide](https://pyodide.org/).

Currently, this WASM build of CPMpy only supports the Rust-based constraint solver [Pumpkin](https://github.com/consol-lab/pumpkin).
Pumpkin is a lazy clause generation constraint programming solver developed by the ConSol Lab at TU Delft. 

The WASM build is working, but is not yet all too user friendly.
E.g. since only the Pumpkin solver is currently supported, calling `.solve()` on a model will default to `OR-Tools` and thus crash.
This will in the future be improved with additional patches to CPMpy.

For now, one can test the build using the following:

```python
import cpmpy as cp
x = cp.intvar(0, 10)
m = cp.Model(x > 3)
m.solve(solver="pumpkin")
x.value()
```

## 📁 Repository Structure

```
├── build/ # Final WASM build output
├── cache/ # Pyodide or dependency cache
├── dist/ # Intermediate build artifacts
├── external/ # External packages or sources (e.g. CPMPy clone)
├── packages/ # Extracted packages to include in Pyodide
├── patches # Patch to make libraries (cpmpy, pumpkin) compatible with WASM
├── index.html # Sample HTML page to run CPMPy in the browser
├── Makefile # Main build automation file
├── README.md # You're here!
├── rename-tags.py # Script to rename tag structure in wheel filenames
├── requirements.txt # List of Python dependencies
├── rust-toolchain.toml # Required Rust version for building Pumpkin
```

## 🚀 Quick Start

### Prerequisites

- `make`

### Build Instructions

```bash
# Clone this repository
git clone https://github.com/ThomSerg/cpmpy_wasm.git
cd cpmpy_wasm

# Build the WASM bundle
make all
```

### Test

Test the WASM build using a simple web page.

```bash
make test
```

