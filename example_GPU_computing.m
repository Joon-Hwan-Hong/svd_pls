clear
% Benchmark repeated large matrix multiplications on CPU vs GPU.
% Parameters
N = 2000; % Matrix dimension (NxN)
numRepeats = 100; % Number of times to repeat A*B
% Generate random matrices
fprintf('Generating two %dx%d random matrices...\n', N, N);
A = rand(N, N);
B = rand(N, N);
% CPU benchmark
fprintf('Starting CPU benchmark (%d repetitions)...\n', numRepeats);
cpuTimer = tic;
for i = 1:numRepeats
C_cpu = A * B;
end
cpuTime = toc(cpuTimer);
fprintf('CPU total time: %.4f seconds (%.4f s per multiplication)\n\n', ...
cpuTime, cpuTime/numRepeats);
% GPU benchmark
% Reset and prepare GPU
parallel.gpu.enableCUDAForwardCompatibility(true)
g = gpuDevice(1);
fprintf('Using GPU: %s (compute %s)\n', g.Name, g.ComputeCapability);
% 1) Single‐precision
A_gpu = gpuArray(single(A));
B_gpu = gpuArray(single(B));
% 2) Preallocate a 3D “page” array of size [N N numRepeats]
A3D = repmat(A_gpu, 1, 1, numRepeats);
B3D = repmat(B_gpu, 1, 1, numRepeats);
C3D = gpuArray.zeros(N, N, numRepeats, 'single');
% 3) Warm up once (JIT, kernel load, etc.)
C3D(:,:,1) = pagefun(@mtimes, A3D(:,:,1), B3D(:,:,1));
wait(g);
% 4) Time the batched multiplies in one go
optTimer = tic;
C3D = pagefun(@mtimes, A3D, B3D);
wait(g);
optTime = toc(optTimer);
fprintf('GPU total time: %.4f seconds (%.4f s per multiplication)\n\n', optTime, optTime/numRepeats);
% Summary
fprintf('===== Benchmark Results =====\n');
fprintf('Matrix size : %dx%d\n', N, N);
fprintf('Repetitions : %d\n', numRepeats);
fprintf('CPU total time : %.4f s\n', cpuTime);
fprintf('GPU total time : %.4f s\n', optTime);
fprintf('Speedup (CPU/GPU) : %.2fx\n', cpuTime / optTime);
fprintf('=======================\n');

