#include "modify.cuh"
#include <cuda_runtime.h>
#include <vector>
#include <cassert>

using std::vector;

__global__ void countFreqKernel(const int *d_input, int total_elements, int *d_freq, int range)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < total_elements)
    {
        int val = d_input[idx];
        atomicAdd(&d_freq[val], 1);
    }
}

__device__ int binarySearch(const int *d_prefix, int range, int idx)
{
    int low = 1;
    int high = range + 1;
    while (low < high)
    {
        int mid = (low + high) >> 1;
        if (d_prefix[mid] <= idx)
            low = mid + 1;
        else
            high = mid;
    }
    return low - 1;
}

__global__ void assignSortedKernel(const int *d_prefix, int range, int total_elements, int *d_output)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < total_elements)
    {
        int value = binarySearch(d_prefix, range, idx);
        d_output[idx] = value;
    }
}

vector<vector<vector<int>>> modify(vector<vector<vector<int>>> &matrices, vector<int> &ranges)
{
    int numMatrices = matrices.size();
    vector<vector<vector<int>>> result(numMatrices);
    vector<cudaStream_t> streams(numMatrices);
    for (int k = 0; k < numMatrices; k++)
    {
        cudaStreamCreate(&streams[k]);
    }
    for (int k = 0; k < numMatrices; k++)
    {
        int rows = matrices[k].size();
        assert(rows > 0);
        int cols = matrices[k][0].size();
        int total_elements = rows * cols;
        int range = ranges[k];
        vector<int> h_input(total_elements);
        for (int i = 0; i < rows; i++)
        {
            for (int j = 0; j < cols; j++)
            {
                h_input[i * cols + j] = matrices[k][i][j];
            }
        }
        int *d_input;
        int *d_output;
        int *d_freq;
        int *d_prefix;
        cudaMalloc(&d_input, total_elements * sizeof(int));
        cudaMalloc(&d_output, total_elements * sizeof(int));
        cudaMalloc(&d_freq, (range + 2) * sizeof(int));
        cudaMalloc(&d_prefix, (range + 2) * sizeof(int));
        cudaMemsetAsync(d_freq, 0, (range + 2) * sizeof(int), streams[k]);
        cudaMemcpyAsync(d_input, h_input.data(), total_elements * sizeof(int), cudaMemcpyHostToDevice, streams[k]);
        int threadsPerBlock = 256;
        int blocks = (total_elements + threadsPerBlock - 1) / threadsPerBlock;
        countFreqKernel<<<blocks, threadsPerBlock, 0, streams[k]>>>(d_input, total_elements, d_freq, range);
        vector<int> h_freq(range + 2, 0);
        cudaMemcpyAsync(h_freq.data(), d_freq, (range + 2) * sizeof(int), cudaMemcpyDeviceToHost, streams[k]);
        cudaStreamSynchronize(streams[k]);
        vector<int> h_prefix(range + 2, 0);
        h_prefix[1] = 0;
        for (int v = 1; v <= range; v++)
        {
            h_prefix[v + 1] = h_prefix[v] + h_freq[v];
        }
        cudaMemcpyAsync(d_prefix, h_prefix.data(), (range + 2) * sizeof(int), cudaMemcpyHostToDevice, streams[k]);
        blocks = (total_elements + threadsPerBlock - 1) / threadsPerBlock;
        assignSortedKernel<<<blocks, threadsPerBlock, 0, streams[k]>>>(d_prefix, range, total_elements, d_output);
        vector<int> h_output(total_elements);
        cudaMemcpyAsync(h_output.data(), d_output, total_elements * sizeof(int), cudaMemcpyDeviceToHost, streams[k]);
        cudaStreamSynchronize(streams[k]);
        vector<vector<int>> sorted_matrix(rows, vector<int>(cols));
        for (int i = 0; i < rows; i++)
        {
            for (int j = 0; j < cols; j++)
            {
                sorted_matrix[i][j] = h_output[i * cols + j];
            }
        }
        result[k] = sorted_matrix;
        cudaFree(d_input);
        cudaFree(d_output);
        cudaFree(d_freq);
        cudaFree(d_prefix);
    }
    for (int k = 0; k < numMatrices; k++)
    {
        cudaStreamDestroy(streams[k]);
    }
    return result;
}

