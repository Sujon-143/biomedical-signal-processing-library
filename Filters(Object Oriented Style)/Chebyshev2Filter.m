%% CHEBYSHEV TYPE II FILTER CLASS
%% Chebyshev2Filter - Apply Chebyshev Type II IIR filters (low, high, bandpass, bandstop)
%%
%% Syntax:
%%   cf2 = Chebyshev2Filter(fs, fc, order, attenuation, filterType)
%%   y   = cf2.apply(data)
%%
%% Properties:
%%   Fs          - Sampling frequency
%%   Fc          - Cutoff frequency (scalar) or [fc1 fc2] for bandpass/bandstop
%%   Order       - Filter order (default: 4)
%%   Attenuation - Stopband attenuation in dB (default: 40)
%%   FilterType  - 'low', 'high', 'bandpass', 'stop' (default: 'low')
%%
%% Methods:
%%   apply        - Apply filter to input data
%%   setCutoff    - Update cutoff frequency/frequencies
%%   setOrder     - Update filter order
%%   setAttenuation - Update stopband attenuation
%%   setType      - Update filter type
%%
%% Example:
%%   cf2 = Chebyshev2Filter(1000, 50, 4, 40, 'low');
%%   y = cf2.apply(data);

classdef Chebyshev2Filter
    properties
        Fs = 1000           % Sampling frequency
        Fc = 50             % Cutoff frequency(s)
        Order = 4           % Filter order
        Attenuation = 40    % Stopband attenuation in dB
        FilterType = 'low'  % 'low', 'high', 'bandpass', 'stop'
    end

    methods
        %% Constructor
        function obj = Chebyshev2Filter(fs, fc, order, attenuation, filterType)
            if nargin >= 1, obj.Fs = fs; end
            if nargin >= 2, obj.Fc = fc; end
            if nargin >= 3, obj.Order = order; end
            if nargin >= 4, obj.Attenuation = attenuation; end
            if nargin >= 5, obj.FilterType = filterType; end
        end

        %% APPLY FILTER
        %% Apply the Chebyshev Type II filter to input data
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
        %%   y = cf2.apply(data);
        function y = apply(obj, data)
            isRow = isrow(data);
            data = data(:);

            % Normalize cutoff frequencies
            Wn = obj.Fc / (obj.Fs/2);

            % Design filter
            [b, a] = designIIRFilter(obj.Order, Wn, obj.FilterType, IIRMethods.Chebyshev2, [], obj.Attenuation);

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

        %% SETATTENUATION
        %% Update stopband attenuation in dB
        %%
        %% Syntax:
        %%   obj = obj.setAttenuation(attenuation)
        function obj = setAttenuation(obj, attenuation)
            obj.Attenuation = attenuation;
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
