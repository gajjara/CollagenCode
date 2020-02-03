%Script with only calculations

%% Constants, Experiment Parameters, Dye Characteristics, and Microscope Objective 
n_glass=1.56; % Guess for the coverslip
n_medium=n_glass; %
integration_time=1/30; % second (guess for now)
%Constants
c=299792458; % m/s
h=6.626068E-34; % Joules/Hz =  m2 kg / s
electron=1.60217646E-19; % coulombs
avogadro=6.022045E23; %  molecules/mol
%Experiment Parameters
lightsource=blueLEDm470L3(); % Use the Thorlabs blue LED source 
filterset=filterset1; % Mohammad's filter set for fluorescence
lambda=filterset.wavelength; % Use the wavelength axis of the
                             % filter set for all plots
%Dye Characteristics
dye=alexa488();
dye_excitation_resampled=zeros(size(lambda));
dye_emission_resampled=zeros(size(lambda));
test=find((dye.wavelength(2)<lambda)&...
     (dye.wavelength(end-1)>lambda));
dye_excitation_resampled(test)=...
 linterp(dye.wavelength,dye.excitation_spectrum,...
	lambda(test));
dye_emission_resampled(test)=...
  linterp(dye.wavelength,dye.emission_spectrum,...
	lambda(test));
%Microscope Objective
objective.M=60;
objective.NA=1.45; 


%% Transmit through ex filter, reflect from dichroic
% Multiply by n_medium^2 to get radiance in medium
spectral_radiance_resampled = zeros(size(lambda));
test = find(( lightsource.wavelength(2) < lambda) & (lightsource.wavelength(end-1) > lambda));
spectral_radiance_resampled(test) = linterp(lightsource.wavelength, lightsource.spectral_radiance, lambda(test));


                              %? .* excitation trans .* (1-dichrome trans) * n_medium^2                     
spectral_radiance_on_target = spectral_radiance_resampled .* filterset.excitation_transmission.* (1-filterset.dichroic_transmission)*n_medium^2;

                                   % spectral radiance/(hc/lambda)
photon_spectral_radiance_on_target = spectral_radiance_on_target./(h*c./lambda);
                          
                            %integrates spectral radiance over each wavelength 
photon_radiance_on_target = trapni(photon_spectral_radiance_on_target,lambda);

%% Photon Irradiance at Target

%Omega = 2pi*(1-sqrt(1-(NA/n_medium)^2)) ?
Omega = 2*pi*(1-sqrt(1-(objective.NA/n_medium)^2));

%Irradiance = radiance*Omega (L*Omega)
photon_irradiance_on_target = photon_radiance_on_target*Omega;

%% Emitted Photons
                 % Irradiance * Sigma
photons_absorbed = photon_irradiance_on_target*dye.sigma;

                 %Quantum yield? * (photons absorbed * dye_lifetime)
photons_emitted = dye.quantum_yield*(1/(1/photons_absorbed+dye.lifetime));


%% Received Photons
       %Omega  as calculated above
Omega = 2*pi*(1-sqrt(1-(objective.NA/n_medium)^2));

                       % Emission*(Omega/4)*(PI*Integration_time)
photons_in_solid_angle = photons_emitted*Omega/4/pi*integration_time;

       %Emission though dye integrated over lambda ?
norm = trapni(dye_emission_resampled,lambda);
                                %Emission*Dye_Emission/(Dye emission integrated over lambda)
photons_emitted_per_wavelength = photons_emitted*dye_emission_resampled/norm;
                                        
                                        %Emission per wavelength*emission_transmission?*dichrome_transmission
photons_through_filter_per_wavelength = photons_emitted_per_wavelength.*filterset.emission_transmission.*filterset.dichroic_transmission;

                        %Photons_per_wavelength integrated over lambda
photons_through_filter = trapni(photons_through_filter_per_wavelength,lambda);
