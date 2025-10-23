function [buffer, status] = load_physionet_gui(varargin)
%LOAD_PHYSIONET_GUI Interactive file loader for PhysioNet ECG data
%
% Usage:
%   [buffer, status] = load_physionet_gui()
%   [buffer, status] = load_physionet_gui('tStart', 10, 'tEnd', 30)
%   [buffer, status] = load_physionet_gui('normalize', true)
%   [buffer, status] = load_physionet_gui('preview', false)
%
% Opens file browser to select .hea or .dat file (automatically finds pair)
% Returns data buffer and status structure for GUI display
%
% Outputs:
%   buffer - Data structure with ECG signals and metadata
%   status - Status structure with loading information for GUI display
%
% Buffer structure:
%   buffer.data      - ECG signal matrix [samples x channels]
%   buffer.time      - time vector in seconds
%   buffer.fs        - sampling frequency (Hz)
%   buffer.channels  - channel names
%   buffer.units     - signal units ('mV' or 'ADC counts')
%   buffer.filepath  - full path to record
%   buffer.record    - record name
%   buffer.loaded    - timestamp of loading
%
% Status structure:
%   status.success      - true/false
%   status.message      - status message
%   status.record       - record name
%   status.channels     - cell array of channel names
%   status.nChannels    - number of channels
%   status.duration     - duration in seconds
%   status.durationStr  - formatted duration string
%   status.fs           - sampling frequency
%   status.nSamples     - number of samples
%   status.units        - signal units
%   status.dataRange    - [min, max] values
%   status.dataRangeStr - formatted range string
%   status.timestamp    - loading timestamp string
%   status.filePath     - full file path

    %% Parse optional arguments
    p = inputParser;
    addParameter(p, 'tStart', 0, @isnumeric);
    addParameter(p, 'tEnd', inf, @isnumeric);
    addParameter(p, 'normalize', false, @islogical);
    addParameter(p, 'raw', false, @islogical);
    addParameter(p, 'preview', true, @islogical);  % Auto-preview option
    parse(p, varargin{:});
    args = p.Results;
    
    % Extract preview flag
    show_preview = args.preview;
    
    % Remove preview from args to pass to reader
    reader_args = rmfield(args, 'preview');
    reader_args_cell = struct2cell(reader_args);
    reader_fields = fieldnames(reader_args);
    reader_varargin = [reader_fields'; reader_args_cell'];
    reader_varargin = reader_varargin(:)';

    %% Initialize outputs
    buffer = [];
    status = struct();
    status.success = false;
    status.message = '';
    
    %% Open file dialog - Select header file first
    [hea_filename, hea_pathname] = uigetfile(...
        {'*.hea', 'Header Files (*.hea)'; ...
         '*.*', 'All Files (*.*)'}, ...
        'Step 1/2: Select PhysioNet Header File (.hea)');
    
    if isequal(hea_filename, 0)
        status.message = 'File selection cancelled by user';
        return;
    end
    
    hea_file = fullfile(hea_pathname, hea_filename);
    
    % Extract record name
    [~, record_name, ~] = fileparts(hea_filename);
    
    %% Select data file
    [dat_filename, dat_pathname] = uigetfile(...
        {'*.dat', 'Data Files (*.dat)'; ...
         '*.*', 'All Files (*.*)'}, ...
        'Step 2/2: Select PhysioNet Data File (.dat)', ...
        fullfile(hea_pathname, [record_name, '.dat']));
    
    if isequal(dat_filename, 0)
        status.message = 'Data file selection cancelled by user';
        return;
    end
    
    dat_file = fullfile(dat_pathname, dat_filename);
    
    %% Verify files exist and match
    if ~isfile(hea_file)
        status.message = sprintf('Header file not found: %s', hea_file);
        return;
    end
    
    if ~isfile(dat_file)
        status.message = sprintf('Data file not found: %s', dat_file);
        return;
    end
    
    % Check if record names match
    [~, dat_record, ~] = fileparts(dat_filename);
    if ~strcmp(record_name, dat_record)
        warning('Record names do not match: %s vs %s. Proceeding anyway...', ...
                record_name, dat_record);
    end
    
    % Create temporary copies in same directory if needed
    if ~strcmp(hea_pathname, dat_pathname)
        % Files are in different directories - create temp working directory
        temp_dir = tempname;
        mkdir(temp_dir);
        copyfile(hea_file, fullfile(temp_dir, hea_filename));
        copyfile(dat_file, fullfile(temp_dir, dat_filename));
        record_path = fullfile(temp_dir, record_name);
        use_temp = true;
    else
        record_path = fullfile(hea_pathname, record_name);
        use_temp = false;
    end
    
    %% Read the data
    try
        % Get the directory containing the files
        [working_dir, ~, ~] = fileparts(record_path);
        old_dir = pwd;
        cd(working_dir);
        
        ecg_data = read_physionet_dat(record_name, reader_varargin{:});
        
        cd(old_dir);
        
        % Clean up temp directory if used
        if use_temp
            rmdir(temp_dir, 's');
        end
        
    catch ME
        cd(old_dir);
        if use_temp && exist(temp_dir, 'dir')
            rmdir(temp_dir, 's');
        end
        status.message = sprintf('Failed to read data: %s', ME.message);
        return;
    end
    
    %% Create buffer structure
    buffer = struct();
    buffer.data = ecg_data.signal;
    buffer.time = ecg_data.time;
    buffer.fs = ecg_data.fs;
    buffer.channels = ecg_data.meta.channels;
    buffer.units = ecg_data.units;
    buffer.gain = ecg_data.gain;
    buffer.baseline = ecg_data.baseline;
    buffer.filepath = record_path;
    buffer.record = record_name;
    buffer.loaded = datetime('now');
    buffer.meta = ecg_data.meta;
    
    %% Create status structure for GUI display
    duration = buffer.time(end) - buffer.time(1);
    data_min = min(buffer.data(:));
    data_max = max(buffer.data(:));
    
    status.success = true;
    status.message = 'Data loaded successfully';
    status.record = buffer.record;
    status.channels = cellstr(buffer.channels);
    status.nChannels = length(buffer.channels);
    status.duration = duration;
    status.durationStr = format_duration(duration);
    status.fs = buffer.fs;
    status.nSamples = size(buffer.data, 1);
    status.units = buffer.units;
    status.dataRange = [data_min, data_max];
    status.dataRangeStr = sprintf('[%.2f, %.2f] %s', data_min, data_max, buffer.units);
    status.timestamp = datestr(buffer.loaded, 'yyyy-mm-dd HH:MM:SS');
    status.filePath = record_path;
    status.heaFile = hea_file;
    status.datFile = dat_file;
    
    % Create formatted summary for display
    status.summary = create_summary(status);
    
    %% Optional preview
    if show_preview
        preview_ecg_data(buffer);
    end
end

%% Helper function: Format duration
function str = format_duration(seconds)
    if seconds < 60
        str = sprintf('%.1f sec', seconds);
    elseif seconds < 3600
        minutes = floor(seconds / 60);
        secs = mod(seconds, 60);
        str = sprintf('%d min %.1f sec', minutes, secs);
    else
        hours = floor(seconds / 3600);
        minutes = floor(mod(seconds, 3600) / 60);
        str = sprintf('%d hr %d min', hours, minutes);
    end
end

%% Helper function: Create summary text
function summary = create_summary(status)
    summary = sprintf(['Record: %s\n' ...
                      'Channels: %d (%s)\n' ...
                      'Duration: %s\n' ...
                      'Sampling Rate: %.0f Hz\n' ...
                      'Samples: %d\n' ...
                      'Units: %s\n' ...
                      'Data Range: %s\n' ...
                      'Loaded: %s'], ...
                      status.record, ...
                      status.nChannels, ...
                      strjoin(status.channels, ', '), ...
                      status.durationStr, ...
                      status.fs, ...
                      status.nSamples, ...
                      status.units, ...
                      status.dataRangeStr, ...
                      status.timestamp);
end

%% Helper function: Preview plot
function preview_ecg_data(buffer)
    figure('Name', sprintf('ECG Preview: %s', buffer.record), ...
           'NumberTitle', 'off', ...
           'Position', [100 100 1000 600]);
    
    n_channels = size(buffer.data, 2);
    
    % Show max 10 seconds for clarity
    max_time = min(10, buffer.time(end));
    idx = buffer.time <= max_time;
    
    for ch = 1:n_channels
        subplot(n_channels, 1, ch);
        plot(buffer.time(idx), buffer.data(idx, ch), 'b', 'LineWidth', 1);
        grid on;
        ylabel(sprintf('%s\n(%s)', buffer.channels(ch), buffer.units));
        if ch == 1
            title(sprintf('Record: %s | Fs: %.0f Hz | Duration: %.1f s', ...
                buffer.record, buffer.fs, buffer.time(end)));
        end
        if ch == n_channels
            xlabel('Time (seconds)');
        else
            set(gca, 'XTickLabel', []);
        end
    end
end