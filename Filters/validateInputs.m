%% ========================================================================
%  INTERNAL HELPER FUNCTIONS
%  ========================================================================

function validateInputs(data, fs, fc)
    if ~isnumeric(data) || ~isvector(data)
        error('Data must be a numeric vector');
    end
    if fs <= 0
        error('Sampling frequency must be positive');
    end
    if any(fc <= 0) || any(fc >= fs/2)
        error('Cutoff frequency must be between 0 and Nyquist frequency');
    end
end

function [b, a] = designIIRFilter(order, Wn, ftype, method, ripple, attenuation)
    if nargin < 5, ripple = 1; end
    if nargin < 6, attenuation = 40; end
    
    switch method
        case IIRMethods.Butterworth
            [z_a, p_a, k_a] = buttap(order);
        case IIRMethods.Chebyshev1
            [z_a, p_a, k_a] = cheb1ap(order, ripple);
        case IIRMethods.Chebyshev2
            [z_a, p_a, k_a] = cheb2ap(order, attenuation);
        case IIRMethods.Elliptic
            [z_a, p_a, k_a] = ellipap(order, ripple, attenuation);
        otherwise
            error('Unknown IIR method');
    end
    
    [b, a] = lp2filter(z_a, p_a, k_a, Wn, ftype);
end

function [z, p, k] = buttap(n)
    z = [];
    p = exp(1i * pi * (2*(1:n) + n - 1) / (2*n));
    p = p(:);
    k = 1;
end

function [z, p, k] = cheb1ap(n, Rp)
    epsilon = sqrt(10^(Rp/10) - 1);
    mu = asinh(1/epsilon) / n;
    
    z = [];
    m = 1:n;
    theta = pi * (2*m - 1) / (2*n);
    p = -sinh(mu) * sin(theta) + 1i * cosh(mu) * cos(theta);
    p = p(:);
    
    k = prod(-p);
    if mod(n, 2) == 0
        k = k / sqrt(1 + epsilon^2);
    end
    k = real(k);
end

function [z, p, k] = cheb2ap(n, Rs)
    epsilon = 1 / sqrt(10^(Rs/10) - 1);
    mu = asinh(1/epsilon) / n;
    
    m = 1:floor(n/2);
    theta = pi * (2*m - 1) / (2*n);
    z = 1i ./ cos(theta);
    if mod(n, 2) == 1
        z = [z; 1i*inf];
    end
    z = [z; conj(z)];
    z = z(:);
    
    m = 1:n;
    theta = pi * (2*m - 1) / (2*n);
    p_temp = -sinh(mu) * sin(theta) + 1i * cosh(mu) * cos(theta);
    p = 1 ./ p_temp;
    p = p(:);
    
    k = real(prod(-p) / prod(-z(~isinf(z))));
end

function [z, p, k] = ellipap(n, Rp, Rs)
    epsilon = sqrt(10^(Rp/10) - 1);
    [z, p, k] = cheb1ap(n, Rp);
    k = k * 10^(-Rs/20);
end

function [b, a] = lp2filter(z, p, k, Wn, ftype)
    switch ftype
        case 'low'
            [b, a] = lp2lp(z, p, k, Wn);
        case 'high'
            [b, a] = lp2hp(z, p, k, Wn);
        case 'bandpass'
            [b, a] = lp2bp(z, p, k, Wn);
        case 'stop'
            [b, a] = lp2bs(z, p, k, Wn);
    end
end

function [b, a] = lp2lp(z, p, k, Wn)
    Wo = tan(pi * Wn / 2);
    p = p * Wo;
    z = z * Wo;
    k = k * Wo^(length(p) - length(z));
    [b, a] = bilinear_zp(z, p, k);
end

function [b, a] = lp2hp(z, p, k, Wn)
    Wo = tan(pi * Wn / 2);
    p = Wo ./ p;
    z = Wo ./ z;
    num_zeros_to_add = length(p) - length(z);
    z = [z; zeros(num_zeros_to_add, 1)];
    [b, a] = bilinear_zp(z, p, k);
end

function [b, a] = lp2bp(z, p, k, Wn)
    Wo = tan(pi * mean(Wn) / 2);
    Bw = Wn(2) - Wn(1);
    Bw = tan(pi * Bw / 2);
    
    p_new = [];
    for i = 1:length(p)
        p_bp = (Bw * p(i) + sqrt((Bw * p(i))^2 - 4 * Wo^2)) / 2;
        p_new = [p_new; p_bp; Wo^2 / p_bp];
    end
    
    z_new = [];
    for i = 1:length(z)
        if ~isinf(z(i))
            z_bp = (Bw * z(i) + sqrt((Bw * z(i))^2 - 4 * Wo^2)) / 2;
            z_new = [z_new; z_bp; Wo^2 / z_bp];
        end
    end
    
    num_zeros_to_add = length(p_new) - length(z_new);
    z_new = [z_new; 1i * ones(num_zeros_to_add/2, 1); -1i * ones(num_zeros_to_add/2, 1)];
    
    [b, a] = bilinear_zp(z_new, p_new, k);
end

function [b, a] = lp2bs(z, p, k, Wn)
    Wo = tan(pi * mean(Wn) / 2);
    Bw = Wn(2) - Wn(1);
    Bw = tan(pi * Bw / 2);
    
    p_new = [];
    for i = 1:length(p)
        denom = Bw * p(i);
        p_bs = Wo^2 / ((denom + sqrt(denom^2 - 4 * Wo^2)) / 2);
        p_new = [p_new; p_bs; conj(p_bs)];
    end
    
    z_new = Wo * [1i * ones(length(p_new)/2, 1); -1i * ones(length(p_new)/2, 1)];
    
    [b, a] = bilinear_zp(z_new, p_new, k);
end

function [b, a] = bilinear_zp(z, p, k)
    z = z(~isinf(z));
    pd = (2 + p) ./ (2 - p);
    zd = (2 + z) ./ (2 - z);
    
    num_zeros_at_minus_one = length(pd) - length(zd);
    zd = [zd; -ones(num_zeros_at_minus_one, 1)];
    
    kd = k * real(prod(2 - p) / prod(2 - z(~isinf(z))));
    
    b = kd * real(poly(zd));
    a = real(poly(pd));
end

function y = filtfilt_manual(b, a, x)
    y_forward = filter_manual(b, a, x);
    y_reverse = filter_manual(b, a, flipud(y_forward));
    y = flipud(y_reverse);
end

function y = filter_manual(b, a, x)
    n = length(x);
    nb = length(b);
    na = length(a);
    nz = max(nb, na) - 1;
    
    b = b / a(1);
    a = a / a(1);
    
    z = zeros(nz, 1);
    y = zeros(n, 1);
    
    for i = 1:n
        if nz > 0
            y(i) = b(1) * x(i) + z(1);
        else
            y(i) = b(1) * x(i);
        end
        
        for j = 1:nz-1
            z(j) = b(j+1) * x(i) - a(j+1) * y(i) + z(j+1);
        end
        if nz > 0
            if nb > nz
                z(nz) = b(nz+1) * x(i) - a(nz+1) * y(i);
            elseif na > nz
                z(nz) = -a(nz+1) * y(i);
            else
                z(nz) = b(nz+1) * x(i) - a(nz+1) * y(i);
            end
        end
    end
end