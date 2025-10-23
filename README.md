# Biomedical Signal Processing Library

A comprehensive collection of digital filter implementations for MATLAB **without requiring the Signal Processing Toolbox**. All filters are implemented from scratch using fundamental DSP principles.

## Features

- **Dual Interface**: Both functional and object-oriented APIs
- **IIR Filters**: Butterworth, Chebyshev Type 1/2, Elliptic designs
- **Filter Types**: Lowpass, Highpass, Bandpass, Bandstop
- **Other Filters**: Moving Average, Exponential Moving Average, Kalman
- **Zero-Phase Filtering**: Uses `filtfilt` implementation to eliminate phase distortion
- **No Toolbox Required**: Pure MATLAB implementation

---

## Quick Start

### Installation

```matlab
addpath('path/to/filters');
```

### Basic Usage

**Functional Interface** (simple, one-time use):
```matlab
% Lowpass filter at 50 Hz
y = filterLowpass(data, 1000, 50);

% Bandpass filter 10-100 Hz
y = filterBandpass(data, 1000, 10, 100);
```

**Class Interface** (reusable, object-oriented):
```matlab
% Create filter object
lpf = LowpassFilter(1000, 50);

% Apply to multiple signals
y1 = lpf.apply(data1);
y2 = lpf.apply(data2);

% Update parameters
lpf.setCutoff(30);
y3 = lpf.apply(data3);
```

---

## Available Filters

### IIR Filters
| Filter Type | Functional | Class |
|-------------|-----------|-------|
| **Lowpass** | `filterLowpass(data, fs, fc, ...)` | `LowpassFilter(fs, fc, ...)` |
| **Highpass** | `filterHighpass(data, fs, fc, ...)` | `HighpassFilter(fs, fc, ...)` |
| **Bandpass** | `filterBandpass(data, fs, fc1, fc2, ...)` | `BandpassFilter(fs, fc1, fc2, ...)` |
| **Bandstop** | `filterBandstop(data, fs, fc1, fc2, ...)` | `BandstopFilter(fs, fc1, fc2, ...)` |

**IIR Methods**: Butterworth (default), Chebyshev1, Chebyshev2, Elliptic

### Other Filters
| Filter Type | Functional | Class |
|-------------|-----------|-------|
| **Moving Average** | `filterMovingAverage(data, windowSize)` | `MovingAverageFilter(windowSize)` |
| **Exponential MA** | `filterMovingExp(data, alpha)` | `ExponentialMovingAverageFilter(alpha)` |
| **Kalman** | `filterKalman(data, Q, R, ...)` | `KalmanFilter(Q, R, ...)` |

---

## Usage Examples

### Remove Noise from Signal

```matlab
% Functional approach
fs = 1000;
cleanData = filterLowpass(noisyData, fs, 50, 4, IIRMethods.Butterworth);

% Class approach
lpf = LowpassFilter(fs, 50, 4, IIRMethods.Butterworth);
cleanData = lpf.apply(noisyData);
```

### ECG Processing Pipeline

```matlab
fs = 500;

% Option 1: Functional (quick and simple)
ecg = filterHighpass(ecg_raw, fs, 0.5, 2);      % Remove baseline
ecg = filterLowpass(ecg, fs, 40, 4);            % Remove HF noise
ecg = filterBandstop(ecg, fs, 58, 62, 4);       % Remove 60 Hz

% Option 2: Class (reusable pipeline)
hpf = HighpassFilter(fs, 0.5, 2);
lpf = LowpassFilter(fs, 40, 4);
notch = BandstopFilter(fs, 58, 62, 4);

ecg = notch.apply(lpf.apply(hpf.apply(ecg_raw)));
```

### Smooth Sensor Data

```matlab
% Simple smoothing
smoothed = filterMovingAverage(sensorData, 10);

% Responsive smoothing
smoothed = filterMovingExp(sensorData, 0.3);

% Optimal smoothing
smoothed = filterKalman(sensorData, 1e-5, 0.01);
```

### Real-time Processing with Classes

```matlab
% Create filters once
maf = MovingAverageFilter(10);
emaf = ExponentialMovingAverageFilter(0.3);

% Process streaming data
while acquiring
    newSample = getSensorData();
    smooth1 = maf.apply(newSample);
    smooth2 = emaf.apply(newSample);
    
    % Adapt filter based on conditions
    if isNoisy
        emaf.setAlpha(0.1);  % More smoothing
    else
        emaf.setAlpha(0.5);  % More responsive
    end
end
```

### Compare Filter Methods

```matlab
fs = 1000;
fc = 50;
order = 4;

% Try different IIR methods
y_butter = filterButterworth(data, fs, fc, order, 'low');
y_cheby1 = filterChebyshev1(data, fs, fc, order, 1, 'low');
y_cheby2 = filterChebyshev2(data, fs, fc, order, 40, 'low');
y_ellip = filterElliptic(data, fs, fc, order, 1, 40, 'low');

% Plot and compare
plot([data, y_butter, y_cheby1, y_cheby2, y_ellip]);
legend('Original', 'Butterworth', 'Cheby1', 'Cheby2', 'Elliptic');
```

---

## IIR Filter Methods Comparison

| Method | Passband | Stopband | Roll-off | Best For |
|--------|----------|----------|----------|----------|
| **Butterworth** | Flat | Monotonic | Moderate | General purpose, audio |
| **Chebyshev 1** | Ripple | Flat | Sharp | Sharp cutoff, ripple OK |
| **Chebyshev 2** | Flat | Ripple | Sharp | Flat passband needed |
| **Elliptic** | Ripple | Ripple | Sharpest | Steepest possible cutoff |

---

## When to Use Each Interface

### Use Functional Interface
✅ One-time filtering operations  
✅ Quick prototyping and testing  
✅ Simple scripts  
✅ No parameter changes needed  

```matlab
y = filterLowpass(data, 1000, 50);
```

### Use Class Interface
✅ Processing multiple signals with same settings  
✅ Dynamic parameter adjustment  
✅ Building filter pipelines  
✅ Object-oriented applications  

```matlab
lpf = LowpassFilter(1000, 50);
for i = 1:N
    output{i} = lpf.apply(input{i});
end
```

---

## Common Applications

### Audio Processing
```matlab
% Remove high-frequency noise
lpf = LowpassFilter(44100, 8000, 6, IIRMethods.Butterworth);
cleanAudio = lpf.apply(noisyAudio);
```

### Biomedical Signals
```matlab
% ECG: Remove baseline and powerline
hpf = HighpassFilter(500, 0.5, 2);
notch = BandstopFilter(500, 58, 62, 4);
cleanECG = notch.apply(hpf.apply(rawECG));
```

### Sensor Fusion
```matlab
% Kalman filter for optimal estimation
kf = KalmanFilter(1e-5, 0.01);
optimalEstimate = kf.apply(noisyMeasurements);
```

### Communications
```matlab
% Extract specific frequency band
bpf = BandpassFilter(10000, 1000, 3000, 6, IIRMethods.Elliptic);
signal = bpf.apply(receivedData);
```

---

## Best Practices

### Filter Order Selection
```matlab
order = 4;   % Good starting point
order = 6;   # Sharper cutoff
order = 8;   % Very sharp (watch stability)
```

### Cutoff Frequency Guidelines
```matlab
fc_max = fs / 2;        % Nyquist frequency
fc = 0.3 * fc_max;      % Safe choice (avoid aliasing)
```

### Handle Edge Effects
```matlab
% Pad data before filtering
pad = 100;
padded = [repmat(data(1), pad, 1); data; repmat(data(end), pad, 1)];
filtered = lpf.apply(padded);
result = filtered(pad+1:end-pad);
```

### Build Reusable Pipelines
```matlab
classdef MyProcessor
    properties
        HPF, LPF, Notch
    end
    
    methods
        function obj = MyProcessor(fs)
            obj.HPF = HighpassFilter(fs, 0.5);
            obj.LPF = LowpassFilter(fs, 40);
            obj.Notch = BandstopFilter(fs, 58, 62);
        end
        
        function clean = process(obj, raw)
            clean = obj.Notch.apply(obj.LPF.apply(obj.HPF.apply(raw)));
        end
    end
end
```

---

## Getting Help

All classes have embedded documentation:
```matlab
help LowpassFilter
help filterLowpass
help ExponentialMovingAverageFilter
```

Example:
```matlab
>> help LowpassFilter

  LowpassFilter - Apply lowpass filter to signals
  
  Syntax:
    lpf = LowpassFilter(fs, fc, order, method)
    y = lpf.apply(data)
  
  Properties:
    Fs      - Sampling frequency (Hz)
    Fc      - Cutoff frequency (Hz)
    Order   - Filter order
    Method  - IIRMethods enum
  
  Methods:
    apply      - Apply filter to data
    setCutoff  - Update cutoff frequency
    ...
```

---

## File Structure

```
filters/
├── FilterHelpers.m              % Core DSP functions
├── FilterTypes.m                % Filter type enumeration
├── IIRMethods.m                 % IIR method enumeration
│
├── Functional Interface/
│   ├── filterLowpass.m
│   ├── filterHighpass.m
│   ├── filterBandpass.m
│   ├── filterBandstop.m
│   ├── filterMovingAverage.m
│   ├── filterMovingExp.m
│   ├── filterKalman.m
│   ├── filterButterworth.m
│   ├── filterChebyshev1.m
│   ├── filterChebyshev2.m
│   └── filterElliptic.m
│
└── Class Interface/
    ├── LowpassFilter.m
    ├── HighpassFilter.m
    ├── BandpassFilter.m
    ├── BandstopFilter.m
    ├── MovingAverageFilter.m
    ├── ExponentialMovingAverageFilter.m
    ├── KalmanFilter.m
    ├── ButterworthFilter.m
    ├── Chebyshev1Filter.m
    ├── Chebyshev2Filter.m
    └── EllipticFilter.m
```

---

## Technical Notes

- **Zero-Phase Filtering**: All IIR filters use forward-backward filtering (`filtfilt`) to eliminate phase distortion
- **Bilinear Transform**: Analog prototypes converted to digital domain with frequency pre-warping
- **Stability**: Filters are designed for stability; avoid very high orders (>10) for bandpass/bandstop
- **No Toolbox**: Pure MATLAB implementation using only built-in functions

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Filter unstable | Reduce order or check cutoff frequencies |
| Not enough attenuation | Increase order or use Elliptic method |
| Signal distorted | Check cutoff frequency isn't too low |
| Slow performance | Reduce order or use Moving Average for simple smoothing |

---

## License

This library is provided as-is for educational and research purposes.

---

**Version**: Development (Experimental)  
**Last Updated**: 2025