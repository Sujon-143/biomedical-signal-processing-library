%% EXPONENTIAL MOVING AVERAGE FILTER
function y = filterMovingExp(data, alpha)
% FILTERMOVINGEXP Apply exponential moving average filter to data
%
% Syntax:
%   y = filterMovingExp(data, alpha)
%
% Inputs:
%   data  - Input signal vector
%   alpha - Smoothing factor between 0 and 1 (default: 0.3)
%           Higher values = more responsive, lower values = more smoothing
%
% Output:
%   y - Filtered signal
%
% Example:
%   y = filterMovingExp(data, 0.2);

    if nargin < 2, alpha = 0.3; end
    
    if alpha <= 0 || alpha > 1
        error('Alpha must be between 0 and 1');
    end
    
    isRow = isrow(data);
    data = data(:);
    
    n = length(data);
    y = zeros(n, 1);
    y(1) = data(1);
    
    for i = 2:n
        y(i) = alpha * data(i) + (1 - alpha) * y(i-1);
    end
    
    if isRow, y = y'; end
end