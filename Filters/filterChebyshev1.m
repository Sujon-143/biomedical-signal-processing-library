%% CHEBYSHEV TYPE 1 FILTER (Direct function)
%% FILTERCHEBYSHEV1 Apply Chebyshev Type 1 filter to data
%%
%% Syntax:
%%   y = filterChebyshev1(data, fs, fc, order, ripple, filterType)
%%
%% Inputs:
%%   data       - Input signal vector
%%   fs         - Sampling frequency (Hz)
%%   fc         - Cutoff frequency (Hz) or [fc1 fc2] for bandpass/bandstop
%%   order      - Filter order (default: 4)
%%   ripple     - Passband ripple in dB (default: 1)
%%   filterType - 'low', 'high', 'bandpass', or 'stop' (default: 'low')
%%
%% Output:
%%   y - Filtered signal
%%
%% Example:
%%   y = filterChebyshev1(data, 1000, 50, 4, 0.5, 'low');

function y = filterChebyshev1(data, fs, fc, order, ripple, filterType)

    if nargin < 4, order = 4; end
    if nargin < 5, ripple = 1; end
    if nargin < 6, filterType = 'low'; end
    
    isRow = isrow(data);
    data = data(:);
    
    Wn = fc / (fs/2);
    [b, a] = designIIRFilter(order, Wn, filterType, IIRMethods.Chebyshev1, ripple);
    y = filtfilt_manual(b, a, data);
    
    if isRow, y = y'; end
end
