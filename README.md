# Simple CUDA Vector Addition Benchmark

A quick side-by-side benchmark comparing a sequential C++ vector addition against a custom CUDA kernel on $50,000,000$ elements.

## Overview

I built this project to get hands-on experience with basic CUDA memory management and parallel execution patterns. It highlights the full memory lifecycle on the GPU:

1. Allocating VRAM with `cudaMalloc`.
2. Transferring input vectors from Host RAM to Device VRAM via `cudaMemcpy`.
3. Launching a 1D grid kernel using global thread indexing (`blockIdx.x * blockDim.x + threadIdx.x`).
4. Copying results back to Host RAM and releasing GPU memory.

---

## Benchmark Results

* **Array Size:** 50,000,000 elements (~200 MB per vector)
* **Environment:** Google Colab (NVIDIA T4 GPU)

| Variant | Execution Time | Notes |
| :--- | :--- | :--- |
| **CPU Baseline** | `55.00 ms` | Single-threaded C++ loop (`g++ -O3`) |
| **GPU Kernel Only** | `2.43 ms` | Isolated compute time using `cudaEvent_t` |
| **Total GPU Runtime** | `130.48 ms` | Includes PCIe transfers (`cudaMemcpy`) |

### Key Takeaway
Isolating the kernel execution shows a **~22x speedup** on raw computation compared to the CPU loop. However, total GPU runtime is dominated by copying data over the PCIe bus (`cudaMemcpy`). Because vector addition requires minimal arithmetic per byte loaded, transfer latency is the main bottleneck here, a classic example of a memory-bound workload.

---

## Building and Running

**CPU**
```bash
g++ -O3 vector_add_cpu.cpp -o cpu_add
./cpu_add
```

**CUDA**
```bash
nvcc vector_add_cuda.cu -o cuda_add
./cuda_add
```
