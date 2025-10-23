%% CHEBYSHEV TYPE 2 FILTER (Direct function)
function y = filterChebyshev2(data, fs, fc, order, attenuation, filterType)
% FILTERCHEBYSHEV2 Apply Chebyshev Type 2 filter to data
%
% Syntax:
%   y = filterChebyshev2(data, fs, fc, order, attenuation, filterType)
%
% Inputs:
%   data        - Input signal vector
%   fs          - Sampling frequency (Hz)
%   fc          - Cutoff frequency (Hz) or [fc1 fc2] for bandpass/bandstop
%   order       - Filter order (default: 4)
%   attenuation - Stopband attenuation in dB (default: 40)
%   filterType  - 'low', 'high', 'bandpass', or 'stop' (default: 'low')
%
% Output:
%   y - Filtered signal
%
% Example:
%   y = filterChebyshev2(data, 1000, 50, 4, 40, 'low');

    if nargin < 4, order = 4; end
    if nargin < 5, attenuation = 40; end
    if nargin < 6, filterType = 'low'; end
    
    isRow = isrow(data);
    data = data(:);
    
    Wn = fc / (fs/2);
    [b, a] = designIIRFilter(order, Wn, filterType, IIRMethods.Chebyshev2, [], attenuation);
    y = filtfilt_manual(b, a, data);
    
    if isRow, y = y'; end
end