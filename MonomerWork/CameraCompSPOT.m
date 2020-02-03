%% Initial Data
% Initial data includes:
% 
% * Spectral radiance of the light sources
% * Transmission data of the filtersets
% * Excitation and emission spectra of the sample
% * Quantum yield, lifetime, absorption, and scattering coefficents of the
% sample
% * Solid angle, numerical aperture, and index of refraction of objective
% lens
% * Quantum efficiency of camera
%
%

lightsource = blueLEDm470L3();
filterset = filterset1;
lambda = filterset.wavelength;
dye = alexa488();
dye.absorption_coefficent = dye.sigma;
dye.scattering_coefficent = 1e-13;

objective.M = 60;
objective.NA = 1.45;
objective.n_medium = 1.56;

camera0 = andorX8250camera();
camera1 = SPOTRT900Camera();

%% CALCULATE
%
% All calculations are conducted thorugh the Experiment.m class
%
% The Experiment.m class calculates the physical values and spectra for
% the emission and scattering from the sample in the Collagen experiment
% and requires the input of data on the filters, objective lens, and
% camera. Documentation is provided for the class.
% 
% What is calculated and determined is:
%
% * Irradiance and radiance form the light source and on the sample
% * Emission from the sample
% * Scattering from the sample
% * Transmission through the objective and filters from both scattering and
% emission
% * Number of electrons excited within the camera from the transmitted
% photons from emission and scattering
% * The number of particles at each stage of the experiments
% * Percentages based off the above values
%
%
% Other functions are:
%
% * Automatically resampling data
% * Displaying numerical data based on a debuglevel
% * Displaying spectral data based on a debuglevel
% * Creates a small GUI to select figures
% * Contains linear interpolation and trapizoidal integration functions
% internally
% * Setters, getter, and checker functions for initial data and constants
%
%
% Data required:
%
% * Spectral radiance, wavelength, and name of the light source.
% * Tranmission and wavelength of each filter in the filter set.
% * Excitation and emission spectrum, wavelength, absorption
% coefficent, scattering coefficent, quantum yield, and lifetime
% of the sample.                                                        
% * Refraction index, solid angle, and numerical aperture of the bjecitve lens.
% * Quantum efficiency and wavelength of the camera.
% * A default wavelength to have each data set be resampled to.
%
% 
% 
F_ANDOR =    Experiment(lightsource, filterset, dye, objective, camera0, lambda, 0.1, 'Andor Camera ');
F_SPOT = Experiment(lightsource, filterset, dye, objective, camera1, lambda, 0.1, 'Spot Camera ');

%lightsource_blue  = blueLEDm470L3();
%lightsource_white = whiteLEDmcwhl5();

%F_BLUE =  Experiment(lightsource_blue , filterset, dye, objective, camera, lambda, 0, 'Blue Light ');
%F_WHITE = Experiment(lightsource_white, filterset, dye, objective, camera, lambda, 0, 'White Light ');
close all;

%% FILTER TRANSMISSION AND DYE EMISSION AND EXCITATION
if(1)
    figure;
    semilogy(lambda*1e9, filterset.excitation_transmission, 'b', ...
        lambda*1e9, 1 - filterset.dichroic_transmission, 'g', ...
        lambda*1e9, filterset.excitation_transmission.* ...
                (1 - filterset.dichroic_transmission), 'r');
    limits = axis;
    axis([limits(1:2), limits(4)*[0,1]]);
    grid on;
    title('Transmission and Reflection through Filters from Source');
    xlabel('\lambda, Wavelength, nm');
    ylabel('Transmission/Reflection Ratio (0-1)');
    legend('Excitation Transmission', 'Dichroic Reflection', 'Product');
end
if(1)
    figure;
    semilogy(lambda*1e9, filterset.dichroic_transmission, 'b', ...
        lambda*1e9, filterset.emission_transmission, 'g', ...
        lambda*1e9, filterset.emission_transmission.* ...
                filterset.dichroic_transmission, 'r');
    limits = axis;
    axis([limits(1:2), limits(4)*[0,1]]);
    grid on;
    title('Transmission of Photons Through Filters from Sample');
    xlabel('\lambda, Wavelength, nm');
    ylabel('Filter');
    legend('Dichroic Transmission','Emission Transmission','Product'); 
end
if(1)
    figure;
    plot(lambda*1e9, F_ANDOR.dye.excitation_spectrum, ...
         lambda*1e9, F_ANDOR.dye.emission_spectrum);
    grid on;
    title('Dye Excitation and Emission Spectra');
    xlabel('\lambda, Wavelength, nm');
    ylabel('Percent Excited/Emitted (0-100)');
    legend('Excitation Spectra', 'Emission Spectra');
end

%% COMPARE BLUE AND WHITE LIGHT
% Blue light chosen as it produces less noise than white light
if(1)
    figure;
    plot(lambda*1e9,  F_BLUE.lightsource.spectral_radiance/1e6/1e3, ...
         lambda*1e9, F_WHITE.lightsource.spectral_radiance/1e6/1e3);
    grid on;
    title('Spectral Radiance from Blue and White Light At Source');
    xlabel('\lambda, Wavelength, nm');
    ylabel('L_\lambda, Spectral Radiance, W/mm^2/sr/mm');
    legend('Blue Light', 'White Light');
end

if(1)
    figure;
    plot(1e9*lambda,    F_BLUE.emission.electrons_spectral_from_emission_camera, ...
         1e9*lambda,  F_BLUE.scattering.electrons_spectral_from_scattering_camera);
    grid on;
    title('Electrons from Emission and Scattering from Blue Light');
    xlabel('\lambda, Wavelength, nm');
    ylabel('N_\lambda, Electrons');
    legend('Electrons from Emission', 'Electrons from Scattering');
end
if(1)
    figure;
    plot(1e9*lambda,    F_WHITE.emission.electrons_spectral_from_emission_camera, ...
         1e9*lambda,  F_WHITE.scattering.electrons_spectral_from_scattering_camera);
    grid on;
    title('Electrons from Emission and Scattering from White Light');
    xlabel('\lambda, Wavelength, nm');
    ylabel('N_\lambda, Electrons');
    legend('Electrons from Emission', 'Electrons from Scattering');
end

%% SPECTRAL RADIANCE, EMISSION, SCATTERING
% Data on the results from the calculations with blue light
if(1)
    figure;
    plot(lambda*1e9,  F_ANDOR.lightsource.spectral_radiance/1e6/1e3, ...
         lambda*1e9,  F_ANDOR.emission.spectral_radiance_on_sample/1e6/1e3)
    grid on;
    title('Spectral Radiance from Blue Light At Source and At Sample');
    xlabel('\lambda, Wavelength, nm');
    ylabel('L_\lambda, Spectral Radiance, W/mm^2/sr/mm');
    legend('At Source', 'At Sample');
end
if(1)
    figure;
    plot(lambda*1e9,   F_ANDOR.emission.photons_spectral_from_emission_in_filters_rate/1e9, ...
         lambda*1e9,   F_ANDOR.emission.photons_spectral_from_emission_from_filters_rate/1e9)
    grid on;
    title('Blue Light Photon Emission Rate Before and After Filter Set');
    xlabel('\lambda, Wavelength, nm');
    ylabel('N_\lambda, Photons transmitted per nm per second');
    legend('Emission Before Filter Set','Emission After Filter Set');
end
if(1)
    figure;
    plot(lambda*1e9, F_ANDOR.scattering.photons_spectral_from_scattering_in_objective_rate/1e9, ...
         lambda*1e9, F_ANDOR.scattering.photons_spectral_from_scattering_from_filters_rate)
    grid on;
    title('Blue Light Photon Scattering Rate Before and After Filter Set');
    xlabel('\lambda, Wavelength, nm');
    ylabel('N_\lambda, Photons scattered per nm per second');
    legend('Scattering Before Filter Set', 'Scattering After Filter Set');
end

%% COMPARING CAMERAS
if(1)
    figure;
    plot(1e9*lambda,    F_ANDOR.emission.electrons_spectral_from_emission_camera, ...
         1e9*lambda,  F_ANDOR.scattering.electrons_spectral_from_scattering_camera);
    grid on;
    title('Electrons from Emission and Scattering from Andor Camera');
    xlabel('\lambda, Wavelength, nm');
    ylabel('N_\lambda, Electrons');
    legend('Electrons from Emission', 'Electrons from Scattering');
end
if(1)
    figure;
    plot(1e9*lambda,    F_SPOT.emission.electrons_spectral_from_emission_camera, ...
         1e9*lambda,  F_SPOT.scattering.electrons_spectral_from_scattering_camera);
    grid on;
    title('Electrons from Emission and Scattering from Coolsnap Camera');
    xlabel('\lambda, Wavelength, nm');
    ylabel('N_\lambda, Electrons');
    legend('Electrons from Emission', 'Electrons from Scattering');
end

if(1)
    disp("Number of electrons from emission Andor Camera");
    disp(F_ANDOR.number_of_particles.number_of_electrons_from_emission);
    disp("Number of electrons from scattering Andor Camera");
    disp(F_ANDOR.number_of_particles.number_of_electrons_from_scattering);
    disp("Ratio of electrons from scattering to emission Andor Camera");
    disp(F_ANDOR.number_of_particles.number_of_electrons_from_scattering/...
         F_ANDOR.number_of_particles.number_of_electrons_from_emission);
    disp("Number of electrons from emission Coolsnap Camera");
    disp(F_SPOT.number_of_particles.number_of_electrons_from_emission);
    disp("Number of electrons from scattering Coolsnap Camera");
    disp(F_SPOT.number_of_particles.number_of_electrons_from_scattering);
    disp("Ratio of electrons from scattering to emission Coolsnap Camera");
    disp(F_SPOT.number_of_particles.number_of_electrons_from_scattering/...
         F_SPOT.number_of_particles.number_of_electrons_from_emission);
end

if(1)
    ANDOR = andorX8250camera(); %dark current is electron per pixel per second
    ANDOR.readout_noise = 1; % electron rms
    SPOT = SPOTRT900Camera(); %dark current is electron per pixel per second
    disp('Andor Camera | Dark Current (electrons per pixel per second)')
    disp(ANDOR.dark_current);
    disp('Andor Camera | Readout Noise (electron rms)');
    disp(ANDOR.readout_noise);
    disp("Andor Camera | Ratio of electrons from scattering to emission");
    disp(F_ANDOR.number_of_particles.number_of_electrons_from_scattering/...
         F_ANDOR.number_of_particles.number_of_electrons_from_emission);
    disp("Andor Camera | Number of electrons from emission");
    disp(F_ANDOR.number_of_particles.number_of_electrons_from_emission);
    disp("Andor Camera | Number of electrons from scattering");
    disp(F_ANDOR.number_of_particles.number_of_electrons_from_scattering);
    % SNR = Emission electrons/sqrt(Emission electrons +
    % readnoise*readnoise + darkcurrent*npixels*integration_time +
    % scattering electrons)
    % Calc Andor SNR
    emission_electrons = F_ANDOR.number_of_particles.number_of_electrons_from_emission;
    scattering_electrons=F_ANDOR.number_of_particles.number_of_electrons_from_scattering;
    readnoise = ANDOR.readout_noise;
    darknoise = sqrt(512*512*F_ANDOR.integration_time*ANDOR.dark_current);
    ANDOR_SNR = (emission_electrons/(sqrt(emission_electrons + readnoise + ...
        darknoise + scattering_electrons)));
    disp('Andor Camera | Electrons from Dark Current')
    disp(darknoise);
    disp('Andor Camera | Electrons from Read Out Noise')
    disp(readnoise);
    disp('Andor Camera | Signal to Noise Ratio')
    disp(ANDOR_SNR);
    
    disp('Spot Camera | Dark Current (electrons per pixel per second)')
    disp(SPOT.dark_current);
    disp('Spot Camera | Readout Noise (electron rms)');
    disp(SPOT.readout_noise);
    disp("Spot Camera | Ratio of electrons from scattering to emission");
    disp(F_SPOT.number_of_particles.number_of_electrons_from_scattering/...
         F_SPOT.number_of_particles.number_of_electrons_from_emission);
    disp("Spot Camera | Number of electrons from emission");
    disp(F_SPOT.number_of_particles.number_of_electrons_from_emission);
    disp("Spot Camera | Number of electrons from scattering");
    disp(F_SPOT.number_of_particles.number_of_electrons_from_scattering);
    
    % SNR = Emission electrons/sqrt(Emission electrons +
    % readnoise*readnoise + darkcurrent*npixels*integration_time +
    % scattering electrons)
    % Calc Coolsnap SNR
    emission_electrons = F_SPOT.number_of_particles.number_of_electrons_from_emission;
    scattering_electrons=F_SPOT.number_of_particles.number_of_electrons_from_scattering;
    readnoise = SPOT.readout_noise;
    darknoise = sqrt(SPOT.pixelcountx*SPOT.pixelcounty*F_SPOT.integration_time*SPOT.dark_current);
    SPOT_SNR = (emission_electrons/(sqrt(emission_electrons + readnoise + ...
        darknoise + scattering_electrons)));
    disp('Spot Camera | Electrons from Dark Current')
    disp(darknoise);
    disp('Spot Camera | Electrons from Read Out Noise')
    disp(readnoise);
    disp('Spot Camera | Signal to Noise Ratio')
    disp(SPOT_SNR);
    fprintf('\n');
    fprintf("SNR =\t Emission Electrons/\n");
    fprintf("\t sqrt(Emission Electrons + Dark Electrons + Readout Noise + Scattering Electrons)\n");
    fprintf("Dark Electrons = sqrt(Pixels*Dark Current*Integration Time)\n");
end