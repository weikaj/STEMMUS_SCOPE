function [PSIs, rsss, rrr, rxx] = calc_rsoil(Rl, ModelSettings, SoilVariables, VanGenuchten, bbx, GroundwaterSettings, Kosugi, options)
    % load Constants
    Constants = io.define_constants();

    SMC = SoilVariables.Theta_LL(1:end - 1, 2);
    Se  = (SMC - VanGenuchten.Theta_r') ./ (VanGenuchten.Theta_s' - VanGenuchten.Theta_r');
    if strcmp(options.modelType, 'VanGenuchten')
        Ksoil = SoilVariables.Ks' .* Se.^Constants.l .* (1 - (1 - Se.^(1 ./ VanGenuchten.m')).^(VanGenuchten.m')).^2;
    elseif strcmp(options.modelType, 'Kosugi') 
        
        Ksoil = SoilVariables.Ks' .* (se^Constants.l) .* 0.5 * erfc((erfcinv(2 * Se) + Kosugi.sigma ./ sqrt(2))).^2;
    else
        error('Invalid model type. Choose either "VanGenuchten" or "Kosugi".');
    end   
        
    if ~GroundwaterSettings.GroundwaterCoupling % no Groundwater coupling
        
        if strcmp(options.modelType, 'VanGenuchten')
            PSIs = -((Se.^(-1 ./ VanGenuchten.m') - 1).^(1 ./ VanGenuchten.n')) ./ (VanGenuchten.Alpha * 100)' .* bbx;
        elseif strcmp(options.modelType, 'Kosugi')
            PSIs = Kosugi.mu * exp(sqrt(2) * Kosugi.sigma * erfcinv(Se)) .* bbx;
        else
        error('Invalid model type. Choose either "VanGenuchten" or "Kosugi".');
        end    
    else % Groundwater coupling is activated, added by Mostafa (see https://github.com/EcoExtreML/STEMMUS_SCOPE/issues/231)
        % Change PSIs with SoilVariables.hh to correct hydraulic head (matric potential + gravity) of the saturated layers
        for i = 1:ModelSettings.NL
            hh_lay(i) = mean([SoilVariables.hh(i), SoilVariables.hh(i + 1)]);
        end
        hh_lay = transpose(hh_lay);
        PSIs = hh_lay / 100 .* bbx; % unit conversion from cm to m (needed in the ebal calculations)
    end

    rsss = 1 ./ Ksoil ./ Rl ./ ModelSettings.DeltZ' / 2 / pi .* log((pi * Rl).^(-0.5) / (0.5 * 1e-3)) * 100 .* bbx;
    rxx  = 1 * 1e10 * ModelSettings.DeltZ' / 0.5 / 0.22 ./ Rl / 100 .* bbx; % Delta_z*j is the depth of the layer
    rrr  = 4 * 1e11 * (VanGenuchten.Theta_s' ./ SMC) ./ Rl ./ (ModelSettings.DeltZ' / 100) .* bbx;
