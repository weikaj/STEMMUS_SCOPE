function Btmh = updateBtmh(VanGenuchten, SoilVariables, i, ModelSettings, Kosugi, options)

    if ModelSettings.SWCC == 1   %  VG and Kosugi soil water retention model
        Btmh = init.calcInitH(VanGenuchten.Theta_s(i), VanGenuchten.Theta_r(i), SoilVariables.BtmX, VanGenuchten.n(i), VanGenuchten.m(i), VanGenuchten.Alpha(i),Kosugi.mu(i), Kosugi.sigma(i), options);
    else
        Btmh = SoilVariables.Phi_s(i) * (SoilVariables.BtmX / VanGenuchten.Theta_s(i))^(-1 / SoilVariables.Lamda(i));
    end
end
