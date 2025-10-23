%% KALMAN FILTER CLASS
%% KalmanFilter - Apply 1D Kalman filter to signals
%%
%% Syntax:
%%   kf = KalmanFilter(processNoise, measNoise, initialEst, initialCov)
%%   y  = kf.apply(data)
%%
%% Properties:
%%   ProcessNoise - Process noise covariance Q (default: 1e-5)
%%   MeasNoise    - Measurement noise covariance R (default: 0.01)
%%   InitialEst   - Initial state estimate (default: data(1))
%%   InitialCov   - Initial error covariance P (default: 1)
%%
%% Methods:
%%   apply        - Apply Kalman filter to input data
%%   setProcessNoise - Update process noise Q
%%   setMeasNoise - Update measurement noise R
%%   setInitialEst - Update initial estimate
%%   setInitialCov - Update initial covariance P
%%
%% Example:
%%   kf = KalmanFilter(1e-4, 0.01);
%%   y = kf.apply(data);

classdef KalmanFilter
    properties
        ProcessNoise = 1e-5
        MeasNoise = 0.01
        InitialEst = []    % Will use first data point if empty
        InitialCov = 1
    end

    methods
        %% Constructor
        function obj = KalmanFilter(processNoise, measNoise, initialEst, initialCov)
            if nargin >= 1, obj.ProcessNoise = processNoise; end
            if nargin >= 2, obj.MeasNoise = measNoise; end
            if nargin >= 3, obj.InitialEst = initialEst; end
            if nargin >= 4, obj.InitialCov = initialCov; end
        end

        %% APPLY FILTER
        %% Apply the 1D Kalman filter to input data
        %%
        %% Syntax:
        %%   y = obj.apply(data)
        %%
        %% Inputs:
        %%   data - Input signal vector
        %%
        %% Output:
        %%   y - Filtered signal
        function y = apply(obj, data)
            isRow = isrow(data);
            data = data(:);

            n = length(data);
            y = zeros(n, 1);

            if isempty(obj.InitialEst)
                x_est = data(1);
            else
                x_est = obj.InitialEst;
            end

            P = obj.InitialCov;
            Q = obj.ProcessNoise;
            R = obj.MeasNoise;

            for i = 1:n
                %% Prediction step
                x_pred = x_est;
                P_pred = P + Q;

                %% Update step
                K = P_pred / (P_pred + R);
                x_est = x_pred + K * (data(i) - x_pred);
                P = (1 - K) * P_pred;

                y(i) = x_est;
            end

            if isRow, y = y'; end
        end

        %% SETPROCESSNOISE
        %% Update process noise covariance Q
        %%
        %% Syntax:
        %%   obj = obj.setProcessNoise(Q)
        function obj = setProcessNoise(obj, Q)
            obj.ProcessNoise = Q;
        end

        %% SETMEASNOISE
        %% Update measurement noise covariance R
        %%
        %% Syntax:
        %%   obj = obj.setMeasNoise(R)
        function obj = setMeasNoise(obj, R)
            obj.MeasNoise = R;
        end

        %% SETINITIALEST
        %% Update initial state estimate
        %%
        %% Syntax:
        %%   obj = obj.setInitialEst(x0)
        function obj = setInitialEst(obj, x0)
            obj.InitialEst = x0;
        end

        %% SETINITIALCOV
        %% Update initial error covariance P
        %%
        %% Syntax:
        %%   obj = obj.setInitialCov(P0)
        function obj = setInitialCov(obj, P0)
            obj.InitialCov = P0;
        end
    end
end
