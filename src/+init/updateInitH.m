function initH = updateInitH(initX, VanGenuchten, SoilVariables, i, ModelSettings, Kosugi, options)

    if ModelSettings.SWCC == 1   % VG and Kosugi soil water retention model
        initH = init.calcInitH(VanGenuchten.Theta_s(i), VanGenuchten.Theta_r(i), initX, VanGenuchten.n(i), VanGenuchten.m(i), VanGenuchten.Alpha(i), Kosugi.mu(i), Kosugi.sigma(i), options);
    else
        initH = SoilVariables.Phi_s(i) * (InitX / VanGenuchten.Theta_s(i))^(-1 / SoilVariables.Lamda(i));
    end
end
