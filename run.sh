module purge
module load compiler/gcc/9.1.0
module load suite/nvidia-hpc-sdk/20.7/cuda11.0
# nvcc main.cpp check.cpp modify.cu -Xcompiler -fopenmp -o check




nvcc main.cpp check.cpp modify.cu -arch=sm_35 -Xcompiler -fopenmp -Wno-deprecated-gpu-targets -o check 
./check 1000 1000 1024 1
./check 1000 1000 4096 1
./check 1000 1000 100000 1
./check 1000 1000 100000000 1


./check 10000 10000 1024 1
./check 10000 10000 4096 1
./check 10000 10000 100000 1
./check 10000 10000 100000000 1


./check 10000 100000 1024 1
./check 10000 100000 4096 1
./check 10000 100000 100000 1
./check 10000 100000 100000000 1


./check 1000 1000 1024 10
./check 1000 1000 4096 10
./check 1000 1000 100000 10
./check 1000 1000 100000000 10

./check 10000 10000 1024 10
./check 10000 10000 4096 10
./check 10000 10000 100000 10
./check 10000 10000 100000000 10
