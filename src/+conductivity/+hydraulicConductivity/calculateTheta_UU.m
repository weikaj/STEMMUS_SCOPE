function theta_uu = calculateTheta_UU(theta_m, gamma_hh, SoilVariables, VanGenuchten, ModelSettings, Kosugi, options)

    hh = SoilVariables.hh;
    phi_s = SoilVariables.Phi_s;
    lamda = SoilVariables.Lamda;

    theta_s = VanGenuchten.Theta_s;
    theta_r = VanGenuchten.Theta_r;
    alpha = VanGenuchten.Alpha;
    n = VanGenuchten.n;
    m = VanGenuchten.m;
    mu = Kosugi.mu;
    sigma = Kosugi.sigma;
    
    % calculate theta_uu
    if ModelSettings.SWCC == 1
        if ModelSettings.SFCC == 1
            if hh >= -1
                theta_uu = theta_s;
            elseif ModelSettings.Thmrlefc
                if gamma_hh == 0
                    theta_uu = 0;
                else
                    subRoutine = 0;
                    theta_uu = conductivity.hydraulicConductivity.calculateTheta(subRoutine, theta_m, hh, gamma_hh, theta_s, theta_r, lamda, phi_s, alpha, n, m, mu, sigma, options);
                end
            end
        else
            if hh >= -1e-6
                theta_uu = theta_s;
            elseif hh <= -1e7
                theta_uu = theta_r;
            else
                subRoutine = 2;
                theta_uu = conductivity.hydraulicConductivity.calculateTheta(subRoutine, theta_m, hh, gamma_hh, theta_s, theta_r, lamda, phi_s, alpha, n, m, mu, sigma, options);
            end
        end
    else
        subRoutine = 1;
        theta_uu = conductivity.hydraulicConductivity.calculateTheta(subRoutine, theta_m, hh, gamma_hh, theta_s, theta_r, lamda, phi_s, alpha, n, m, mu, sigma, options);
    end
end
