%% MOVING AVERAGE FILTER
function y = filterMovingAverage(data, windowSize)
% FILTERMOVINGAVERAGE Apply moving average filter to data
%
% Syntax:
%   y = filterMovingAverage(data, windowSize)
%
% Inputs:
%   data       - Input signal vector
%   windowSize - Window size for averaging (default: 5)
%
% Output:
%   y - Filtered signal
%
% Example:
%   y = filterMovingAverage(data, 10);

    if nargin < 2, windowSize = 5; end
    
    isRow = isrow(data);
    data = data(:);
    
    windowSize = round(windowSize);
    n = length(data);
    y = zeros(n, 1);
    
    halfWin = floor(windowSize/2);
    
    for i = 1:n
        startIdx = max(1, i - halfWin);
        endIdx = min(n, i + halfWin);
        y(i) = mean(data(startIdx:endIdx));
    end
    
    if isRow, y = y'; end
end