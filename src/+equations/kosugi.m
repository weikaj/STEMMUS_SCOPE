% -*- coding: utf-8 -*-
function volumetricWaterContent = kosugi(Theta_s, Theta_r,  mu, hParameter, sigma)
    %{
        This function calculates the volumetric water content using the Kosugi model.
   
        
        Kosugi model:
        Kosugi K (1996) Lognormal distribution model for unsaturated soil hydraulic properties.
        Water Resour. Res., 32(9), 2697–2703.
    %}

    
        % Kosugi model calculation
        volumetricWaterContent = Theta_r + (Theta_s - Theta_r) .* 0.5 .* erfc(log(abs(hParameter) ./ mu) ./ (sqrt(2) * sigma));
end
