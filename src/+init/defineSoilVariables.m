function SoilVariables = defineSoilVariables(InitialValues, SoilProperties, VanGenuchten, Kosugi, options)
    %{
        Create a SoilVariables structure and define some variables.
        SoilVariables is input for initializing Temperature, Matric potential
        and soil air pressure.
    %}

    % Create a SoilVariables structure
    SoilVariables = struct();

    % Add initial values to SoilVariables
    soil_fields = {
                   'P_g', 'P_gg', 'h', 'T', 'TT', 'h_frez', 'Theta_L', ...
                   'Theta_LL', 'Theta_V', 'Theta_g', 'Se', 'KL_h', ...
                   'DTheta_LLh', 'KfL_T', 'Theta_II', 'Theta_I', ...
                   'Theta_UU', 'Theta_U', 'TT_CRIT', 'KfL_h', 'DTheta_UUh', ...
                   'Ratio_ice'
                  };
    for field = soil_fields
        SoilVariables.(field{1}) = InitialValues.(field{1});
    end

    % Calculate some of SoilVariables
    if strcmp(options.modelType, 'VanGenuchten')
        SoilVariables.XK = VanGenuchten.Theta_r + 0.02; % 0.11 This is for silt loam; For sand XK=0.025
        SoilVariables.XWILT = equations.van_genuchten(VanGenuchten.Theta_s, VanGenuchten.Theta_r, VanGenuchten.Alpha, -1.5e4, VanGenuchten.n, VanGenuchten.m);
        SoilVariables.XCAP = equations.van_genuchten(VanGenuchten.Theta_s, VanGenuchten.Theta_r, VanGenuchten.Alpha, -336, VanGenuchten.n, VanGenuchten.m);
    elseif strcmp(options.modelType, 'Kosugi')
        SoilVariables.XK = Kosugi.Theta_r + 0.02; % 0.11 This is for silt loam; For sand XK=0.025
        SoilVariables.XWILT = equations.kosugi(Kosugi.Theta_s, Kosugi.Theta_r, Kosugi.mu, -1.5e4, Kosugi.sigma);
        SoilVariables.XCAP = equations.kosugi(Kosugi.Theta_s, Kosugi.Theta_r, Kosugi.mu, -336, Kosugi.sigma);
    else
        error('Invalid model type. Choose either "VanGenuchten" or "Kosugi".');
    end
    SoilVariables.VPERSOC = equations.calc_msoc_fraction(SoilProperties.MSOC); % fraction of soil organic matter
    SoilVariables.FOSL = 1 - SoilProperties.FOC - SoilProperties.FOS - SoilVariables.VPERSOC;

    % Add variables to SoilVariables, see issue 141
    SoilVariables.POR = SoilProperties.porosity;
    SoilVariables.VPERS = SoilProperties.FOS' .* (1 - SoilVariables.POR);
    SoilVariables.VPERSL = SoilVariables.FOSL' .* (1 - SoilVariables.POR);
    SoilVariables.VPERC = SoilProperties.FOC' .* (1 - SoilVariables.POR);
    SoilVariables.Ks = SoilProperties.SaturatedK;
    SoilVariables.Vol_qtz = SoilProperties.FOS;

end
