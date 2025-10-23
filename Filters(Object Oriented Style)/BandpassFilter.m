%% BANDPASS FILTER CLASS
%% BandpassFilter - Apply bandpass IIR filters to signals
%%
%% Syntax:
%%   bp = BandpassFilter(fs, fc1, fc2, order, method)
%%   y = bp.apply(data)
%%
%% Properties:
%%   Fs     - Sampling frequency
%%   Fc1    - Lower cutoff frequency
%%   Fc2    - Upper cutoff frequency
%%   Order  - Filter order (default: 4)
%%   Method - IIR method (default: Butterworth)
%%
%% Methods:
%%   apply      - Apply filter to input data
%%   setCutoff  - Update cutoff frequencies
%%   setOrder   - Update filter order
%%   setMethod  - Update filter method
%%
%% Example:
%%   bp = BandpassFilter(1000, 10, 100, 4, IIRMethods.Butterworth);
%%   y = bp.apply(data);

classdef BandpassFilter
    properties
        Fs          % Sampling frequency
        Fc1         % Lower cutoff frequency
        Fc2         % Upper cutoff frequency
        Order = 4
        Method = IIRMethods.Butterworth
    end

    methods
        %% Constructor
        function obj = BandpassFilter(fs, fc1, fc2, order, method)
            if nargin >= 1, obj.Fs = fs; end
            if nargin >= 2, obj.Fc1 = fc1; end
            if nargin >= 3, obj.Fc2 = fc2; end
            if nargin >= 4, obj.Order = order; end
            if nargin >= 5, obj.Method = method; end
        end

        %% APPLY FILTER
        %% Apply the bandpass filter to input data
        %%
        %% Syntax:
        %%   y = obj.apply(data)
        %%
        %% Inputs:
        %%   data - Vector containing the signal to filter
        %%
        %% Output:
        %%   y - Filtered signal
        %%
        %% Example:
        %%   y = bp.apply(data);
        function y = apply(obj, data)
            validateInputs(data, obj.Fs, [obj.Fc1, obj.Fc2]);

            isRow = isrow(data);
            data = data(:);

            Wn = [obj.Fc1, obj.Fc2] / (obj.Fs/2);
            [b, a] = designIIRFilter(obj.Order, Wn, 'bandpass', obj.Method);

            y = filtfilt_manual(b, a, data);

            if isRow, y = y'; end
        end

        %% SETCUTOFF
        %% Update lower and upper cutoff frequencies
        %%
        %% Syntax:
        %%   obj = obj.setCutoff(fc1, fc2)
        function obj = setCutoff(obj, fc1, fc2)
            obj.Fc1 = fc1;
            obj.Fc2 = fc2;
        end

        %% SETORDER
        %% Update filter order
        %%
        %% Syntax:
        %%   obj = obj.setOrder(order)
        function obj = setOrder(obj, order)
            obj.Order = order;
        end

        %% SETMETHOD
        %% Update filter method
        %%
        %% Syntax:
        %%   obj = obj.setMethod(method)
        function obj = setMethod(obj, method)
            obj.Method = method;
        end
    end
end
