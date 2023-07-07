function theta_ii = calculateTheta_II(tt, xcap)

    % get model settings
    ModelSettings = io.getModelSettings();

    Tf1 = 273.15 + 1;
    Tf2 = 273.15 - 3;

    if hh <= -1e7
        theta_ii = 0;
    end
    if ModelSettings.SWCC == 1 && ModelSettings.SFCC ~= 1
        if tt + 273.15 > Tf1
            theta_ii = 0;
        elseif tt + 273.15 >= Tf2
            theta_ii = 0.5 * (1 - sin(pi() * (tt + 273.15 - 0.5 * Tf1 - 0.5 * Tf2) / (Tf1 - Tf2))) * xcap;
        else
            theta_ii = xcap;
        end
    end

end