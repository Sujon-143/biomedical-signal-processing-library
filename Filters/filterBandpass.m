%% BANDPASS FILTER
%% FILTERBANDPASS Apply bandpass filter to data
%%
%% Syntax:
%%   y = filterBandpass(data, fs, fc1, fc2, order, method)
%%
%% Inputs:
%%   data   - Input signal vector
%%   fs     - Sampling frequency (Hz)
%%   fc1    - Lower cutoff frequency (Hz)
%%   fc2    - Upper cutoff frequency (Hz)
%%   order  - Filter order (default: 4)
%%   method - IIRMethods enum (default: IIRMethods.Butterworth)
%%
%% Output:
%%   y - Filtered signal
%%
%% Example:
%%   y = filterBandpass(data, 1000, 10, 100, 4, IIRMethods.Butterworth);
function y = filterBandpass(data, fs, fc1, fc2, order, method)

    if nargin < 5, order = 4; end
    if nargin < 6, method = IIRMethods.Butterworth; end
    
    validateInputs(data, fs, [fc1, fc2]);
    
    isRow = isrow(data);
    data = data(:);
    
    Wn = [fc1, fc2] / (fs/2);
    [b, a] = designIIRFilter(order, Wn, 'bandpass', method);
    y = filtfilt_manual(b, a, data);
    
    if isRow, y = y'; end
end
