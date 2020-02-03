%% Parameters
lightsource = blueLEDm470L3();
filterset = filterset1;
lambda = filterset.wavelength;
dye = alexa488();
dye.absorption_coefficent = dye.sigma;
dye.scattering_coefficent = 1e-13;
objective.M = 60;
objective.NA = 1.45; %Worst case: 1.0, Best case: 1.45
objective.n_medium = 1.56;
camera = coolsnap_ez_monochrome();
debuglevel = 100; % From 0-100 (Higher debuglevel shows more data
integration_time = 5; % in seconds

%% Experiment

F = Experiment(lightsource, filterset, dye, objective, ...
    camera, lambda, integration_time, debuglevel);

%% Make Figure
figure; semilogy( ...
    F.default_wavelength*1e9, ...
    F.scattering.photons_spectral_scattering_from_sample_rate/1e3, ...
    F.default_wavelength*1e9, ...
    F.scattering.photons_spectral_from_scattering_from_filters_rate/1e3); 
xlabel('\lambda, Wavelength, nm');
ylabel('N_\lambda, Photons scattered per mm per second'); 
title("Photon Scattering Rate Before and After Filter Set"); 
legend('Before Filter Set', 'After Filter Set');

figure; plot(F.default_wavelength*1e9, F.camera.quantum_efficiency); 
title("Quantum Efficency of Coolsnap Camera"); 
xlabel("\lambda, Wavelength, nm"); 
ylabel("Value"); 
legend("Quantum Efficency");


