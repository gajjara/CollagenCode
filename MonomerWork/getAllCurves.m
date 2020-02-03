lightsource = blueLEDm470L3();
filterset = filterset1;
lambda = filterset.wavelength;
dye = alexa488();
dye.absorption_coefficent = dye.sigma;
dye.scattering_coefficent = 1e-13;
objective.M = 60;
objective.NA = 1.45; %Worst case: 1.0, Best case: 1.45
objective.n_medium = 1.56;

camera1 = coolsnap_ez_monochrome();

F_FINAL = Experiment(lightsource, filterset, dye, objective, camera1, lambda, 0);
close all;

EMISSION = F_FINAL.emission;
SCATTERING = F_FINAL.scattering;

%%
% %%
% % plot one
% figure; plot(lambda, F_FINAL.lightsource.spectral_radiance); grid on; ...
%     title('Spectral Radiance at Source');
%     xlabel('\lambda, Wavelength, nm'); ...
%     ylabel('L_\lambda, Spectral Radiance, W/mm^2/sr/mm');
% 
% % plot two
% figure; plot(lambda, ...
%     F_FINAL.integration_time*...
%     EMISSION.photon_spectral_radiance_on_sample_rate); ...
%     grid on;
%     title('Spectral Irradiance on Sample');
%     xlabel('\lambda, Wavelength, nm'); ...
%     ylabel('Spectral Irradiance, W/mm^2/mm');
%    
% % plot thress
