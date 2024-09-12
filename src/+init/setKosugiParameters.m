function Kosugi = setKosugiParameters(SoilProperties)
    %{
        Update/define parameters of Kosugi model.
        Kosugi K. (1996) Lognormal Distribution Model for Unsaturated Soil
        Hydraulic Properties. Water Resources Research, 32(9), 2697-2703.
        https://doi.org/10.1029/96WR01776
    %}

    Kosugi.Theta_s = SoilProperties.SaturatedMC;
    Kosugi.Theta_r = SoilProperties.ResidualMC;
    Kosugi.Theta_f = SoilProperties.fieldMC;
    Kosugi.mu = SoilProperties.Coefficient_mu; %added into SoilProperties.mat by append 
    Kosugi.sigma = SoilProperties.Coefficient_sigma;
end