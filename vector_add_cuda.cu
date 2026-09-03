#include <vector>
#include <iostream>
#include <chrono>

using namespace std;

__global__ void vectorAddKernel(float* A, float* B, float* C, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x; // Each thread has unique ID number (replaces for loop)
    if (i < n) {
        C[i] = A[i] + B[i];
    }
} 

int main() {
    int n = 50000000;
    int size_in_bytes = n * sizeof(float);
    float* d_A; //On device GPU
    float* d_B;
    float* d_C;

    vector<float> A(n);
    vector<float> B(n);
    vector<float> C(n);

    for (int i = 0; i < n; i++) {
        A[i] = i;
        B[i] = i * 2;
    }

    cudaMalloc(&d_A, size_in_bytes); //Allocate memory into address of d_A on device GPU
    cudaMalloc(&d_B, size_in_bytes); //Allocate memory into address of d_B on device GPU
    cudaMalloc(&d_C, size_in_bytes); //Allocate memory into address of d_C on device GPU

    chrono::high_resolution_clock::time_point start = chrono::high_resolution_clock::now();

    cudaMemcpy(d_A, A.data(), size_in_bytes, cudaMemcpyHostToDevice); //Copy data from host to device
    cudaMemcpy(d_B, B.data(), size_in_bytes, cudaMemcpyHostToDevice);

    // CUDA Events for just kernel execution time
    cudaEvent_t start_event, stop_event;
    cudaEventCreate(&start_event);
    cudaEventCreate(&stop_event); 

    int threadsPerBlock = 256; //Group threads into blocks of 256 threads
    int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock; //Calculate number of blocks needed

    cudaEventRecord(start_event);

    vectorAddKernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, n); //Launch kernel

    cudaEventRecord(stop_event);

    cudaMemcpy(C.data(), d_C, size_in_bytes, cudaMemcpyDeviceToHost); //Copy data from device VRAM to host RAM
    cout << "C[100]: " << C[100]; //Quick check to see if the result is correct

    chrono::high_resolution_clock::time_point end = chrono::high_resolution_clock::now();
    chrono::duration<double> elapsed = end - start;

    cudaEventSynchronize(stop_event);
    float kernel_ms = 0;
    cudaEventElapsedTime(&kernel_ms, start_event, stop_event);
    cout << "Kernel elapsed time: " << kernel_ms << " ms" << endl;
    cout << "GPU elapsed time: " << elapsed.count() * 1000 << " ms";
 
    cudaFree(d_A); //Free memory on device GPU
    cudaFree(d_B); 
    cudaFree(d_C);

    cudaEventDestroy(start_event);
    cudaEventDestroy(stop_event);

    return 0;
}

