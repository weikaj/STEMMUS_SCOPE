function theta = calculateTheta(subRoutine, theta_m, heat_term, gamma_hh, theta_s, theta_r, lamda, phi_s, alpha, n, m, mu, sigma, options)
    % get soil constants
    SoilConstants = io.getSoilConstants();
    hd = SoilConstants.hd;

    switch subRoutine
        if strcmp(options.modelType, 'VanGenuchten')
            case 0
                % heat_term = hh or hh + hh_frez
                theta = gamma_hh * theta_r + (theta_m - gamma_hh * theta_r) / (1 + abs(alpha * heat_term)^n)^m;
                if heat_term <= hd
                    theta = 0;
                end
            case 1
                % heat_term = hh or hh + hh_frez
                theta = theta_s * (heat_term / phi_s)^(-1 * lamda);
                if heat_term <= -1e7
                    theta = Theta_r;
                elseif heat_term >= phi_s
                    theta = theta_s;
                end
            case 2
                % heat_term = hh or hh + hh_frez
                theta = Theta_r + (theta_s - Theta_r) / (1 + abs(alpha * heat_term)^n)^m;
                
        elseif strcmp(options.modelType, 'Kosugi') 
            case 0
                    % heat_term = hh or hh + hh_frez
                    S_e = 0.5 * erfc((log(abs(heat_term) / mu)) / (sqrt(2) * sigma));
                    theta = gamma_hh * theta_r + S_e * (theta_m - gamma_hh *theta_r);
                    if heat_term <= hd
                        theta = 0;
                    end
                case 1
                    % heat_term = hh or hh + hh_frez
                    theta = theta_s * (heat_term / phi_s)^(-1 * lamda); % need to transform to kosugi
                    if heat_term <= -1e7
                        theta = theta_r;
                    elseif heat_term >= phi_s
                        theta = theta_s;
                    end
                case 2
                    % heat_term = hh or hh + hh_frez
                    S_e = 0.5 * erfc((log(abs(heat_term) / mu)) / (sqrt(2) * sigma));
                    theta = theta_r + S_e * (theta_s - theta_r);
        else
            error('Invalid model type. Choose either "VanGenuchten" or "Kosugi".');
        end
        
    end
end
