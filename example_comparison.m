% EXAMPLE_COMPARISON
% This script compares the runtime of PLScorr and PLScorr_parallel
% using randomly generated data.

% Settings for the synthetic dataset
nSub  = 3000;   % number of subjects
nX    = 500;    % number of X features
nY    = 120;    % number of Y features

% Generate random data
rng(1); % for reproducibility
X = randn(nSub, nX);
Y = randn(nSub, nY);

% Analysis options (reduced numbers for a quick example)
opts = struct();
opts.nPerm = 2000;    % keep small for demonstration purposes
opts.nBoot = 2000;    % keep small for demonstration purposes
opts.norm  = 'zscore';

% Run standard PLScorr
fprintf('Running PLScorr...\n');
tic;
PLSout = PLScorr(X, Y, opts);
time_serial = toc;
fprintf('PLScorr completed in %.2f seconds.\n', time_serial);

% Run parallel PLScorr
fprintf('Running PLS parallel...\n');
% start parallel pool outside of timing to avoid startup overhead
if isempty(gcp('nocreate'))
    parpool(11);
end

startPar = tic;
PLSout_par = PLScorr_parallel(X, Y, opts);
time_parallel = toc(startPar);

fprintf('PLScorr parallel completed in %.2f seconds.\n', time_parallel);

% Display summary
fprintf('\n--- Runtime comparison ---\n');
fprintf('PLScorr runtime: %.2f s\n', time_serial);
fprintf('PLScorr parallel runtime: %.2f s\n', time_parallel);

% Shut down parallel pool if it is still running
if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
