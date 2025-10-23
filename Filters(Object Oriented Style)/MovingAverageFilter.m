%% MOVING AVERAGE FILTER CLASS
%% MovingAverageFilter - Apply moving average filter to signals
%%
%% Syntax:
%%   maf = MovingAverageFilter(windowSize)
%%   y   = maf.apply(data)
%%
%% Properties:
%%   WindowSize - Size of the moving average window (default: 5)
%%
%% Methods:
%%   apply       - Apply the moving average filter to input data
%%   setWindow   - Update window size
%%
%% Example:
%%   maf = MovingAverageFilter(10);
%%   y = maf.apply(data);

classdef MovingAverageFilter
    properties
        WindowSize = 5  % Size of the moving average window
    end

    methods
        %% Constructor
        function obj = MovingAverageFilter(windowSize)
            if nargin >= 1
                obj.WindowSize = windowSize;
            end
        end

        %% APPLY FILTER
        %% Apply the moving average filter to input data
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
            isRow = isrow(data);
            data = data(:);

            windowSize = round(obj.WindowSize);
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

        %% SETWINDOW
        %% Update moving average window size
        %%
        %% Syntax:
        %%   obj = obj.setWindow(windowSize)
        function obj = setWindow(obj, windowSize)
            obj.WindowSize = windowSize;
        end
    end
end
