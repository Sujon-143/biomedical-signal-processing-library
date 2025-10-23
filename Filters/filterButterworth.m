%% BUTTERWORTH FILTER (Direct function)
function y = filterButterworth(data, fs, fc, order, filterType)
% FILTERBUTTERWORTH Apply Butterworth filter to data
%
% Syntax:
%   y = filterButterworth(data, fs, fc, order, filterType)
%
% Inputs:
%   data       - Input signal vector
%   fs         - Sampling frequency (Hz)
%   fc         - Cutoff frequency (Hz) or [fc1 fc2] for bandpass/bandstop
%   order      - Filter order (default: 4)
%   filterType - 'low', 'high', 'bandpass', or 'stop' (default: 'low')
%
% Output:
%   y - Filtered signal
%
% Example:
%   y = filterButterworth(data, 1000, 50, 6, 'low');

    if nargin < 4, order = 4; end
    if nargin < 5, filterType = 'low'; end
    
    isRow = isrow(data);
    data = data(:);
    
    Wn = fc / (fs/2);
    [b, a] = designIIRFilter(order, Wn, filterType, IIRMethods.Butterworth);
    y = filtfilt_manual(b, a, data);
    
    if isRow, y = y'; end
end