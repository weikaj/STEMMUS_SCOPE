function [SoilVariables, VanGenuchten, Kosugi] = updateSoilVariables(SoilVariables, VanGenuchten, SoilProperties, ModelSettings, i, j,Kosugi, options)

    % Get soil constants for StartInit
    SoilConstants = io.getSoilConstants();

    SoilVariables.POR(i) = SoilProperties.porosity(j);
    SoilVariables.Ks(i) = SoilProperties.SaturatedK(j);
    SoilVariables.Theta_qtz(i) = SoilVariables.Vol_qtz(j);
    SoilVariables.VPER(i, 1) = SoilVariables.VPERS(j);
    SoilVariables.VPER(i, 2) = SoilVariables.VPERSL(j);
    SoilVariables.VPER(i, 3) = SoilVariables.VPERC(j);
    SoilVariables.XSOC(i) = SoilVariables.VPERSOC(j);
    SoilVariables.XK(i) = SoilConstants.XK;

    if ModelSettings.SWCC == 1   % VG soil water retention model
        if strcmp(options.modelType, 'VanGenuchten')
            VanGenuchten.Theta_s(i) = SoilProperties.SaturatedMC(j);
            VanGenuchten.Theta_r(i) = SoilProperties.ResidualMC(j);
            VanGenuchten.Theta_f(i) = SoilProperties.fieldMC(j);
            VanGenuchten.Alpha(i) = SoilProperties.Coefficient_Alpha(j);
            VanGenuchten.n(i) = SoilProperties.Coefficient_n(j);
            VanGenuchten.m(i) = 1 - 1 ./ VanGenuchten.n(i);

            SoilVariables.XK(i) = SoilProperties.ResidualMC(j) + 0.02;
            SoilVariables.XWILT(i) = equations.van_genuchten(VanGenuchten.Theta_s(i), VanGenuchten.Theta_r(i), VanGenuchten.Alpha(i), -1.5e4, VanGenuchten.n(i), VanGenuchten.m(i));
            SoilVariables.XCAP(i) = equations.van_genuchten(VanGenuchten.Theta_s(i), VanGenuchten.Theta_r(i), VanGenuchten.Alpha(i), -336, VanGenuchten.n(i), VanGenuchten.m(i));
        elseif strcmp(options.modelType, 'Kosugi')
            Kosugi.Theta_s(i) = SoilProperties.SaturatedMC(j);
            Kosugi.Theta_r(i) = SoilProperties.ResidualMC(j);
            Kosugi.Theta_f(i) = SoilProperties.fieldMC(j);
            Kosugi.mu(i) = SoilProperties.Coefficient_mu(j);
            Kosugi.sigma(i) = SoilProperties.Coefficient_sigma(j);

            SoilVariables.XK(i) = SoilProperties.ResidualMC(j) + 0.02;
            SoilVariables.XWILT(i) = equations.kosugi(Kosugi.Theta_s(i), Kosugi.Theta_r(i), Kosugi.mu(i), -1.5e4, Kosugi.sigma(i));
            SoilVariables.XCAP(i) = equations.kosugi(Kosugi.Theta_s(i), Kosugi.Theta_r(i), Kosugi.mu(i), -336, Kosugi.sigma(i));
        else
            error('Invalid model type. Choose either "VanGenuchten" or "Kosugi".');
        end  
    else
        if strcmp(options.modelType, 'VanGenuchten')
            VanGenuchten.Theta_r(i) = SoilProperties.ResidualMC(j);
        elseif strcmp(options.modelType, 'Kosugi') 
            Kosugi.Theta_r(i) = SoilProperties.ResidualMC(j);
        else
            error('Invalid model type. Choose either "VanGenuchten" or "Kosugi".');
        end
            
        if SoilConstants.CHST == 0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
            SoilVariables.Phi_s(i) = SoilConstants.Phi_S(j);
            SoilVariables.Lamda(i) = SoilProperties.Coef_Lamda(j);
        else
            
            VanGenuchten.Theta_s(i) = 0.489 - 0.00126 * SoilVariables.VPER(i, 1) / (1 - SoilVariables.POR(i)) * 100;
            SoilVariables.Phi_s(i) = equations.calcPhi_s(SoilVariables.VPER(i, 1), SoilVariables.POR, SoilConstants.Phi_soc, SoilVariables.XSOC);
            SoilVariables.Lamda(i) = equations.calcLambda(SoilVariables.VPER(i, 3), SoilVariables.POR, SoilVariables.Lamda_soc, SoilVariables.XSOC);
        end
        SoilVariables.XWILT(i) = VanGenuchten.Theta_s(i) * ((-1.5e4) / SoilVariables.Phi_s(i))^(-1 * SoilVariables.Lamda(i));
    end
