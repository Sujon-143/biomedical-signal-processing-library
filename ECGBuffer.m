classdef ECGBuffer
    properties
        data      double    % ECG signal matrix [samples x channels]
        time      double    % Time vector in seconds
        fs        double    % Sampling frequency (Hz)
        channels  string    % Channel names
        units     char      % Signal units ('mV' or 'ADC counts')
        gain      double    % Per-channel ADC gain
        baseline  double    % Per-channel baseline
        filepath  char      % Full path to record
        record    char      % Record name
        loaded    datetime  % Timestamp of loading
        meta      struct    % Metadata structure
    end
    
end