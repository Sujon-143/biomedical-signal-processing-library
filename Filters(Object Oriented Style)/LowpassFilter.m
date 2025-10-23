%% LOWPASS FILTER CLASS
%% LowpassFilter - Apply lowpass IIR filters to signals
%%
%% Syntax:
%%   lp = LowpassFilter(fs, fc, order, method)
%%   y  = lp.apply(data)
%%
%% Properties:
%%   Fs     - Sampling frequency
%%   Fc     - Cutoff frequency
%%   Order  - Filter order (default: 4)
%%   Method - IIRMethods enum (default: Butterworth)
%%
%% Methods:
%%   apply      - Apply filter to input data
%%   setCutoff  - Update cutoff frequency
%%   setOrder   - Update filter order
%%   setMethod  - Update filter method
%%
%% Example:
%%   lp = LowpassFilter(1000, 50, 6, IIRMethods.Butterworth);
%%   y = lp.apply(data);

classdef LowpassFilter
    properties
        Fs = 1000               % Sampling frequency
        Fc = 50                 % Cutoff frequency
        Order = 4               % Filter order
        Method = IIRMethods.Butterworth  % IIR method
    end

    methods
        %% Constructor
        function obj = LowpassFilter(fs, fc, order, method)
            if nargin >= 1, obj.Fs = fs; end
            if nargin >= 2, obj.Fc = fc; end
            if nargin >= 3, obj.Order = order; end
            if nargin >= 4, obj.Method = method; end
        end

        %% APPLY FILTER
        %% Apply the lowpass filter to input data
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
            validateInputs(data, obj.Fs, obj.Fc);

            isRow = isrow(data);
            data = data(:);

            Wn = obj.Fc / (obj.Fs/2);
            [b, a] = designIIRFilter(obj.Order, Wn, 'low', obj.Method);

            y = filtfilt_manual(b, a, data);

            if isRow, y = y'; end
        end

        %% SETCUTOFF
        %% Update cutoff frequency
        %%
        %% Syntax:
        %%   obj = obj.setCutoff(fc)
        function obj = setCutoff(obj, fc)
            obj.Fc = fc;
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
        %% Update IIR method
        %%
        %% Syntax:
        %%   obj = obj.setMethod(method)
        function obj = setMethod(obj, method)
            obj.Method = method;
        end
    end
end
