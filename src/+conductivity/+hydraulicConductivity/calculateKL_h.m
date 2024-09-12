function kl_h = calculateKL_h(mu_w, se, Ks, m, sigma, options)

    % load Constants
    Constants = io.define_constants();

    MU_WN = Constants.MU_W0 * exp(Constants.MU1 / (8.31441 * (20 + 133.3)));
    CKT = MU_WN / mu_w;
    if se == 0
        kl_h = 0;
    else
        if strcmp(options.modelType, 'VanGenuchten')
            kl_h = CKT * Ks * (se^(0.5)) * (1 - (1 - se^(1 / m))^m)^2;
        elseif strcmp(options.modelType, 'Kosugi')
            
            kl_h = CKT * Ks * (se^(0.5)) * 0.5 * erfc((erfcinv(2 * Se) + sigma / sqrt(2)))^2;
        else
            error('Invalid model type. Choose either "VanGenuchten" or "Kosugi".');
        end
    end
    if kl_h <= 1E-20
        kl_h = 1E-20;
    end
    if isnan(kl_h) == 1
        kl_h = 0;
        warning('\n case "isnan(kl_h) == 1", set "kl_h = 0" \r');
    end
    if ~isreal(kl_h)
        warning('\n case "~isreal(kl_h)", dont know what to do! \r');
    end
end
