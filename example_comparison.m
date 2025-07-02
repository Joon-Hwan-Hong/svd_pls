% EXAMPLE_COMPARISON
% This script compares the runtime of PLScorr and PLScorr_parallel
% using randomly generated data.

% Settings for the synthetic dataset
nSub  = 100;   % number of subjects
nX    = 50;    % number of X features
nY    = 60;    % number of Y features

% Generate random data
rng(1); % for reproducibility
X = randn(nSub, nX);
Y = randn(nSub, nY);

% Analysis options (reduced numbers for a quick example)
opts = struct();
opts.nPerm = 50;    % keep small for demonstration purposes
opts.nBoot = 50;    % keep small for demonstration purposes
opts.norm  = 'zscore';

% Run standard PLScorr
fprintf('Running PLScorr...\n');
tic;
PLSout = PLScorr(X, Y, opts); %#ok<NASGU>
time_serial = toc;
fprintf('PLScorr completed in %.2f seconds.\n', time_serial);

% Run parallel PLScorr
fprintf('Running PLScorr\_parallel...\n');
% start parallel pool outside of timing to avoid startup overhead
if isempty(gcp('nocreate'))
    parpool; %#ok<*NOPRT>
end

startPar = tic;
PLSout_par = PLScorr_parallel(X, Y, opts); %#ok<NASGU>
time_parallel = toc(startPar);

fprintf('PLScorr\_parallel completed in %.2f seconds.\n', time_parallel);

% Display summary
fprintf('\n--- Runtime comparison ---\n');
fprintf('PLScorr runtime: %.2f s\n', time_serial);
fprintf('PLScorr\_parallel runtime: %.2f s\n', time_parallel);

% Shut down parallel pool if it is still running
if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
