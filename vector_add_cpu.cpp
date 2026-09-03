#include <vector>
#include <iostream>
#include <chrono>

using namespace std;

int main() {
    vector<float> A(50000000);
    vector<float> B(50000000);
    vector<float> C(A.size());

    for (size_t i = 0; i < A.size(); i++) {
        A[i] = i;
        B[i] = i * 2;
    }
    chrono::high_resolution_clock::time_point start = chrono::high_resolution_clock::now();
    for (size_t i = 0; i < C.size(); i++) {
        C[i] = A[i] + B[i];
        //cout << C[i] << " ";
    }
    chrono::high_resolution_clock::time_point end = chrono::high_resolution_clock::now();
    chrono::duration<double> elapsed = end - start;
    cout << "CPU elapsed time: " << elapsed.count() * 1000 << " ms";
    return 0;
}
