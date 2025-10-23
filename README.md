# Digital Filters Library

A comprehensive collection of digital filter implementations for MATLAB **without requiring the Signal Processing Toolbox**. All filters are implemented from scratch using fundamental DSP principles.

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Filter Types](#filter-types)
- [IIR Filter Methods](#iir-filter-methods)
- [Usage Examples](#usage-examples)
- [Filter Comparison](#filter-comparison)
- [Technical Details](#technical-details)
- [API Reference](#api-reference)

---

## Overview

This library provides two main categories of filters:

### **IIR Filters (Infinite Impulse Response)**
- Lowpass, Highpass, Bandpass, Bandstop
- Methods: Butterworth, Chebyshev Type 1, Chebyshev Type 2, Elliptic
- Uses feedback for efficient sharp cutoffs
- Zero-phase filtering via `filtfilt` implementation

### **Other Filters**
- Moving Average (simple smoothing)
- Exponential Moving Average (weighted smoothing)
- Kalman Filter (optimal estimation)

---

## Installation

1. Clone or download the filter library
2. Add the folder to your MATLAB path:
```matlab
addpath('path/to/filters');
```

3. Ensure you have the enumeration files:
   - `FilterTypes.m`
   - `IIRMethods.m`

### File Structure
```
filters/
├── FilterHelpers.m          % Internal helper functions
├── FilterTypes.m            % Enumeration of filter types
├── IIRMethods.m            % Enumeration of IIR methods
├── filterLowpass.m
├── filterHighpass.m
├── filterBandpass.m
├── filterBandstop.m
├── filterMovingAverage.m
├── filterMovingExp.m
├── filterKalman.m
├── filterButterworth.m
├── filterChebyshev1.m
├── filterChebyshev2.m
└── filterElliptic.m
```

---

## Filter Types

### 1. **Lowpass Filter**
Passes low frequencies, attenuates high frequencies.

```matlab
y = filterLowpass(data, fs, fc, order, method);
```

**Use cases**: Remove high-frequency noise, smooth signals, anti-aliasing

---

### 2. **Highpass Filter**
Passes high frequencies, attenuates low frequencies.

```matlab
y = filterHighpass(data, fs, fc, order, method);
```

**Use cases**: Remove DC offset, eliminate low-frequency drift, baseline correction

---

### 3. **Bandpass Filter**
Passes frequencies within a specific band.

```matlab
y = filterBandpass(data, fs, fc1, fc2, order, method);
```

**Use cases**: Extract specific frequency bands, isolate signals of interest

---

### 4. **Bandstop (Notch) Filter**
Attenuates frequencies within a specific band.

```matlab
y = filterBandstop(data, fs, fc1, fc2, order, method);
```

**Use cases**: Remove power line interference (50/60 Hz), eliminate specific noise

---

### 5. **Moving Average Filter**
Simple averaging over a sliding window.

```matlab
y = filterMovingAverage(data, windowSize);
```

**Use cases**: Basic smoothing, noise reduction, trend extraction

---

### 6. **Exponential Moving Average**
Weighted average giving more importance to recent samples.

```matlab
y = filterMovingExp(data, alpha);
```

**Use cases**: Real-time smoothing, trend following, responsive filtering

---

### 7. **Kalman Filter**
Optimal recursive estimator for linear systems.

```matlab
y = filterKalman(data, processNoise, measNoise, initialEst, initialCov);
```

**Use cases**: Sensor fusion, state estimation, tracking, optimal noise reduction

---

## IIR Filter Methods

All IIR filters (lowpass, highpass, bandpass, bandstop) support four design methods:

### 1. **Butterworth** (`IIRMethods.Butterworth`)
- **Characteristics**: Maximally flat passband
- **Pros**: Smooth frequency response, no ripple
- **Cons**: Slow roll-off
- **Best for**: General-purpose filtering, audio applications

```matlab
y = filterLowpass(data, 1000, 50, 4, IIRMethods.Butterworth);
```

---

### 2. **Chebyshev Type 1** (`IIRMethods.Chebyshev1`)
- **Characteristics**: Ripple in passband, flat stopband
- **Pros**: Sharper roll-off than Butterworth
- **Cons**: Passband ripple
- **Parameter**: `ripple` - Passband ripple in dB (typical: 0.5-3 dB)
- **Best for**: When sharp cutoff is needed and passband ripple is acceptable

```matlab
y = filterChebyshev1(data, 1000, 50, 4, 1, 'low');  % 1 dB ripple
```

---

### 3. **Chebyshev Type 2** (`IIRMethods.Chebyshev2`)
- **Characteristics**: Flat passband, ripple in stopband
- **Pros**: No passband distortion, sharp roll-off
- **Cons**: Stopband ripple
- **Parameter**: `attenuation` - Stopband attenuation in dB (typical: 40-60 dB)
- **Best for**: When passband flatness is critical

```matlab
y = filterChebyshev2(data, 1000, 50, 4, 40, 'low');  % 40 dB stopband
```

---

### 4. **Elliptic (Cauer)** (`IIRMethods.Elliptic`)
- **Characteristics**: Ripple in both passband and stopband
- **Pros**: Steepest roll-off for given order
- **Cons**: Ripple in both bands, complex design
- **Parameters**: `ripple` and `attenuation`
- **Best for**: When the sharpest possible cutoff is needed

```matlab
y = filterElliptic(data, 1000, 50, 4, 1, 40, 'low');
```

---

## Usage Examples

### Basic Filtering

```matlab
% Load or generate data
fs = 1000;  % Sampling frequency
t = 0:1/fs:1;
data = sin(2*pi*10*t) + 0.5*randn(size(t));  % 10 Hz signal + noise

% Apply lowpass filter at 20 Hz
filtered = filterLowpass(data, fs, 20);

% Plot results
figure;
subplot(2,1,1); plot(t, data); title('Original');
subplot(2,1,2); plot(t, filtered); title('Filtered');
```

### Removing Power Line Noise

```matlab
% Remove 60 Hz interference with bandstop filter
fs = 1000;
cleaned = filterBandstop(data, fs, 58, 62, 4, IIRMethods.Butterworth);
```

### ECG Signal Processing

```matlab
% ECG typical processing pipeline
fs = 500;  % 500 Hz sampling

% 1. Remove baseline wander (< 0.5 Hz)
ecg_hp = filterHighpass(ecg, fs, 0.5, 2);

% 2. Remove high-frequency noise (> 40 Hz)
ecg_lp = filterLowpass(ecg_hp, fs, 40, 4);

% 3. Remove 60 Hz power line
ecg_clean = filterBandstop(ecg_lp, fs, 58, 62, 4);
```

### Smooth Sensor Data

```matlab
% Fast smoothing with moving average
smooth_fast = filterMovingAverage(sensor_data, 10);

% More responsive smoothing with exponential filter
smooth_responsive = filterMovingExp(sensor_data, 0.3);

% Optimal smoothing with Kalman filter
smooth_optimal = filterKalman(sensor_data, 1e-5, 0.01);
```

### Compare Filter Methods

```matlab
fs = 1000;
fc = 50;
order = 4;

% Design different filters
y_butter = filterButterworth(data, fs, fc, order, 'low');
y_cheby1 = filterChebyshev1(data, fs, fc, order, 1, 'low');
y_cheby2 = filterChebyshev2(data, fs, fc, order, 40, 'low');
y_ellip = filterElliptic(data, fs, fc, order, 1, 40, 'low');

% Plot comparison
figure;
plot(data, 'k'); hold on;
plot(y_butter, 'b');
plot(y_cheby1, 'r');
plot(y_cheby2, 'g');
plot(y_ellip, 'm');
legend('Original', 'Butterworth', 'Cheby1', 'Cheby2', 'Elliptic');
```

---

## Filter Comparison

### IIR Methods Comparison

| Method | Roll-off | Passband | Stopband | Complexity |
|--------|----------|----------|----------|------------|
| **Butterworth** | Moderate | Flat | Monotonic | Low |
| **Chebyshev 1** | Sharp | Ripple | Flat | Medium |
| **Chebyshev 2** | Sharp | Flat | Ripple | Medium |
| **Elliptic** | Sharpest | Ripple | Ripple | High |

### When to Use Each Filter Type

| Application | Recommended Filter | Reason |
|-------------|-------------------|--------|
| Audio processing | Butterworth | No passband ripple |
| Anti-aliasing | Butterworth/Cheby2 | Flat passband |
| Communications | Elliptic | Sharpest roll-off |
| ECG/EEG | Butterworth | Minimal distortion |
| Sensor smoothing | Moving Average/Kalman | Simple/Optimal |
| Real-time tracking | Exponential MA/Kalman | Low latency |

---

## Technical Details

### Implementation Notes

1. **Zero-Phase Filtering**: All IIR filters use `filtfilt` (forward-backward filtering) to eliminate phase distortion
2. **Bilinear Transform**: Analog prototypes are converted to digital using the bilinear transformation
3. **Frequency Pre-warping**: Cutoff frequencies are pre-warped to account for bilinear transform distortion
4. **No Toolbox Required**: All functions implemented from scratch using basic MATLAB

### Filter Design Process (IIR)

```
1. Analog Prototype Design
   ├── Butterworth: buttap(n)
   ├── Chebyshev1: cheb1ap(n, Rp)
   ├── Chebyshev2: cheb2ap(n, Rs)
   └── Elliptic: ellipap(n, Rp, Rs)
   
2. Frequency Transformation
   ├── Lowpass: lp2lp()
   ├── Highpass: lp2hp()
   ├── Bandpass: lp2bp()
   └── Bandstop: lp2bs()
   
3. Bilinear Transform (s → z)
   └── bilinear_zp(z, p, k)
   
4. Apply Filter
   └── filtfilt_manual(b, a, x)
```

### Stability Considerations

- IIR filters can become unstable for high orders (> 10-12)
- Bandpass/bandstop filters double the order
- All implementations check for valid cutoff frequencies
- Filters are normalized to prevent numerical issues

---

## API Reference

### Type-Specific Functions

#### `filterLowpass(data, fs, fc, order, method)`
**Parameters:**
- `data`: Input signal vector
- `fs`: Sampling frequency (Hz)
- `fc`: Cutoff frequency (Hz)
- `order`: Filter order (default: 4)
- `method`: IIRMethods enum (default: Butterworth)

**Returns:** Filtered signal

---

#### `filterHighpass(data, fs, fc, order, method)`
**Parameters:**
- `data`: Input signal vector
- `fs`: Sampling frequency (Hz)
- `fc`: Cutoff frequency (Hz)
- `order`: Filter order (default: 4)
- `method`: IIRMethods enum (default: Butterworth)

**Returns:** Filtered signal

---

#### `filterBandpass(data, fs, fc1, fc2, order, method)`
**Parameters:**
- `data`: Input signal vector
- `fs`: Sampling frequency (Hz)
- `fc1`: Lower cutoff frequency (Hz)
- `fc2`: Upper cutoff frequency (Hz)
- `order`: Filter order (default: 4)
- `method`: IIRMethods enum (default: Butterworth)

**Returns:** Filtered signal

---

#### `filterBandstop(data, fs, fc1, fc2, order, method)`
**Parameters:**
- `data`: Input signal vector
- `fs`: Sampling frequency (Hz)
- `fc1`: Lower cutoff frequency (Hz)
- `fc2`: Upper cutoff frequency (Hz)
- `order`: Filter order (default: 4)
- `method`: IIRMethods enum (default: Butterworth)

**Returns:** Filtered signal

---

#### `filterMovingAverage(data, windowSize)`
**Parameters:**
- `data`: Input signal vector
- `windowSize`: Number of samples to average (default: 5)

**Returns:** Smoothed signal

---

#### `filterMovingExp(data, alpha)`
**Parameters:**
- `data`: Input signal vector
- `alpha`: Smoothing factor 0-1 (default: 0.3)
  - Higher α = more responsive
  - Lower α = more smoothing

**Returns:** Smoothed signal

---

#### `filterKalman(data, processNoise, measNoise, initialEst, initialCov)`
**Parameters:**
- `data`: Input signal vector
- `processNoise`: Process noise covariance Q (default: 1e-5)
- `measNoise`: Measurement noise covariance R (default: 0.01)
- `initialEst`: Initial state estimate (default: data(1))
- `initialCov`: Initial error covariance P (default: 1)

**Returns:** Filtered signal

---

### Method-Specific Functions

#### `filterButterworth(data, fs, fc, order, filterType)`
Direct access to Butterworth filter for any type.

#### `filterChebyshev1(data, fs, fc, order, ripple, filterType)`
Direct access to Chebyshev Type 1 filter.

#### `filterChebyshev2(data, fs, fc, order, attenuation, filterType)`
Direct access to Chebyshev Type 2 filter.

#### `filterElliptic(data, fs, fc, order, ripple, attenuation, filterType)`
Direct access to Elliptic filter.

---

## Best Practices

### 1. **Choosing Filter Order**
```matlab
% Start with order 4, increase if needed
order = 4;  % Good starting point
order = 6;  % Sharper cutoff
order = 8;  % Very sharp (watch for stability)
```

### 2. **Cutoff Frequency Selection**
```matlab
% Rule of thumb: fc should be well below Nyquist
fc_max = fs / 2;  % Nyquist frequency
fc = 0.4 * fc_max;  % Safe choice
```

### 3. **Handling Edge Effects**
```matlab
% Pad data before filtering for better edge behavior
pad_length = 100;
data_padded = [repmat(data(1), pad_length, 1); data; repmat(data(end), pad_length, 1)];
filtered_padded = filterLowpass(data_padded, fs, fc);
filtered = filtered_padded(pad_length+1:end-pad_length);
```

### 4. **Real-Time vs Batch Processing**
```matlab
% Batch: Use filtfilt for zero-phase
y_batch = filterLowpass(data, fs, fc);  % Zero-phase

% Real-time: Use single-pass filter
% (requires modification to use filter() instead of filtfilt())
```

---

## Troubleshooting

### Issue: Filter is unstable
**Solution**: Reduce filter order or check cutoff frequencies

### Issue: Not enough attenuation
**Solution**: Increase filter order or use Elliptic method

### Issue: Signal is distorted
**Solution**: Check if cutoff frequency is too low, or reduce order

### Issue: Slow performance
**Solution**: Use Moving Average for simple smoothing, reduce filter order

---

## License

This library is provided as-is for educational and research purposes.

## Contributing

Contributions are welcome! Please ensure:
- No Signal Processing Toolbox dependencies
- Clear documentation
- Usage examples
- Proper error handling

## References

1. Oppenheim, A. V., & Schafer, R. W. (2009). *Discrete-Time Signal Processing*
2. Parks, T. W., & Burrus, C. S. (1987). *Digital Filter Design*
3. Antoniou, A. (2006). *Digital Signal Processing: Signals, Systems, and Filters*

---

**Version**: 1.0  
**Last Updated**: 2025