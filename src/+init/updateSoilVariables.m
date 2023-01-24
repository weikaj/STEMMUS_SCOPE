function [SoilVariables, Genuchten] = updateSoilVariables(SoilVariables, Genuchten, SoilConstants, SoilProperties, i, j)

    SoilVariables.POR(i) = SoilProperties.porosity(j);
    SoilVariables.Ks(i) = SoilProperties.SaturatedK(j);
    SoilVariables.Theta_qtz(i) = SoilConstants.Vol_qtz(j);
    SoilVariables.VPER(i,1) = SoilVariables.VPERS(j);
    SoilVariables.VPER(i,2) = SoilVariables.VPERSL(j);
    SoilVariables.VPER(i,3) = SoilVariables.VPERC(j);
    SoilVariables.XSOC(i) = SoilConstants.VPERSOC(j);
    SoilVariables.XK(i) = 0.11; %0.11 This is for silt loam; For sand XK=0.025

    if SoilConstants.SWCC==1   % VG soil water retention model
        Genuchten.Theta_s(i) = SoilProperties.SaturatedMC(j);
        Genuchten.Theta_r(i) = SoilProperties.ResidualMC(j);
        Genuchten.Theta_f(i) = SoilProperties.fieldMC(j);
        Genuchten.Alpha(i) = SoilProperties.Coefficient_Alpha(j);
        Genuchten.n(i) = SoilProperties.Coefficient_n(j);
        Genuchten.m(i) = 1-1./Genuchten.n(i);

        SoilVariables.XK(i) = SoilProperties.ResidualMC(j) + 0.02;
        SoilVariables.XWILT(i) = equations.van_genuchten(Genuchten.Theta_s(i), Genuchten.Theta_r(i), Genuchten.Alpha(i), -1.5e4, Genuchten.n(i), Genuchten.m(i));
        SoilVariables.XCAP(i) = equations.van_genuchten(Genuchten.Theta_s(i), Genuchten.Theta_r(i), Genuchten.Alpha(i), -336, Genuchten.n(i), Genuchten.m(i));
    else
        Genuchten.Theta_s(i) = Theta_s_ch(j); % TODO check undefined Theta_s_ch
        Genuchten.Theta_r(i) = SoilProperties.ResidualMC(j);

        if SoilConstants.CHST==0  % Indicator of parameters derivation using soil texture or not. CHST=1, use; CHST=0 not use
            SoilVariables.Phi_s(i) = SoilConstants.Phi_S(j);
            SoilVariables.Lamda(i) = SoilProperties.Coef_Lamda(j);
        else
            Genuchten.Theta_s_min(i)=0.489-0.00126*SoilVariables.VPER(i,1)/(1-SoilVariables.POR(i))*100;
            Genuchten.Theta_s(i) = Genuchten.Theta_s_min(i)*(1-SoilVariables.XSOC(i))+SoilVariables.XSOC(i)*SoilConstants.Theta_soc;
            Genuchten.Theta_s(i) = Genuchten.Theta_s_min(i); % TODO check repeated lines

            SoilVariables.Phi_s(i) = init.calcPhi_s(SoilVariables.VPER(i,1), SoilVariables.POR, SoilConstants.Phi_soc, SoilVariables.XSOC);
            SoilVariables.Lamda(i) = init.calcLambda(SoilVariables.VPER(i,3), SoilVariables.POR, SoilVariables.Lamda_soc, SoilVariables.XSOC);
        end
        SoilVariables.XWILT(i) = Genuchten.Theta_s(i) * ((-1.5e4) / SoilVariables.Phi_s(i)) ^(-1 * SoilVariables.Lamda(i));
end
