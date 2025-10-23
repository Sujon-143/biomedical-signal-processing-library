function out = read_physionet_dat(record_name, varargin)
%READ_PHYSIONET_DAT Reads ECG data from PhysioNet-style .dat/.hea files
%
% Usage:
%   out = read_physionet_dat('100')
%   out = read_physionet_dat('100', 'tStart', 10, 'tEnd', 30)
%   out = read_physionet_dat('100', 'normalize', true, 'raw', true)
%
% Output structure:
%   out.signal   - ECG matrix [samples x channels]
%   out.time     - time vector in seconds
%   out.fs       - sampling frequency (Hz)
%   out.gain     - per-channel ADC gain
%   out.baseline - per-channel baseline (zero level)
%   out.units    - 'mV' or 'ADC counts'
%   out.meta     - header metadata

    %% Parse input arguments
    p = inputParser;
    addParameter(p, 'tStart', 0, @isnumeric);
    addParameter(p, 'tEnd', inf, @isnumeric);
    addParameter(p, 'normalize', false, @islogical);
    addParameter(p, 'raw', false, @islogical);
    parse(p, varargin{:});
    args = p.Results;

    %% Read and parse header file
    hea_file = [record_name, '.hea'];
    if ~isfile(hea_file)
        error('Header file %s not found.', hea_file);
    end
    
    header = strtrim(splitlines(fileread(hea_file)));
    header = header(~cellfun('isempty', header));

    % Parse first line: record_name nsig fs [length] [base_time] [base_date]
    first_line = strsplit(header{1});
    if numel(first_line) < 3
        error('Invalid .hea header format.');
    end
    
    nsig = str2double(first_line{2});
    fs = str2double(first_line{3});
    
    if isnan(nsig) || isnan(fs) || nsig < 1
        error('Invalid number of signals or sampling frequency in header.');
    end

    % Parse signal specification lines
    format_code = zeros(nsig, 1);
    gain = zeros(nsig, 1);
    baseline = zeros(nsig, 1);
    signal_names = strings(nsig, 1);
    
    for i = 1:nsig
        if i + 1 > length(header)
            error('Header file has fewer signal lines than specified.');
        end
        
        parts = strsplit(header{i + 1});
        if numel(parts) < 5
            error('Invalid signal specification in line %d.', i + 1);
        end
        
        % Parse format code
        format_code(i) = str2double(parts{2});
        
        % Parse gain with validation
        g = str2double(parts{3});
        if isnan(g) || g == 0
            gain(i) = 200;  % Default gain for ECG (ADC units per mV)
            warning('Channel %d: Invalid or zero gain detected, using default 200.', i);
        else
            gain(i) = g;
        end
        
        % Parse baseline with validation
        b = str2double(parts{5});
        if isnan(b)
            baseline(i) = 0;
            warning('Channel %d: Invalid baseline, using 0.', i);
        else
            baseline(i) = b;
        end
        
        % Extract signal name if available
        if numel(parts) >= 9
            signal_names(i) = string(parts{9});
        else
            signal_names(i) = sprintf("Channel_%d", i);
        end
    end

    % Check format consistency
    fmt = unique(format_code);
    if numel(fmt) ~= 1
        warning('Multiple format codes detected. Using format %d.', fmt(1));
    end
    fmt = fmt(1);

    %% Read binary data file
    dat_file = [record_name, '.dat'];
    if ~isfile(dat_file)
        error('Data file %s not found.', dat_file);
    end

    %% Decode based on format
    switch fmt
        case 212
            % Format 212: 12-bit samples, 2 samples per 3 bytes
            fid = fopen(dat_file, 'r', 'ieee-le');
            bytes = fread(fid, inf, 'uint8');
            fclose(fid);
            
            n = floor(length(bytes) / 3);
            raw = zeros(n * 2, 1);

            for i = 1:n
                b1 = bytes(3*(i-1) + 1);
                b2 = bytes(3*(i-1) + 2);
                b3 = bytes(3*(i-1) + 3);

                % Extract two 12-bit samples
                x1 = bitand(b2, 15) * 256 + b1;
                x2 = bitshift(b2, -4) * 256 + b3;

                % Convert to signed
                if x1 > 2047, x1 = x1 - 4096; end
                if x2 > 2047, x2 = x2 - 4096; end

                raw(2*i - 1) = x1;
                raw(2*i) = x2;
            end

            % Reshape to [samples x channels]
            raw = reshape(raw, nsig, [])';
            
        case 16
            % Format 16: 16-bit signed integers
            fid = fopen(dat_file, 'r', 'ieee-le');
            raw = fread(fid, [nsig, inf], 'int16')';
            fclose(fid);
            
        case 24
            % Format 24: 24-bit signed integers
            fid = fopen(dat_file, 'r', 'ieee-le');
            bytes = fread(fid, inf, 'uint8');
            fclose(fid);
            
            n = floor(length(bytes) / 3);
            raw = zeros(n, 1);
            for i = 1:n
                b1 = bytes(3*(i-1) + 1);
                b2 = bytes(3*(i-1) + 2);
                b3 = bytes(3*(i-1) + 3);
                x = b1 + 256*b2 + 65536*b3;
                if x > 8388607, x = x - 16777216; end
                raw(i) = x;
            end
            raw = reshape(raw, nsig, [])';
            
        otherwise
            error('Unsupported format code: %d. Supported: 16, 212, 24.', fmt);
    end

    %% Process data
    nSamples = size(raw, 1);
    t = (0:nSamples - 1)' / fs;

    % Apply time window
    tStart = max(args.tStart, 0);
    tEnd = min(args.tEnd, t(end));
    idx = (t >= tStart) & (t <= tEnd);
    
    raw = raw(idx, :);
    t = t(idx);

    % Calibrate to physical units (mV)
    calibrated = (raw - baseline') ./ gain';

    % Optional normalization (per channel)
    if args.normalize
        for ch = 1:nsig
            calibrated(:, ch) = (calibrated(:, ch) - mean(calibrated(:, ch))) / std(calibrated(:, ch));
        end
    end

    %% Prepare output
    if args.raw
        signal_out = raw;
        unit = 'ADC counts';
    else
        signal_out = calibrated;
        unit = 'mV';
    end

    out = struct( ...
        'signal', signal_out, ...
        'time', t, ...
        'fs', fs, ...
        'gain', gain, ...
        'baseline', baseline, ...
        'units', unit, ...
        'meta', struct( ...
            'record', record_name, ...
            'format', fmt, ...
            'channels', signal_names, ...
            'nsig', nsig, ...
            'tStart', tStart, ...
            'tEnd', tEnd ...
        ) ...
    );
    
    % Display summary
    fprintf('Read %d channels, %.2f seconds @ %.0f Hz\n', nsig, t(end)-t(1), fs);
    fprintf('Data range: [%.2f, %.2f] %s\n', min(signal_out(:)), max(signal_out(:)), unit);
end