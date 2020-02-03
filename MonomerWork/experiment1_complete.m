%% EXPERIMENT 1 PROGRAM

%% PROGRAM NOTES
%
% VARIABLE NAMING (FOR MOST VARIABLES)
% Variable are named by type of particle, if the variable is spectral,
% by which property, by experiment stage, and wheter or not there is a
% per second rate for the variable.
% 
% Variable names have this structure:
%      particle  spectral?   property    stage   rate?, with an example of:
% Ex:  photon_spectral_radiance_on_sample_rate
%
% The following particles are: photon, electron, photons, electrons
% The following properties are: absorption, emission, scattering, 
% from_emission, from_scattering, radiance, and irradiance, 
% The following stages are: from_src, on_sample, in_sample, from_sample,
% in_objective, to_filters, on_filters, in_filters, from_filters, 
% to_camera, _camera
%
% debuglevel VARIABLE
% The debuglevel variable allows figures and values to be shown for 
% the purpose of debugging and seeing the values
% 
% The debuglevel variable has five different values based on the
% importance of the value or figure
%  
% debuglevel VALUE      IMPORTANCE
% 0                     Very Important
% 25                    Important
% 50                    Neutral
% 75                    Not Important
% 100                   Very Not Important
%
% FILES AND FUNCTIONS NEEDED
% alexa488.m, andorX8250camera.m, andorX8520.mat, blueLEDm470L3.m,
% filterset1.m, linterp.m, resample_data.m, trapni.m
%
% VARIABLES THAT ARE STRUCTS
% camera, dye, filterset, lightsource, objective
%
% VARIABLES THAT ARE GUESSED
% n_glass, integration_time, scattering_coefficent

%% Experiment Constants, Intitial Values, Characteristics, and Parameters
debuglevel = 100;               % For debugging

% Constants
n_glass = 1.56;                 % Guess for the coverslip
n_medium = n_glass;             % 
integration_time = 5;        % seconds (guess for now)
c = 299792458;                  % m/s
h = 6.626068E-34;               % Joules/Hz =  m2 kg / s
electron = 1.60217646E-19;      % coulombs
avogadro = 6.022045E23;         % molecules/mol

% Filterset and lightsource
lightsource = blueLEDm470L3();%blueLEDm470L3();  % Use the Thorlabs blue LED source 
filterset = filterset1;         % Mohammad's filter set for fluorescence
lambda = filterset.wavelength;  % Use the wavelength axis of the
                                % filter set for all plots

% Dye characteristics resampled
dye = alexa488();
dye_excitation_resampled = resample_data(dye.excitation_spectrum, ...
    dye.wavelength, lambda);
dye_emission_resampled = resample_data(dye.emission_spectrum, ...
    dye.wavelength, lambda);

camera = coolsnap_ez_monochrome;

% Objective characteristics
objective.M = 60;
objective.NA = 1.33; 

%% Transmission Through Excitation Filter and Reflection from Dichroic

% Resample spectral radiance data from lightsource
spectral_radiance_from_src_resampled = ...
    resample_data(lightsource.spectral_radiance, ...
        lightsource.wavelength, lambda);
    
% TEST: REMOVE
test = 0;
if(test == 1)
spectral_radiance_from_src_resampled(750:1100) = spectral_radiance_from_src_resampled(650:1000); 
spectral_radiance_from_src_resampled(650:749) = 0;
end

% Spectral radiance on the sample
% multiply by n_medium^2 to get radiance in medium
spectral_radiance_on_sample = ...  
    spectral_radiance_from_src_resampled.*...
    filterset.excitation_transmission.*...
    (1 - filterset.dichroic_transmission)*n_medium^2;

% Photon spectral radiance per second on the target
photon_spectral_radiance_on_sample_rate = spectral_radiance_on_sample./...
    (h*c./lambda);

% Photon spectral radiance per second on the target
photon_radiance_on_sample_rate = ...
    trapni(photon_spectral_radiance_on_sample_rate, lambda);
    
% Debugging this section
if(debuglevel >= 100)
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
    ylabel('Filter');
    legend('Excitation Transmission', 'Dichroic Reflection', 'Product');
end

if(debuglevel >= 75)
    figure;
    plot(lightsource.wavelength*1e9, ...
        lightsource.spectral_radiance/1e6/1e3, ...
            'b', ...
        lambda*1e9, ...
        spectral_radiance_on_sample/1e6/1e3, 'r');
    grid on;
    title('Spectral Radiance At Source and On Sample');
    xlabel('\lambda, Wavelength, nm');
    ylabel('L_\lambda, Spectral Radiance, W/mm^2/sr/mm');
    legend('At Source', 'On Sample');
end

if(debuglevel >= 100)
    figure;
    plot(lambda*1e9, ...
        photon_spectral_radiance_on_sample_rate/1e6/1e3, 'r');
    grid on;
    title('Photon Spectral Radiance on Sample Rate');
    xlabel('\lambda, Wavelength, nm');
    ylabel('L_{P\lambda}, Photon Spectral Radiance, Photons/s/mm^2/sr/mm');
end

if(debuglevel >= 50)
    disp('Photons per second per mm^2 per steradian on sample');
    disp(photon_radiance_on_sample_rate/1e6);
end

%% Photon Irradiance at the Sample

% Irradiance = Omega * Radiance
Omega = 2*pi*(1 - sqrt(1 - (objective.NA/n_medium)^2));
photon_irradiance_on_sample_rate = ...
    photon_radiance_on_sample_rate*Omega;

photon_spectral_irradiance_on_sample_rate = ...
    photon_spectral_radiance_on_sample_rate*Omega;

% Debugging this section
if(debuglevel >= 50)
    disp('Photons per second per mm^2 on sample');
    disp(photon_irradiance_on_sample_rate/1e6);
end

%% Absorbed and Emitted Photons

% Photons absorbed by sample per second
% absorption = irradiance * sigma
absorption_coefficent = dye.sigma;
photons_absorbed_by_sample_rate = ...
    photon_irradiance_on_sample_rate*absorption_coefficent;

% Photons emitted by sample per second
% emission = quantum yield*(1/((1/absorption) + lifetime))
photons_emitted_by_sample_rate = dye.quantum_yield*...
    1/(1/photons_absorbed_by_sample_rate + dye.lifetime);
                
% Debugging this section
if(debuglevel >= 50)
    disp('Photons per second absorbed by sample');
    disp(photons_absorbed_by_sample_rate);
    disp('Photons per second emitted by sample');
    disp(photons_emitted_by_sample_rate);
end

if(photons_absorbed_by_sample_rate > 1/dye.lifetime)
    disp('Warning: Fluorescence Saturation');
end

%% Photons in Solid Angle

% Photons in through the objective lens
% photons per second = emission*omega/4/pi
Omega = 2*pi*(1 - sqrt(1 - (objective.NA/n_medium)^2));
photons_from_emission_in_objective_rate = ...
    photons_emitted_by_sample_rate*Omega/4/pi;
                   
% Debugging this section
if(debuglevel >= 50)
    disp('Photons through objective lens per second');
    disp(photons_from_emission_in_objective_rate);
end

% Filters on photons recieved from emission from sample
if(debuglevel >= 100)
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

%% Photons Through Filters

% Normalizing photon emission
norm = trapni(dye_emission_resampled, lambda);
photons_spectral_from_emission_in_filters_rate = ...
    photons_from_emission_in_objective_rate*...
    dye_emission_resampled/norm;

% Photons through the filters per second per wavelength
% photons per second per wavelength = emission per second per wavelength
% * transmission per second per wavelength
photons_spectral_from_emission_from_filters_rate = ...
    photons_spectral_from_emission_in_filters_rate.*...
    filterset.emission_transmission.*...
    filterset.dichroic_transmission;

% Debugging
if(debuglevel >= 75)
    figure;
    plot(lambda*1e9, ...
        photons_spectral_from_emission_in_filters_rate/1e9, ...
        'b', lambda*1e9, ...
        photons_spectral_from_emission_from_filters_rate/1e9, 'r');
    grid on;
    title('Photon Emission Rate Before and After Filter Set');
    xlabel('\lambda, Wavelength, nm');
    ylabel('N_\lambda, Photons emitted per nm per second');
    legend('Before Filter Set','After Filter Set');
end
                
% Photons through the filters
photons_from_emission_from_filters_rate = ...
    trapni(photons_spectral_from_emission_from_filters_rate, lambda);

% Debugging
if(debuglevel >= 50)
    disp('Photons emitted through filters per second');
    disp(photons_from_emission_from_filters_rate);
end

%% Photons Entering Camera and Electrons in Camera

% Extract quantum efficiency from camera
camera;
quantum_efficiency_resampled = resample_data(camera.quantum_efficiency, ...
    camera.wavelength, lambda);

% Electons per wavelength per second within camera
electrons_spectral_from_emission_camera_rate = ...
    photons_spectral_from_emission_from_filters_rate.*...
    (quantum_efficiency_resampled/100);

% Electrons per wavelength within camera
electrons_spectral_from_emission_camera = ...
    electrons_spectral_from_emission_camera_rate*integration_time;

% Number of electrons within camera
number_of_electrons_from_emission = ...
    trapni(electrons_spectral_from_emission_camera, lambda);
        
% Photons entering camera per wavelength
photons_spectral_emission_from_filters = ...
    photons_spectral_from_emission_from_filters_rate*integration_time;

% Debugging this section
if(debuglevel >= 100)
    figure;
    plot(lambda*1e9, photons_spectral_emission_from_filters, ...
        lambda*1e9, electrons_spectral_from_emission_camera);
    grid on;
    title('Photons Entering Camera and Electrons in Camera from Emission');
    xlabel('\lambda, Wavelength, nm');
    ylabel('N_\lambda, Particles');
    legend('Photons', 'Electrons');
end

if(debuglevel >= 25)
    disp('Number of electrons from emission');
    disp(number_of_electrons_from_emission);
end

%% Scattered Photons

% Calculate scattering coefficent
scattering_coefficent = 1e-13;      % Guess for now

% Photons scattered = irradiance*scattering_coefficent
photons_spectral_scattering_from_sample_rate = ...
    photon_spectral_irradiance_on_sample_rate*scattering_coefficent;

photons_scattering_from_sample_rate = ...
    trapni(photons_spectral_scattering_from_sample_rate, lambda);

% Debugging
if(debuglevel >= 50)
    disp('Photons per second scattered by sample')
    disp(photons_scattering_from_sample_rate);
end

% Photons on filters = photons_scattered*(Omega/4pi)
photons_spectral_from_scattering_in_objective_rate = ...
    photons_spectral_scattering_from_sample_rate*(Omega/(4*pi));

photons_scattered_in_objective_rate = ...
    trapni(photons_spectral_from_scattering_in_objective_rate, lambda);

% Debugging
if(debuglevel >= 50)
    disp('Photons scattered through objective lens per second')
    disp(photons_scattered_in_objective_rate);
end

% Photons through filters = photons scattered*transmission
photons_spectral_from_scattering_from_filters_rate = ...
    photons_spectral_from_scattering_in_objective_rate.*...
    filterset.emission_transmission.*...
    filterset.dichroic_transmission;

photons_from_scattering_from_filters_rate = ...
    trapni(photons_spectral_from_scattering_from_filters_rate, lambda);

% Debugging
if(debuglevel >= 50)
    disp('Photons scattered through filters per second')
    disp(photons_from_scattering_from_filters_rate);
end

% Electrons from scattering = photons from scattering*quantum_efficiency
electrons_spectral_from_scattering_camera_rate = ...
    photons_spectral_from_scattering_from_filters_rate.*...
    (quantum_efficiency_resampled/100);

% Number of electrons from scattering per wavelength
electrons_spectral_from_scattering_camera = ...
    electrons_spectral_from_scattering_camera_rate*integration_time;

% Number of electrons from scattering
number_of_electrons_from_scattering = ...
    trapni(electrons_spectral_from_scattering_camera, lambda);

% Scattered photons through the filter per wavelnegth
photons_spectral_scattered_from_filters = ...
    photons_spectral_from_scattering_from_filters_rate*integration_time;

% Ratio of electrons from emission to electrons from scattering
ratio_electrons_from_emission_electrons_from_scattering = ...
    number_of_electrons_from_emission/number_of_electrons_from_scattering;

% Debugging
if(debuglevel >= 100)
    figure;
    plot(1e9*lambda, photons_spectral_scattered_from_filters, ...
        1e9*lambda, electrons_spectral_from_scattering_camera);
    grid on; 
    title(...
        'Photons Entering Camera and Electrons in Camera from Scattering');
    xlabel('\lambda, Wavelength, nm');
    ylabel('N_\lambda, Particles');
    legend('Photons', 'Electrons');
end

if(debuglevel >= 25)
    disp('Number of electrons from scattering');
    disp(number_of_electrons_from_scattering);
end

if(ratio_electrons_from_emission_electrons_from_scattering < 1)
	disp('Warning: Excessive Noise');
end

if(debuglevel >= 0)
    figure;
    plot(1e9*lambda, electrons_spectral_from_emission_camera, ...
        1e9*lambda, electrons_spectral_from_scattering_camera);
    grid on;
    title('Electrons from Emission and Scattering');
    xlabel('\lambda, Wavelength, nm');
    ylabel('N_\lambda, Electrons');
    legend('Electrons from Emission', 'Electrons from Scattering');
end

%% Checking Number of Particles at Each Stage

% Number of Particles from Emission
photons_emitted_by_sample = ...
    photons_emitted_by_sample_rate*integration_time;
photons_from_emission_in_objective = ...
    photons_from_emission_in_objective_rate*integration_time;
photons_from_emission_from_filters = ...
    photons_from_emission_from_filters_rate*integration_time;
number_of_electrons_from_emission;

% Number of Particles from Scattering
photons_scattered_by_sample = ...
    photons_scattering_from_sample_rate*integration_time;
photons_from_scattering_in_objective = ...
    photons_scattered_in_objective_rate*integration_time;
photons_from_scattering_from_filters = ...
    photons_from_scattering_from_filters_rate*integration_time;
number_of_electrons_from_scattering;

% Arrays to signal each stage
stage_number = [1, 2, 3, 4];
stage_number_size = size(stage_number);

% Stages for particles from emission:
% Photons Emitted by Sample
% Photons from Emission through Objective
% Photons from Emission through Filters
% Number of Electroms from Emission
particles_each_stage_emission = [photons_emitted_by_sample, ...
    photons_from_emission_in_objective, ...
    photons_from_emission_from_filters, ...
    number_of_electrons_from_emission];

% Stages for particles from scattering:
% Photons Scattering by Sample (ignored),
% Photons from Scattering through Objective (ignored),
% Photons from Scattering through Filters, 
% Number of Electrons from Scattering
particles_each_stage_scattering = [-1e10, ...
    -1e10, ...
    photons_from_scattering_from_filters, ...
    number_of_electrons_from_scattering];
                
% Debugging this section
if(debuglevel >= 0)
    figure;
    for i = 1:stage_number_size(2)
        plot(stage_number(i), particles_each_stage_emission(i), 'b--o');
        hold on;
    end
    for j = 1:stage_number_size(2)
        plot(stage_number(j), particles_each_stage_scattering(j), 'r--o');
        hold on;
    end
    grid on;
    xticks(stage_number);
    axis([stage_number_size(1) stage_number_size(2) ...
        0 max(max(particles_each_stage_emission, ... 
        particles_each_stage_scattering))]);
    title('Number of Particles at Each Stage');
    xlabel('Stage');
    ylabel('N, Number of Particles');
    legend('Photons Emitted by Sample', ...
        'Emitted Photons Through Objective', ...
        'Emitted Photons Through Filters', ...
        'Number of Electrons from Emission in Camera', ...
        'Photons Scattered by Sample (Ignored)', ...
        'Scattered Photons Through Objective (Ignored)', ...
        'Scattered Photons Through Filters', ...
        'Number of Electrons from Scattering in Camera');
end

%% Noise
signal_photons = photons_from_emission_from_filters;
noise_photons =  photons_from_scattering_from_filters;
signal = number_of_electrons_from_emission;
noise_signal_error = sqrt(signal_photons);
noise_from_scattering = number_of_electrons_from_scattering;
noise_from_dark_current = integration_time*camera.dark_current;
noise_from_readout_noise = camera.readout_noise;
signal_to_noise_ratio = ...
    signal/(noise_from_scattering + ...
    noise_from_dark_current + noise_from_readout_noise);

if(debuglevel >= 0)
    disp("Signal Photons (counts)");
    disp(signal_photons);
    disp("Noise Photons (counts)");
    disp(noise_photons);
    disp("Signal Electrons (counts)");
    disp(signal);
    disp("Background Electrons (counts)");
    disp(noise_from_scattering);
    disp("Dark Current (e-/pixel)");
    disp(noise_from_dark_current);
    disp("Readout Noise (e- rms)");
    disp(noise_from_readout_noise);
    disp("Signal to Noise Ratio");
    disp(signal_to_noise_ratio);
end

%% Percent Change of Number of Particles between Each Stage
%{
  
% Percents for particles from emission
percent_remained_from_emission_sample_to_objective = 100*...
    photons_from_emission_in_objective/photons_emitted_by_sample;

percent_remained_from_emission_objective_to_filters = 100*...
    photons_from_emission_from_filters/photons_from_emission_in_objective;

percent_remained_from_emission_filters_to_electrons = 100*...
    number_of_electrons_from_emission/photons_from_emission_from_filters;

% Percents for particles form scattering
percent_remained_from_scattering_sample_to_objective = 100*...
    photons_from_scattering_in_objective/photons_scattered_by_sample;

percent_remained_from_scattering_objective_to_filters = 100*...
    photons_from_scattering_from_filters/...
    photons_from_scattering_in_objective;

percent_remained_from_scattering_filters_to_electrons = 100*...
    number_of_electrons_from_scattering/...
    photons_from_scattering_from_filters;

% Debugging this section
if(debuglevel >= 125)
    % Display percent change from emission
    disp(...
'Percent remained of photons (from emission) from sample to objective');
    disp(percent_remained_from_emission_sample_to_objective);
    disp(...
'Percent remained of photons (from emission) from objective to filters');
    disp(percent_remained_from_emission_objective_to_filters);
    disp(...
'Percent remained of particles (from emission) from filters to camera');
    disp(percent_remained_from_emission_filters_to_electrons);
    
    % Display percent change from scattering
    disp(...
'Percent remained of photons (from scattering) from sample to objective');
    disp(percent_remained_from_scattering_sample_to_objective);
    disp(...
'Percent remained of photons (from scattering) from objective to filters');
    disp(percent_remained_from_scattering_objective_to_filters);
    disp(...
'Percent remained of particles (from scattering) from filters to camera');
    disp(percent_remained_from_scattering_filters_to_electrons);
end

%}

%% End of Program
% Variables that are structs
camera;
dye; 
filterset; 
lightsource; 
objective;

% Guessed variables
n_glass;
integration_time;
scattering_coefficent;

% Reset values or settings
xticks('auto');

% Clear unused variables
% clear dye_excitation_resampled;
%close all;