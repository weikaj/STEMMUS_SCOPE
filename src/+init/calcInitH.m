function initH = calcInitH(Theta_s, Theta_r, initX, nParameter, mParameter, alphaParameter, mu, sigma, options)
    %{
        Calculate soil water potential (initH) using van Genuchten model.
        van Genuchten, M.T. (1980), A Closed-form Equation for Predicting the
        Hydraulic Conductivity of Unsaturated Soils. Soil Science Society of
        America Journal, 44: 892-898.
        https://doi.org/10.2136/sssaj1980.03615995004400050002x
        Kosugi, K. (1996), Lognormal distribution model for unsaturated soil hydraulic properties. Water Resour. Res., 32(9), 2697–2703.
        https://doi.org/10.1029/96WR01776

    %}
     

    if strcmp(options.modelType, 'VanGenuchten')
        initH = -(((Theta_s - Theta_r) / (initX - Theta_r))^(1 / mParameter) - 1)^(1 / nParameter) / alphaParameter;
    elseif strcmp(options.modelType, 'Kosugi')
        initH = exp(log(mu) + sqrt(2) * sigma * erfcinv((initX - Theta_r) / (Theta_s - Theta_r)));
    else
        error('Invalid model type. Choose either "VanGenuchten" or "Kosugi".');
    end
end
