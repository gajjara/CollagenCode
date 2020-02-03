%% MainExperiment
lightsource = blueLEDm470L3();
filterset = filterset1;
lambda = filterset.wavelength;
dye = alexa488();
dye.absorption_coefficent = dye.sigma;
dye.scattering_coefficent = 1e-13;
objective.M = 60;
objective.NA = 1.33; %Worst case: 1.0, Best case: 1.45
objective.n_medium = 1.56;
andorcam = andorX8250camera();
coolsnapcam = coolsnap_ez_monochrome();
debuglevel = 100; % From 0-100 (Higher debuglevel shows more data
integration_time = 5; % in seconds

%%

simulatingleakage = 0; 
if(simulatingleakage == 1)
    filterset.excitation_transmission(501:1501) = 1;
    filterset.dichroic_transmission(501:1501) = 0;
    filterset.emission_transmission(1501:2001) = 1;
    filterset.dichroic_transmission(1501:2001) = 1;
end



%F_withAndor =    Experiment( ...
%    lightsource, filterset, dye, objective, ...
%    andorcam,    lambda, integration_time, debuglevel);
F_withCoolsnap = Experiment( ...
    lightsource, filterset, dye, objective, ...
    coolsnapcam, lambda, integration_time, debuglevel);
close all;

%%
% SIGNAL_ANDOR =              F_withAndor.noise.signal_photons;
% BACKGROUND_ANDOR =          F_withAndor.noise.noise_photons;
% SIGNAL_ELECTRONS_ANDOR =    F_withAndor.noise.signal;
% BACKGROUND_ELECTRONS_ANDOR =F_withAndor.noise.noise_from_scattering;
% DARKCURRENTNOISE_ANDOR =    F_withAndor.noise.noise_from_dark_current;
% READOUTNOISE_ANDOR     =    F_withAndor.noise.noise_from_readout_noise;
SIGNAL_COOLSNAP =               F_withCoolsnap.noise.signal_photons;
BACKGROUND_COOLSNAP =           F_withCoolsnap.noise.noise_photons;
SIGNAL_ELECTRONS_COOLSNAP =     F_withCoolsnap.noise.signal;
BACKGROUND_ELECTRONS_COOLSNAP = F_withCoolsnap.noise.noise_from_scattering;
DARKCURRENTNOISE_COOLSNAP =     F_withCoolsnap.noise.noise_from_dark_current;
READOUTNOISE_COOLSNAP     =     F_withCoolsnap.noise.noise_from_readout_noise;

disp("DISPLAYING IMPORTANT VALUES");
disp("");
disp("Integration Time");
disp(integration_time);
% disp("Signal from Andor Camera (photons)");
% disp(SIGNAL_ANDOR);
% disp("Background from Andor Camera (photons)");
% disp(BACKGROUND_ANDOR);
% disp("Signal Electrons from Andor Camera (electrons)");
% disp(SIGNAL_ELECTRONS_ANDOR);
% disp("Background Electrons from Andor Camera (electrons)");
% disp(BACKGROUND_ELECTRONS_ANDOR);
% disp("Dark Current Noise from Andor Camera (electrons)");
% disp(DARKCURRENTNOISE_ANDOR);
% disp("Readout Noise from Andor Camera (electrons)");
% disp(READOUTNOISE_ANDOR);
disp("Signal from Coolsnap Camera (photons)");
disp(SIGNAL_COOLSNAP);
disp("Background from Coolsnap Camera (photons)");
disp(BACKGROUND_COOLSNAP);
disp("Signal Electrons from Coolsnap Camera (electrons)");
disp(SIGNAL_ELECTRONS_COOLSNAP);
disp("Background Electrons from Coolsnap Camera (electrons)");
disp(BACKGROUND_ELECTRONS_COOLSNAP);
disp("Dark Current Noise from Coolsnap Camera (electrons)");
disp(DARKCURRENTNOISE_COOLSNAP);
disp("Readout Noise from Coolsnap Camera (electrons)");
disp(READOUTNOISE_COOLSNAP);




