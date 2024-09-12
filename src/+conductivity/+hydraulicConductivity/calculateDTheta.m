function dtheta = calculateDTheta(subRoutine, heat_term, theta_s, theta_r, theta_m, gamma_hh, theta_ll, theta_l, theta_uu, theta_u, hh, h, hh_frez, h_frez, phi_s, lamda, alpha, n, m, mu, sigma, options)

    % get soil constants
    SoilConstants = io.getSoilConstants();

    switch subRoutine
        if strcmp(options.modelType, 'VanGenuchten')
        
            case 0
                % for DTheta_LLh, heat_term = hh
                % for DTheta_UUh, heat_term = hh + hh_frez
                A = (-theta_r) / (abs(heat_term) * log(abs(SoilConstants.hd / SoilConstants.hm))) * (1 - (1 + abs(alpha * heat_term)^n)^(-m));
                B = alpha * n * m * (theta_m - gamma_hh * theta_r);
                C = ((1 + abs(alpha * heat_term)^n)^(-m - 1));
                D = (abs(alpha * heat_term)^(n - 1));
                dtheta = A -  B * C * D;
                if (hh + hh_frez) <= SoilConstants.hd
                    dtheta = 0;
                end
            case 1
                % heat_term = hh or  hh + hh_frez
                A = (theta_m - theta_r) * alpha * n;
                B =  abs(alpha * heat_term)^(n - 1) * (-m);
                C = (1 + abs(alpha * heat_term)^n)^(-m - 1);
                dtheta = A * B * C;
            case 2
                A = theta_ll - theta_l;
                B = hh + hh_frez - h - h_frez;
                dtheta = A / B;
            case 3
                A = theta_uu - theta_u;
                B = hh - h;
                dtheta = A / B;
            case 4
                dtheta = theta_s / phi_s * (hh / phi_s)^(-1 * lamda - 1);
            case 5
                % this case differs with case 1 only regarding `theta_m` and `theta_s`
                % see issue 181, item 7
                % heat_term = hh or  hh + hh_frez
                A = (theta_s - theta_r) * alpha * n;
                B =  abs(alpha * heat_term)^(n - 1) * (-m);
                C = (1 + abs(alpha * heat_term)^n)^(-m - 1);
                dtheta = A * B * C;
                
                
        elseif strcmp(options.modelType, 'Kosugi')      
            % Define objective function to solve for m given sigma
            function f = sigma_objective(m)
                f = abs(sigma^2 - (1-m) * log((2^(1/m) - 1) / m));
            end

            % Solve for m using optimization within the range [0, 1]
            options = optimset('TolX', 1e-12);
            m = fminbnd(@sigma_objective, 0, 1, options);

            % Calculate alpha using h_m (theta_m in this context)
            h_0 = mu / exp(sigma^2);
            alpha = m^(1-m) / h_0;

            % Calculate n using the relationship with m
            n = 1 / (1 - m);   
            
            case 0
                % for DTheta_LLh, heat_term = hh
                % for DTheta_UUh, heat_term = hh + hh_frez
                A = (-theta_r) / (abs(heat_term) * log(abs(SoilConstants.hd / SoilConstants.hm))) * (1 - (1 + abs(alpha * heat_term)^n)^(-m));
                B = alpha * n * m * (theta_m - gamma_hh * theta_r);
                C = ((1 + abs(alpha * heat_term)^n)^(-m - 1));
                D = (abs(alpha * heat_term)^(n - 1));
                dtheta = A -  B * C * D;
                if (hh + hh_frez) <= SoilConstants.hd
                    dtheta = 0;
                end
            case 1
                % heat_term = hh or  hh + hh_frez
                A = (theta_m - theta_r) * alpha * n;
                B =  abs(alpha * heat_term)^(n - 1) * (-m);
                C = (1 + abs(alpha * heat_term)^n)^(-m - 1);
                dtheta = A * B * C;
            case 2
                A = theta_ll - theta_l;
                B = hh + hh_frez - h - h_frez;
                dtheta = A / B;
            case 3
                A = theta_uu - theta_u;
                B = hh - h;
                dtheta = A / B;
            case 4
                dtheta = theta_s / phi_s * (hh / phi_s)^(-1 * lamda - 1);
            case 5
                % this case differs with case 1 only regarding `theta_m` and `theta_s`
                % see issue 181, item 7
                % heat_term = hh or  hh + hh_frez
                A = (theta_s - theta_r) * alpha * n;
                B =  abs(alpha * heat_term)^(n - 1) * (-m);
                C = (1 + abs(alpha * heat_term)^n)^(-m - 1);
                dtheta = A * B * C;
        else
            error('Invalid model type. Choose either "VanGenuchten" or "Kosugi".');
        end     
    end
end
