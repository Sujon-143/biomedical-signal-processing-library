%% EXPONENTIAL MOVING AVERAGE FILTER CLASS
%% ExponentialMovingAverageFilter - Apply exponential moving average filter to signals
%%
%% Syntax:
%%   emaf = ExponentialMovingAverageFilter(alpha)
%%   y    = emaf.apply(data)
%%
%% Properties:
%%   Alpha - Smoothing factor between 0 and 1 (default: 0.3)
%%           Higher values = more responsive, lower values = more smoothing
%%
%% Methods:
%%   apply      - Apply the exponential moving average filter to input data
%%   setAlpha   - Update the smoothing factor
%%
%% Example:
%%   emaf = ExponentialMovingAverageFilter(0.2);
%%   y = emaf.apply(data);

classdef ExponentialMovingAverageFilter
    properties
        Alpha = 0.3  % Smoothing factor
    end

    methods
        %% Constructor
        function obj = ExponentialMovingAverageFilter(alpha)
            if nargin >= 1
                if alpha <= 0 || alpha > 1
                    error('Alpha must be between 0 and 1');
                end
                obj.Alpha = alpha;
            end
        end

        %% APPLY FILTER
        %% Apply the exponential moving average filter to input data
        %%
        %% Syntax:
        %%   y = obj.apply(data)
        %%
        %% Inputs:
        %%   data - Vector containing the signal to filter
        %%
        %% Output:
        %%   y - Filtered signal
        function y = apply(obj, data)
            if obj.Alpha <= 0 || obj.Alpha > 1
                error('Alpha must be between 0 and 1');
            end

            isRow = isrow(data);
            data = data(:);

            n = length(data);
            y = zeros(n, 1);
            y(1) = data(1);

            for i = 2:n
                y(i) = obj.Alpha * data(i) + (1 - obj.Alpha) * y(i-1);
            end

            if isRow, y = y'; end
        end

        %% SETALPHA
        %% Update smoothing factor
        %%
        %% Syntax:
        %%   obj = obj.setAlpha(alpha)
        function obj = setAlpha(obj, alpha)
            if alpha <= 0 || alpha > 1
                error('Alpha must be between 0 and 1');
            end
            obj.Alpha = alpha;
        end
    end
end
