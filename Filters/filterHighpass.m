%% HIGHPASS FILTER
function y = filterHighpass(data, fs, fc, order, method)
% FILTERHIGHPASS Apply highpass filter to data
%
% Syntax:
%   y = filterHighpass(data, fs, fc, order, method)
%
% Inputs:
%   data   - Input signal vector
%   fs     - Sampling frequency (Hz)
%   fc     - Cutoff frequency (Hz)
%   order  - Filter order (default: 4)
%   method - IIRMethods enum (default: IIRMethods.Butterworth)
%
% Output:
%   y - Filtered signal
%
% Example:
%   y = filterHighpass(data, 1000, 10, 4, IIRMethods.Chebyshev1);

    if nargin < 4, order = 4; end
    if nargin < 5, method = IIRMethods.Butterworth; end
    
    validateInputs(data, fs, fc);
    
    isRow = isrow(data);
    data = data(:);
    
    Wn = fc / (fs/2);
    [b, a] = designIIRFilter(order, Wn, 'high', method);
    y = filtfilt_manual(b, a, data);
    
    if isRow, y = y'; end
end
