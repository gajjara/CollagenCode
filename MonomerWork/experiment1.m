% /home/dimarzio/Documents/notes/peoplef/mohammadsiadat/experiment1.m
% Fri Jun 14 12:21:53 2019
% Chuck DiMarzio, Northeastern University
%
debuglevel=100;
n_glass=1.56; % Guess for the coverslip
n_medium=n_glass; %
integration_time=1/30; % second (guess for now)

%% Constants -------------------------------
c=299792458; % m/s
h=6.626068E-34; % Joules/Hz =  m2 kg / s
electron=1.60217646E-19; % coulombs
avogadro=6.022045E23; %  molecules/mol
% ------------------------------------------

%% Experiment Parameters
lightsource=blueLEDm470L3(); % Use the Thorlabs blue LED source 

filterset=filterset1; % Mohammad's filter set for fluorescence
lambda=filterset.wavelength; % Use the wavelength axis of the
                             % filter set for all plots

%% Dye Characteristics
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

%% Microscope Objective
objective.M=60;
objective.NA=1.45; 

%% Transmit through ex filter, reflect from dichroic
% Multiply by n_medium^2 to get radiance in medium
spectral_radiance_resampled=zeros(size(lambda));
test=find((lightsource.wavelength(2)<lambda)&...
     (lightsource.wavelength(end-1)>lambda));
spectral_radiance_resampled(test)=...
linterp(lightsource.wavelength,lightsource.spectral_radiance,...
	lambda(test));

spectral_radiance_on_target=...
 spectral_radiance_resampled.*filterset.excitation_transmission.*...
    (1-filterset.dichroic_transmission)*n_medium^2;

photon_spectral_radiance_on_target=spectral_radiance_on_target./...
    (h*c./lambda);

photon_radiance_on_target=...
    trapni(photon_spectral_radiance_on_target,lambda);

if(debuglevel>40);
figure;
plot(lambda*1e9,filterset.excitation_transmission,'b',...
     lambda*1e9,1-filterset.dichroic_transmission,'g',...
     lambda*1e9,filterset.excitation_transmission.*...
                (1-filterset.dichroic_transmission),'r');
grid on;
xlabel('\lambda, Wavelength, nm');
ylabel('Filter');
legend('Excitation Transm','Dichroic Refl','Product');
end;

if(debuglevel>20);
figure;
plot(lightsource.wavelength*1e9,...
     lightsource.spectral_radiance/1e6/1e9, ...
	    'b',...
     lambda*1e9,...
     spectral_radiance_on_target/1e6/1e9,'r');
grid on;
xlabel('\lambda, Wavelength, nm');
ylabel('L_\lambda, Spectral Radiance, W/mm^2/sr/nm');
legend('At Source','On Target');
end;

if(debuglevel>10);
figure;
plot(lambda*1e9,...
     photon_spectral_radiance_on_target/1e6/1e9,'r');
grid on;
xlabel('\lambda, Wavelength, nm');
ylabel('L_{P\lambda}, Photon Spectral Radiance, Photons/s/mm^2/sr/nm');
end;

if(debuglevel>5);
  disp(photon_radiance_on_target/1e6);
  disp('Photons per second per mm^2 per steradian on target');
end;

%% Photon Irradiance at Target
Omega=2*pi*(1-sqrt(1-(objective.NA/n_medium)^2));
photon_irradiance_on_target=photon_radiance_on_target*Omega;

if(debuglevel>5);
  disp(photon_irradiance_on_target/1e6);
  disp('Photons per second per mm^2 on target');
end;

%% Emitted Photons
photons_absorbed=photon_irradiance_on_target*dye.sigma;
photons_emitted=dye.quantum_yield*...
    1/(1/photons_absorbed+dye.lifetime);

if(debuglevel>0);
  disp(photons_absorbed);
  disp('Photons per second absorbed');
  disp(photons_emitted);
  disp('Photons per second emitted');
end;

if(photons_absorbed>1/dye.lifetime);
  disp('Warning:  Fluorescence Saturation');
end;

%% Received Photons
Omega=2*pi*(1-sqrt(1-(objective.NA/n_medium)^2));
photons_in_solid_angle=photons_emitted*Omega/4/pi*integration_time;
if(debuglevel>0);
  disp(photons_in_solid_angle);
  disp('Photons in Solid Angle');
end;

% Filters on receiver
if(debuglevel>40);
figure;
plot(lambda*1e9,filterset.dichroic_transmission,'b',...
     lambda*1e9,filterset.emission_transmission,'g',...
     lambda*1e9,filterset.emission_transmission.*...
                filterset.dichroic_transmission,'r');
grid on;
xlabel('\lambda, Wavelength, nm');
ylabel('Filter');
legend('Dichroic Transm','Emission Transm','Product');
end;

norm=trapni(dye_emission_resampled,lambda);
photons_emitted_per_wavelength=photons_emitted*...
    dye_emission_resampled/norm;

if(debuglevel>10);
figure;
plot(lambda*1e9,...
     photons_emitted_per_wavelength/1e9,'b');
grid on;
xlabel('\lambda, Wavelength, nm');
ylabel('N_\lambda, Photons emitted per nm');
end;

photons_through_filter_per_wavelength=...
    photons_emitted_per_wavelength.*...
    filterset.emission_transmission.*...
    filterset.dichroic_transmission;

if(debuglevel>10);
figure;
plot(lambda*1e9,photons_emitted_per_wavelength/1e9,'b',...
     lambda*1e9,photons_through_filter_per_wavelength/1e9,'r');
grid on;
xlabel('\lambda, Wavelength, nm');
ylabel('N_\lambda, Photons emitted per nm');
legend('Before Filter Set','After Filter Set');
end;

photons_through_filter=...
    trapni(photons_through_filter_per_wavelength,lambda);
if(debuglevel>0);
  disp(photons_through_filter);
  disp('Photons Through Filter');
end;

