%% KALMAN FILTER
function y = filterKalman(data, processNoise, measNoise, initialEst, initialCov)
% FILTERKALMAN Apply 1D Kalman filter to data
%
% Syntax:
%   y = filterKalman(data, processNoise, measNoise, initialEst, initialCov)
%
% Inputs:
%   data         - Input signal vector
%   processNoise - Process noise covariance Q (default: 1e-5)
%   measNoise    - Measurement noise covariance R (default: 0.01)
%   initialEst   - Initial state estimate (default: data(1))
%   initialCov   - Initial error covariance P (default: 1)
%
% Output:
%   y - Filtered signal
%
% Example:
%   y = filterKalman(data, 1e-4, 0.01);

    if nargin < 2, processNoise = 1e-5; end
    if nargin < 3, measNoise = 0.01; end
    if nargin < 5, initialCov = 1; end
    
    isRow = isrow(data);
    data = data(:);
    
    n = length(data);
    y = zeros(n, 1);
    
    if nargin < 4 || isempty(initialEst)
        x_est = data(1);
    else
        x_est = initialEst;
    end
    
    P = initialCov;
    Q = processNoise;
    R = measNoise;
    
    for i = 1:n
        % Prediction step
        x_pred = x_est;
        P_pred = P + Q;
        
        % Update step
        K = P_pred / (P_pred + R);
        x_est = x_pred + K * (data(i) - x_pred);
        P = (1 - K) * P_pred;
        
        y(i) = x_est;
    end
    
    if isRow, y = y'; end
end
