function theta_m = calculateTheta_m(gamma_hh, VanGenuchten, POR, Kosugi, options)

    theta_s = VanGenuchten.Theta_s;
    theta_r = VanGenuchten.Theta_r;
    alpha = VanGenuchten.Alpha;
    n = VanGenuchten.n;
    m = VanGenuchten.m;
    mu = Kosugi.mu;
    sigma = Kosugi.sigma;
    
    if strcmp(options.modelType, 'VanGenuchten')
        theta_m = gamma_hh * theta_r + (theta_s - gamma_hh * theta_r) * (1 + abs(alpha * (-1))^n)^m;
    elseif strcmp(options.modelType, 'Kosugi')
        theta_m = gamma_hh * theta_r + 0.5 * (theta_s - gamma_hh *theta_r) * erfc(log(1 / mu) / sigma * sqrt(2));
    else
        error('Invalid model type. Choose either "VanGenuchten" or "Kosugi".');
    end  
    if theta_m >= POR
        theta_m = POR;
    elseif theta_m <= theta_s
        theta_m = theta_s;
    end
end
