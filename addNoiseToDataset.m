function noisyData = addNoiseToDataset(data, fs, desiredSNR, opts)
% ADDNOISETODATASET  Add biomedical-like noise types to signals at a given SNR.
% Toolbox-free version (no Signal Processing Toolbox required)
%
% Inputs:
%   data        - [N x M] clean signal(s)
%   fs          - sampling frequency in Hz
%   desiredSNR  - target Signal-to-Noise Ratio in dB
%   opts        - struct specifying which noises to add:
%                   .baselineWander, .gaussian, .highFreq, .powerLine, .emg
%
% Output:
%   noisyData   - noisy signal(s)

    if nargin < 4
        opts = struct('baselineWander',true, 'gaussian',true, ...
                      'highFreq',true, 'powerLine',true, 'emg',true);
    end

    [N, M] = size(data);
    if N < M
        data = data';
        [N, M] = size(data);
    end

    t = (0:N-1)' / fs;
    noisyData = zeros(size(data));

    for ch = 1:M
        signal = data(:, ch);
        noise = zeros(N, 1);

        % === Baseline Wander ===
        if isfield(opts, 'baselineWander') && opts.baselineWander
            f_bw = 0.3 + rand*0.4; % 0.3–0.7 Hz
            noise = noise + 0.2 * sin(2*pi*f_bw*t + rand*2*pi);
        end

        % === Gaussian Noise ===
        if isfield(opts, 'gaussian') && opts.gaussian
            noise = noise + randn(N,1);
        end

        % === High-Frequency Overshoot ===
        if isfield(opts, 'highFreq') && opts.highFreq
            f_hf = 80 + rand*40; % 80–120 Hz
            hf = sin(2*pi*f_hf*t);
            bursts = rand(N,1) > 0.98; % random short spikes
            noise = noise + 0.2 * hf .* bursts;
        end

        % === Power Line Interference (50 Hz) ===
        if isfield(opts, 'powerLine') && opts.powerLine
            f_line = 50;
            noise = noise + 0.1 * sin(2*pi*f_line*t);
        end

        % === EMG Noise (Manual Band-limited 20–200 Hz) ===
        if isfield(opts, 'emg') && opts.emg
            wn = randn(N,1);
            EMG_Flow = 20; EMG_Fhigh = 200;

            % Frequency-domain filtering using FFT
            W = fft(wn);
            freqs = (0:N-1)' * fs/N; % frequency axis
            mask = (freqs >= EMG_Flow & freqs <= EMG_Fhigh) | ...
                   (freqs >= fs-EMG_Fhigh & freqs <= fs-EMG_Flow); % mirror band
            W_filtered = W .* mask;
            emg = real(ifft(W_filtered));
            emg = emg / std(emg); % normalize power
            noise = noise + 0.1 * emg;
        end

        % === Scale noise for desired SNR ===
        Ps = mean(signal.^2);
        Pn = mean(noise.^2);
        if Pn == 0
            noisyData(:, ch) = signal;
        else
            scale = sqrt(Ps / (Pn * 10^(desiredSNR/10)));
            noisyData(:, ch) = signal + scale * noise;
        end
    end
end
