%% BUTTERWORTH FILTER CLASS
%% ButterworthFilter - Apply Butterworth IIR filters (low, high, bandpass, bandstop)
%%
%% Syntax:
%%   bf = ButterworthFilter(fs, fc, order, filterType)
%%   y  = bf.apply(data)
%%
%% Properties:
%%   Fs         - Sampling frequency
%%   Fc         - Cutoff frequency (scalar) or [fc1 fc2] for bandpass/bandstop
%%   Order      - Filter order (default: 4)
%%   FilterType - 'low', 'high', 'bandpass', 'stop' (default: 'low')
%%
%% Methods:
%%   apply       - Apply filter to input data
%%   setCutoff   - Update cutoff frequency/frequencies
%%   setOrder    - Update filter order
%%   setType     - Update filter type
%%
%% Example:
%%   bf = ButterworthFilter(1000, 50, 6, 'low');
%%   y = bf.apply(data);

classdef ButterworthFilter
    properties
        Fs = 1000          % Sampling frequency
        Fc = 50            % Cutoff frequency(s)
        Order = 4          % Filter order
        FilterType = 'low' % 'low', 'high', 'bandpass', 'stop'
    end

    methods
        %% Constructor
        function obj = ButterworthFilter(fs, fc, order, filterType)
            if nargin >= 1, obj.Fs = fs; end
            if nargin >= 2, obj.Fc = fc; end
            if nargin >= 3, obj.Order = order; end
            if nargin >= 4, obj.FilterType = filterType; end
        end

        %% APPLY FILTER
        %% Apply the Butterworth filter to input data
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
        %%   y = bf.apply(data);
        function y = apply(obj, data)
            isRow = isrow(data);
            data = data(:);

            % Normalize cutoff frequencies
            Wn = obj.Fc / (obj.Fs/2);

            % Design filter
            [b, a] = designIIRFilter(obj.Order, Wn, obj.FilterType, IIRMethods.Butterworth);

            % Apply filter
            y = filtfilt_manual(b, a, data);

            % Return same shape as input
            if isRow, y = y'; end
        end

        %% SETCUTOFF
        %% Update cutoff frequency/frequencies
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

        %% SETTYPE
        %% Update filter type
        %%
        %% Syntax:
        %%   obj = obj.setType(filterType)
        function obj = setType(obj, filterType)
            obj.FilterType = filterType;
        end
    end
end
