%% Test Fluorescense_Particles;
f = Fluorescense_Particles();

%% Constants
n_glass = 1.56;                 % Guess for the coverslip
n_medium = n_glass;             % 
integration_time = 1/30;        % seconds (guess for now)
c = 299792458;                  % m/s
h = 6.626068E-34;               % Joules/Hz =  m2 kg / s
electron = 1.60217646E-19;      % coulombs
avogadro = 6.022045E23;         % molecules/mol

%% Data for testing

lightsource = blueLEDm470L3(); 
filterset = filterset1;         
lambda = filterset.wavelength;
dye = alexa488();
objective.M = 60;
objective.NA = 1.45; 
objective.n_medium = 1.56;
camera = andorX8250camera();

%% Data enter Test
f.lightsource.wavelength = lightsource.wavelength;
f.lightsource.spectral_radiance = lightsource.spectral_radiance;
f.filterset.wavelength = filterset.wavelength;
f.filterset.excitation_transmission = filterset.excitation_transmission;
f.filterset.emission_transmission = filterset.emission_transmission;
f.filterset.dichroic_transmission = filterset.dichroic_transmission;
f.dye.wavelength = dye.wavelength;
f.dye.excitation_spectrum = dye.excitation_spectrum;
f.dye.emission_spectrum = dye.emission_spectrum;
f.dye.absorption_coefficent = dye.sigma;
f.dye.scattering_coefficent = 1e-13;
f.dye.quantum_yield = dye.quantum_yield;
f.dye.lifetime = dye.lifetime;
f.objective.M = objective.M;
f.objective.NA = objective.NA;
f.objective.n_medium = objective.n_medium;
f.camera.wavelength = camera.wavelength;
f.camera.quantum_efficiency = camera.quantum_efficiency;
f.default_wavelength = lambda;

disp('Check of Default Wavelength');
disp(f.checkDefaultWavelength(lambda));

disp('Checking data is equal');
disp(isequal(f.lightsource.wavelength,lightsource.wavelength));
disp(isequal(f.lightsource.spectral_radiance,lightsource.spectral_radiance));
disp(isequal(f.filterset.wavelength,filterset.wavelength));
disp(isequal(f.filterset.excitation_transmission,filterset.excitation_transmission));
disp(isequal(f.filterset.emission_transmission,filterset.emission_transmission));
disp(isequal(f.filterset.dichroic_transmission,filterset.dichroic_transmission));
disp(isequal(f.dye.wavelength,dye.wavelength));
disp(isequal(f.dye.excitation_spectrum,dye.excitation_spectrum));
disp(isequal(f.dye.emission_spectrum,dye.emission_spectrum));
disp(isequal(f.dye.absorption_coefficent,dye.sigma));
disp(isequal(f.dye.scattering_coefficent,1e-13));
disp(isequal(f.dye.lifetime,dye.lifetime));
disp(isequal(f.objective.M,objective.M));
disp(isequal(f.objective.n_medium,objective.n_medium));
disp(isequal(f.camera.wavelength,camera.wavelength));
disp(isequal(f.camera.quantum_efficiency,camera.quantum_efficiency));

f.resampleAll();
resample1 = resample_data(lightsource.spectral_radiance, ...
        lightsource.wavelength, lambda);
resample2 = resample_data(dye.excitation_spectrum, ...
    dye.wavelength, lambda);
resample3 = resample_data(dye.emission_spectrum, ...
    dye.wavelength, lambda);
resample4 = resample_data(camera.quantum_efficiency, ...
    camera.wavelength, lambda);

disp('Checking Resampling');
disp(isequal(f.lightsource.spectral_radiance, resample1));
disp(isequal(f.dye.excitation_spectrum, resample2));
disp(isequal(f.dye.emission_spectrum, resample3));
disp(isequal(f.camera.quantum_efficiency, resample4));

%% Transmission Test
spectral_radiance_from_src_resampled = ...
    resample_data(lightsource.spectral_radiance, ...
        lightsource.wavelength, lambda);
spectral_radiance_on_sample = ...  
    spectral_radiance_from_src_resampled.*...
    filterset.excitation_transmission.*...
    (1 - filterset.dichroic_transmission)*n_medium^2;
photon_spectral_radiance_on_sample_rate = spectral_radiance_on_sample./...
    (h*c./lambda);
photon_radiance_on_sample_rate = ...
    trapni(photon_spectral_radiance_on_sample_rate, lambda);

f.calculateTransmission();
data1 = f.transmission.spectral_radiance_on_sample;
data2 = f.transmission.photon_spectral_radiance_on_sample_rate;
data3 = f.transmission.photon_radiance_on_sample_rate;

disp('Checking Transmission');
disp(isequal(data1,spectral_radiance_on_sample));
disp(isequal(data2,photon_spectral_radiance_on_sample_rate));
disp(isequal(data3,photon_radiance_on_sample_rate));

%% Irradiance Radiance Test
Omega = 2*pi*(1 - sqrt(1 - (objective.NA/n_medium)^2));
photon_irradiance_on_sample_rate = ...
    photon_radiance_on_sample_rate*Omega;
photon_spectral_irradiance_on_sample_rate = ...
    photon_spectral_radiance_on_sample_rate*Omega;

f.calculateRadianceIrradiance();
data1 = f.radiance_irradiance.Omega;
data2 = f.radiance_irradiance.photon_irradiance_on_sample_rate;
data3 = f.radiance_irradiance.photon_spectral_irradiance_on_sample_rate;

disp('Checking Irradiance Radiance');
disp(isequal(data1,Omega));
disp(isequal(data2,photon_irradiance_on_sample_rate));
disp(isequal(data3,photon_spectral_irradiance_on_sample_rate));

%% Absorption and Emission Test
absorption_coefficent = dye.sigma;
photons_absorbed_by_sample_rate = ...
    photon_irradiance_on_sample_rate*absorption_coefficent;
photons_emitted_by_sample_rate = dye.quantum_yield*...
    1/(1/photons_absorbed_by_sample_rate + dye.lifetime);

f.calulateAbsorptionEmission();
data1 = f.absorption_emission.photons_absorbed_by_sample_rate;
data2 = f.absorption_emission.photons_emitted_by_sample_rate;

disp('Checking Absorption Emission');
disp(isequal(data1,photons_absorbed_by_sample_rate));
disp(isequal(data2,photons_emitted_by_sample_rate));

%% Through Solid Angle Test
Omega = 2*pi*(1 - sqrt(1 - (objective.NA/n_medium)^2));
photons_from_emission_in_objective_rate = ...
    photons_emitted_by_sample_rate*Omega/4/pi;

f.calculateThroughObjective();
data1 = f.through_objective.Omega;
data2 = f.through_objective.photons_from_emission_in_objective_rate;

disp('Checking Through Solid Angle');
disp(isequal(data1,Omega));
disp(isequal(data2,photons_from_emission_in_objective_rate));

%% Through Filters Test
norm = trapni(resample3, lambda);
photons_spectral_from_emission_in_filters_rate = ...
    photons_from_emission_in_objective_rate*...
    resample3/norm;
photons_spectral_from_emission_from_filters_rate = ...
    photons_spectral_from_emission_in_filters_rate.*...
    filterset.emission_transmission.*...
    filterset.dichroic_transmission;
photons_from_emission_from_filters_rate = ...
    trapni(photons_spectral_from_emission_from_filters_rate, lambda);

f.calculateThroughFilters();
data1 = f.through_filters.norm;
data2 = f.through_filters.photons_spectral_from_emission_in_filters_rate;
data3 = f.through_filters.photons_spectral_from_emission_from_filters_rate;
data4 = f.through_filters.photons_from_emission_from_filters_rate;

disp('Checking Through Filters');
disp(isequal(data1,norm));
disp(isequal(data2,photons_spectral_from_emission_in_filters_rate));
disp(isequal(data3,photons_spectral_from_emission_from_filters_rate));
disp(isequal(data4,photons_from_emission_from_filters_rate));

%% Checking To Camera
electrons_spectral_from_emission_camera_rate = ...
    photons_spectral_from_emission_from_filters_rate.*...
    (resample4/100);
electrons_spectral_from_emission_camera = ...
    electrons_spectral_from_emission_camera_rate*integration_time;
number_of_electrons_from_emission = ...
    trapni(electrons_spectral_from_emission_camera, lambda);
photons_spectral_emission_from_filters = ...
    photons_spectral_from_emission_from_filters_rate*integration_time;

f.calculateToCamera();
data1 = f.to_camera.electrons_spectral_from_emission_camera_rate;
data2 = f.to_camera.electrons_spectral_from_emission_camera;
data3 = f.to_camera.number_of_electrons_from_emission;
data4 = f.to_camera.photons_spectral_emission_from_filters;

disp('Checking To Camera');
disp(isequal(data1,electrons_spectral_from_emission_camera_rate));
disp(isequal(data2,electrons_spectral_from_emission_camera));
disp(isequal(data3,number_of_electrons_from_emission));
disp(isequal(data4,photons_spectral_emission_from_filters));

%% Checking Scattering
scattering_coefficent = 1e-13;
photons_spectral_scattering_from_sample_rate = ...
    photon_spectral_irradiance_on_sample_rate*scattering_coefficent;
photons_scattering_from_sample_rate = ...
    trapni(photons_spectral_scattering_from_sample_rate, lambda);
photons_spectral_from_scattering_in_objective_rate = ...
    photons_spectral_scattering_from_sample_rate*(Omega/(4*pi));
photons_scattered_in_objective_rate = ...
    trapni(photons_spectral_from_scattering_in_objective_rate, lambda);
photons_spectral_from_scattering_from_filters_rate = ...
    photons_spectral_from_scattering_in_objective_rate.*...
    filterset.emission_transmission.*...
    filterset.dichroic_transmission;
photons_from_scattering_from_filters_rate = ...
    trapni(photons_spectral_from_scattering_from_filters_rate, lambda);
electrons_spectral_from_scattering_camera_rate = ...
    photons_spectral_from_scattering_from_filters_rate.*...
    (resample4/100);
electrons_spectral_from_scattering_camera = ...
    electrons_spectral_from_scattering_camera_rate*integration_time;
number_of_electrons_from_scattering = ...
    trapni(electrons_spectral_from_scattering_camera, lambda);
photons_spectral_scattered_from_filters = ...
    photons_spectral_from_scattering_from_filters_rate*integration_time;
ratio_electrons_from_emission_electrons_from_scattering = ...
    number_of_electrons_from_emission/number_of_electrons_from_scattering;

f.calculateScattering();
data1 = f.scattering.photons_spectral_scattering_from_sample_rate;
data2 = f.scattering.photons_scattering_from_sample_rate;
data3 = f.scattering.photons_spectral_from_scattering_in_objective_rate;
data4 = f.scattering.photons_scattered_in_objective_rate;
data5 = f.scattering.photons_spectral_from_scattering_from_filters_rate;
data6 = f.scattering.photons_from_scattering_from_filters_rate;
data7 = f.scattering.electrons_spectral_from_scattering_camera_rate;
data8 = f.scattering.electrons_spectral_from_scattering_camera;
data9 = f.scattering.number_of_electrons_from_scattering;
data10 = f.scattering.photons_spectral_scattered_from_filters;
data11 = f.scattering.ratio_electrons_from_emission_electrons_from_scattering;

disp('Checking Scattering');
disp(isequal(data1,photons_spectral_scattering_from_sample_rate));
disp(isequal(data2,photons_scattering_from_sample_rate));
disp(isequal(data3,photons_spectral_from_scattering_in_objective_rate));
disp(isequal(data4,photons_scattered_in_objective_rate));
disp(isequal(data5,photons_spectral_from_scattering_from_filters_rate));
disp(isequal(data6,photons_from_scattering_from_filters_rate));
disp(isequal(data7,electrons_spectral_from_scattering_camera_rate));
disp(isequal(data8,electrons_spectral_from_scattering_camera));
disp(isequal(data9,number_of_electrons_from_scattering));
disp(isequal(data10,photons_spectral_scattered_from_filters));
disp(isequal(data11,ratio_electrons_from_emission_electrons_from_scattering));

%% Checking Number of Particles
photons_emitted_by_sample = ...
    photons_emitted_by_sample_rate*integration_time;
photons_from_emission_in_objective = ...
    photons_from_emission_in_objective_rate*integration_time;
photons_from_emission_from_filters = ...
    photons_from_emission_from_filters_rate*integration_time;
number_of_electrons_from_emission;
photons_scattered_by_sample = ...
    photons_scattering_from_sample_rate*integration_time;
photons_from_scattering_in_objective = ...
    photons_scattered_in_objective_rate*integration_time;
photons_from_scattering_from_filters = ...
    photons_from_scattering_from_filters_rate*integration_time;
number_of_electrons_from_scattering;
stage_number = [1, 2, 3, 4];
stage_number_size = size(stage_number);
particles_each_stage_emission = [photons_emitted_by_sample, ...
    photons_from_emission_in_objective, ...
    photons_from_emission_from_filters, ...
    number_of_electrons_from_emission];
particles_each_stage_scattering = [-1e10, ...
    -1e10, ...
    photons_from_scattering_from_filters, ...
    number_of_electrons_from_scattering];

f.calculateNumberOfParticles();
data1 = f.number_of_particles.photons_emitted_by_sample;
data2 = f.number_of_particles.photons_from_emission_in_objective;
data3 = f.number_of_particles.photons_from_emission_from_filters;
data4 = f.number_of_particles.number_of_electrons_from_emission;
data5 = f.number_of_particles.photons_scattered_by_sample;
data6 = f.number_of_particles.photons_from_scattering_in_objective;
data7 = f.number_of_particles.photons_from_scattering_from_filters;
data8 = f.number_of_particles.number_of_electrons_from_scattering;
data9 = f.number_of_particles.stage_number;
data10 = f.number_of_particles.stage_number_size;
data11 = f.number_of_particles.particles_each_stage_emission;
data12 = f.number_of_particles.particles_each_stage_scattering;

disp('Checking Number of Particles');
disp(isequal(data1,photons_emitted_by_sample));
disp(isequal(data2,photons_from_emission_in_objective));
disp(isequal(data3,photons_from_emission_from_filters));
disp(isequal(data4,number_of_electrons_from_emission));
disp(isequal(data5,photons_scattered_by_sample));
disp(isequal(data6,photons_from_scattering_in_objective));
disp(isequal(data7,photons_from_scattering_from_filters));
disp(isequal(data8,number_of_electrons_from_scattering));
disp(isequal(data9,stage_number));
disp(isequal(data10,stage_number_size));
disp(isequal(data11,particles_each_stage_emission));
disp(isequal(data12,particles_each_stage_scattering));

%% Checking Percentages
percent_remained_from_emission_sample_to_objective = 100*...
    photons_from_emission_in_objective/photons_emitted_by_sample;
percent_remained_from_emission_objective_to_filters = 100*...
    photons_from_emission_from_filters/photons_from_emission_in_objective;
percent_remained_from_emission_filters_to_electrons = 100*...
    number_of_electrons_from_emission/photons_from_emission_from_filters;
percent_remained_from_scattering_sample_to_objective = 100*...
    photons_from_scattering_in_objective/photons_scattered_by_sample;
percent_remained_from_scattering_objective_to_filters = 100*...
    photons_from_scattering_from_filters/...
    photons_from_scattering_in_objective;
percent_remained_from_scattering_filters_to_electrons = 100*...
    number_of_electrons_from_scattering/...
    photons_from_scattering_from_filters;

f.calculatePercents();
data1 = f.percentages.percent_remained_from_emission_sample_to_objective;
data2 = f.percentages.percent_remained_from_emission_objective_to_filters;
data3 = f.percentages.percent_remained_from_emission_filters_to_electrons;
data4 = f.percentages.percent_remained_from_scattering_sample_to_objective;
data5 = f.percentages.percent_remained_from_scattering_objective_to_filters;
data6 = f.percentages.percent_remained_from_scattering_filters_to_electrons;

disp('Checking Percentages');
disp(isequal(data1,percent_remained_from_emission_sample_to_objective));
disp(isequal(data2,percent_remained_from_emission_objective_to_filters));
disp(isequal(data3,percent_remained_from_emission_filters_to_electrons));
disp(isequal(data4,percent_remained_from_scattering_sample_to_objective));
disp(isequal(data5,percent_remained_from_scattering_objective_to_filters));
disp(isequal(data6,percent_remained_from_scattering_filters_to_electrons));


%% Displaying Data

f.dispData(100);
f.dispFigures(100);