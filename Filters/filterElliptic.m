%% ELLIPTIC FILTER (Direct function)
%% FILTERELLIPTIC Apply Elliptic filter to data
%%
%% Syntax:
%%   y = filterElliptic(data, fs, fc, order, ripple, attenuation, filterType)
%%
%% Inputs:
%%   data        - Input signal vector
%%   fs          - Sampling frequency (Hz)
%%   fc          - Cutoff frequency (Hz) or [fc1 fc2] for bandpass/bandstop
%%   order       - Filter order (default: 4)
%%   ripple      - Passband ripple in dB (default: 1)
%%   attenuation - Stopband attenuation in dB (default: 40)
%%   filterType  - 'low', 'high', 'bandpass', or 'stop' (default: 'low')
%%
%% Output:
%%   y - Filtered signal
%%
%% Example:
%%   y = filterElliptic(data, 1000, 50, 4, 1, 40, 'low');
function y = filterElliptic(data, fs, fc, order, ripple, attenuation, filterType)
    if nargin < 4, order = 4; end
    if nargin < 5, ripple = 1; end
    if nargin < 6, attenuation = 40; end
    if nargin < 7, filterType = 'low'; end
    
    isRow = isrow(data);
    data = data(:);
    
    Wn = fc / (fs/2);
    [b, a] = designIIRFilter(order, Wn, filterType, IIRMethods.Elliptic, ripple, attenuation);
    y = filtfilt_manual(b, a, data);
    
    if isRow, y = y'; end
end