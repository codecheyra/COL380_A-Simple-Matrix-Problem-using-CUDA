#include <random>
#include <iostream>
#include "modify.cuh"
#include <chrono>

#define MODIFY_ON
#define CHECK_ON

void print(vector<vector<int>>& matrix) {
  for (int i = 0; i < matrix.size(); i++) {
    for (int j = 0; j < matrix[0].size(); j++)
      cout << matrix[i][j] << ' ';
  }
  cout << endl;
}

int main(int argc, char* argv[]) {
    int rows = atoi(argv[1]);
    int cols = atoi(argv[2]);
    int range = atoi(argv[3]);
    int num_matrices = atoi(argv[4]);
//   int range{ 1024 }, rows{ 10000 }, cols{ 10000 };
    cout << "rows: "<<rows<<" cols: "<<cols<<" range: "<<range<<" num_mat: "<<num_matrices<<endl;
  vector<vector<vector<int>>> matrices;
  for(int i = 0; i < num_matrices; i++){
    matrices.push_back(gen_matrix(range, rows, cols));
  }
//   matrices.push_back(gen_matrix(range, rows, cols));
  vector<int> ranges(num_matrices, range);

#ifdef MODIFY_ON
auto start = std::chrono::high_resolution_clock::now();
  vector<vector<vector<int>>> upd_matrices = modify(matrices, ranges);
  auto end = std::chrono::high_resolution_clock::now();
auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
  cout << "Time taken: " << duration/1000 << " ms\n";
#endif

#ifdef CHECK_ON
  if (check(upd_matrices, matrices)) cout << "Test Passed\n";
  else cout << "Test Failed\n";
#endif
  return 0;
}
