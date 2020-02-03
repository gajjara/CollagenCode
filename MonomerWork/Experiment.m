classdef Experiment < handle
    % Experiment Calculate Physical Values and Spectra For 
    %   Emissiom and Scattering from a sample and accounts for the 
    %   prescense of filters, an objective lens, and a camera.
    %
    %   What is calculated and determined is:
    %       Irradiance and radiance from the light source and on the sample
    %       Emission from the sample
    %       Scattering from the sample
    %       Transmission through the objective from
    %           both scattering and emission
    %       Transmission through the filters from 
    %           both scattering and emission
    %       Number of electrons excited within the camera from both the
    %           transmitted photons from emission and scattering
    %       The number of particles at each stage of the experiment
    %       Percentages based off the above values
    %       Noise
    % 
    %   Data required:
    %       Spectral radiance, wavelength, and name of the light source.
    %       Tranmission and wavelength of each filter in the filter set.
    %       Excitation and emission spectrum, wavelength, absorption
    %       coefficent, scattering coefficent, quantum yield, and lifetime
    %       of the sample.                                                        
    %       Refraction index, solid angle, and numerical aperture of the
    %       objecitve lens.
    %       Quantum efficiency and wavelength of the camera.
    %       A default wavelength to have each data set be resampled to.
    properties (Access = public)
        integration_time = 1;    % Time for integration (s) (1/30 for now)
    end
    properties (Hidden)
        c = 299792458;              % Speed of light (m/s)
        h = 6.626068E-34;           % Plank's Constant (Joules/Hz)(m^2*kg/s)
        electron = 1.60217646E-19;  % Electron charge (Coulombs)
        avogadro = 6.022045E23;     % Avagrado's constant (molecules/mol)
    end
    properties (Access = public)
        default_wavelength;         % The wavelength that all data 
                                    % is resampled to
    end
    properties (Access = public)
        %LIGHTSOURCE - Holds the spectral radiance, wavelength, and name of the lightsource
        %
        % Objects:
        %   wavelength - Wavelengths spectral data covers
        %   spectral_radiance - Spectral radiance of the lightsource
        %   name - Name of the lightsource (string object)
        %
        % Other m-files required: none
        % Subfunctions: none
        % MAT-files required: none
        lightsource = struct(...
            'wavelength', [], ... 
            'spectral_radiance', [], ...
            'name', []); 
        %FILTERSET - Holds the transmission spectra and wavelength of each filter
        %
        % Objects:
        %   wavelength - Wavelengths spectral data covers
        %   excitation_transmission - Transmission spectra of excitation
        %   filter
        %   emission_transmission - Transmission spectra of emission filter
        %   dichroic_transmission - Transmission spectar of dichroic filter
        %   
        % Other m-files required: none
        % Subfunctions: none
        % MAT-files required: none
        filterset = struct(... 
            'wavelength', [], ...
            'excitation_transmission', [], ...
            'emission_transmission', [], ...
            'dichroic_transmission', []); 
        %DYE - Holds the quantum and optical properties of the sample
        %
        % Objects:
        %   wavelength - Wavelengths spectral data covers
        %   excitation_spectrum - Excitation spectra of the sample
        %   emission_spectrum - Emission spectra of the sample
        %   absorption_coefficent - Absorption coefficent of the sample
        %   scattering_coefficent - Scattering coefficent of the sample
        %   quantum_yield - Quantum yield of the sample
        %   lifetime - Lifetime of the sample
        %
        % Other m-files required: none
        % Subfunctions: none
        % MAT-files required: none
        dye = struct( ...
            'wavelength', [],  ...
            'excitation_spectrum', [], ...
            'emission_spectrum', [], ...
            'absorption_coefficent', [], ...
            'scattering_coefficent', [], ...
            'quantum_yield', [], ...
            'lifetime', []);
        %OBJECTIVE - Holds the optical properties of the objective lens
        %
        % Objects:
        %   n_medium - Refractive index of the objective lens
        %   M - Solid angle of the objective lens
        %   NA - Numerical aperture of the objective lens
        %
        % Other m-files required: none
        % Subfunctions: none
        % MAT-files required: none
        objective = struct(...
            'n_medium', [], ...
            'M', [], ...
            'NA', []);
        %CAMERA - Holds the quantum efficiency and wavelength of the camera 
        %
        % Objects:
        %   wavelength - Wavelengths spectral data covers
        %   quantum_efficiency - Quantum efficiency spectra of the camera
        %   pixelcountx - Pixel count in x direction
        %   pixelcounty - Pixel count in y direction
        %   dark_current - The dark current of the camera
        %   readout_noise - The readout noise of the camera
        %
        % Other m-files required: none
        % Subfunctions: none
        % MAT-files required: none
        camera = struct(... 
            'wavelength', [], ...
            'quantum_efficiency', [], ...
            'pixelcountx', [], ...
            'pixelcounty', [], ...
            'dark_current', [], ...
            'readout_noise', []);
    end
    properties (Access = public)
        %EMISSION - Holds all the calculated properties from emission by the sample
        %
        % Objects:
        %   spectral_radiance_on_sample - Spectral radiance on the sample
        %   photon_spectral_radiance_on_sample_rate - Photon spectral
        %       radiance rate on the sample
        %   photon_radiance_on_sample_rate - Photon radiance rate on the
        %       sample
        %   Omega - Solid angle of the objective lens
        %   photon_irradiance_on_sample_rate - Photon irradiance rate on the
        %       sample
        %   photon_spectral_irradiance_on_sample_rate - Photon spectral
        %       irradiance rate on the sample
        %   photons_absorbed_by_sample_rate - Photon absorption rate by the
        %       sample
        %   photons_emitted_by_sample_rate - Photon emission rate by the
        %       sample
        %   photons_from_emission_in_objective_rate - Photons from emission
        %       tranmission rate through the objective lens
        %   norm - Normalization value for photon spectral transmission 
        %       onto the filters
        %   photons_spectral_from_emission_in_filters_rate - Photons from
        %       emission spectral transmission rate onto the filters
        %   photons_spectral_from_emission_from_filters_rate - Photons from
        %       emission spectral transmission rate from the filters
        %   photons_from_emission_from_filters_rate - Number of photons
        %       from emission that are transmitted through the filters
        %   electrons_spectral_from_emission_camera_rate - Spectral rate of
        %       electrons excited in the camera from emitted photons
        %   electrons_spectral_from_emission_camera - Spectral number of 
        %       electrons excited in the camera from emitted photons
        %   number_of_electrons_from_emission - Number of electrons
        %       excited in the camera from emitted photons
        %   photons_spectral_emission_from_filters - Photons from
        %       emission spectral transmission through the filters
        %
        % Other m-files required: Experiment.m
        % Subfunctions: none
        % MAT-files required: none
        emission = struct( ...
            'spectral_radiance_on_sample', [], ...
            'photon_spectral_radiance_on_sample_rate', [], ...
            'photon_radiance_on_sample_rate', [], ...
            'Omega', [], ...
            'photon_irradiance_on_sample_rate', [], ...
            'photon_spectral_irradiance_on_sample_rate', [], ...
            'photons_absorbed_by_sample_rate', [], ...
            'photons_emitted_by_sample_rate', [], ...
            'photons_from_emission_in_objective_rate', [], ...
            'norm', [], ...
            'photons_spectral_from_emission_in_filters_rate', [], ...
            'photons_spectral_from_emission_from_filters_rate', [], ...
            'photons_from_emission_from_filters_rate', [], ...
            'electrons_spectral_from_emission_camera_rate', [], ...
            'electrons_spectral_from_emission_camera', [], ...
            'number_of_electrons_from_emission', [], ...
            'photons_spectral_emission_from_filters', []);
        %SCATTERING - Holds all the calculated properties from scattering by the sample
        %
        % Objects:
        %   photons_spectral_scattering_from_sample_rate - Photon spectral
        %       scattering rate by the sample
        %   photons_scattering_from_sample_rate - Photon scattering rate by
        %       the sample
        %   photons_spectral_from_scattering_in_objective_rate - Photons
        %       from scattering tranmission rate through the objective lens
        %   photons_scattered_in_objective_rate - Photons from scattering
        %       transmission rate through the objective lens
        %   photons_spectral_from_scattering_from_filters_rate - Photons 
        %       from scattering spectral transmission rate from the filters
        %   photons_from_scattering_from_filters_rate - Photons from
        %       scattering transmission rate from the filters
        %   electrons_spectral_from_scattering_camera_rate - Spectral rate
        %       of electrons excited in the camera from scattered photons
        %   electrons_spectral_from_scattering_camera - Spectral number of
        %       electrons excited in the camera from scattered photons
        %   number_of_electrons_from_scattering - Number of electrons
        %       excited in the camera from emitted photons
        %   photons_spectral_scattered_from_filters - Photons from
        %       scattering spectral transmission through the filters
        %   ratio_electrons_from_emission_electrons_from_scattering - Ratio
        %       of electrons from emission to electrons from scattering
        %   
        % Other m-files required: Experiment.m
        % Subfunctions: none
        % MAT-files required: none
        scattering = struct( ...
            'photons_spectral_scattering_from_sample_rate', [], ...
            'photons_scattering_from_sample_rate', [], ...
            'photons_spectral_from_scattering_in_objective_rate', [], ...
            'photons_scattered_in_objective_rate', [], ...
            'photons_spectral_from_scattering_from_filters_rate', [], ...
            'photons_from_scattering_from_filters_rate', [], ...
            'electrons_spectral_from_scattering_camera_rate', [], ...
            'electrons_spectral_from_scattering_camera', [], ...
            'number_of_electrons_from_scattering', [], ...
            'photons_spectral_scattered_from_filters', [], ...
            'ratio_electrons_from_emission_electrons_from_scattering', []);
        %NUMBER_OF_PARTICLES - Stores the number of particles at each stage of the experiment
        %
        % Objects:
        %   photons_emitted_by_sample - Number of photons emitted by the sample
        %   photons_from_emission_in_objective - Number of photons from
        %       emission transmitted through the objective lens
        %   photons_from_emission_from_filters - Number of photons from
        %       emission transmitted through the filters
        %   number_of_electrons_from_emission - Number of electrons excited
        %       in the camera from emitted photons
        %   photons_scattered_by_sample - Number of photons scattered by
        %       the sample
        %   photons_from_scattering_in_objective - Number of photons from
        %       scattering transmitted through the objective lens
        %   photons_from_scattering_from_filters - Number of photons from
        %       scattering transmitted through the filters
        %   number_of_electrons_from_scattering - Number of electrons
        %       exited in the camera from scattered photons
        %   stage_number
        %   stage_number_size
        %   particles_each_stage_emission
        %   particles_each_stage_scattering
        %
        % Other m-files required: Experiment.m
        % Subfunctions: none
        % MAT-files required: none
        number_of_particles = struct( ...
            'photons_emitted_by_sample', [], ...
            'photons_from_emission_in_objective', [], ...
            'photons_from_emission_from_filters', [], ...
            'number_of_electrons_from_emission', [], ...
            'photons_scattered_by_sample', [], ...
            'photons_from_scattering_in_objective', [], ...
            'photons_from_scattering_from_filters', [], ...
            'number_of_electrons_from_scattering', [], ...
            'stage_number', [], ...
            'stage_number_size', [], ...
            'particles_each_stage_emission', [], ...
            'particles_each_stage_scattering', []);
        %PERCENTAGES - Stores the percent of particles remaining at each stage
        %
        % Objects:
        %   percent_remained_from_emission_sample_to_objective - Percentage
        %       of particles remained from sample emission to objective
        %       transmission (emission)
        %   percent_remained_from_emission_objective_to_filters -
        %       Percentage of particles remained from objective
        %       transmission to filter transmission (emission)
        %   percent_remained_from_emission_filters_to_electrons -
        %       Percentage of particles remained from filter transmission
        %       to electron excitation (emission)
        %   percent_remained_from_scattering_sample_to_objective - Percentage
        %       of particles remained from sample scattering to objective
        %       transmission (scattering)
        %   percent_remained_from_scattering_objective_to_filters -
        %       Percentage of particles remained from objective
        %       transmission to filter transmission (scattering)
        %   percent_remained_from_scattering_filters_to_electrons -
        %       Percentage of particles remained from filter transmission
        %       to electron excitation (scattering)
        %
        % Other m-files required: Experiment.m
        % Subfunctions: none
        % MAT-files required: none
        percentages = struct( ...
            'percent_remained_from_emission_sample_to_objective', [], ...
            'percent_remained_from_emission_objective_to_filters', [], ...
            'percent_remained_from_emission_filters_to_electrons', [], ...
            'percent_remained_from_scattering_sample_to_objective', [], ...
            'percent_remained_from_scattering_objective_to_filters', [], ...
            'percent_remained_from_scattering_filters_to_electrons', []);
        %NOISE - Stores the number of electrons that produce signal and
        %noise and ratios between noise and signal
        %
        % Objects:
        %   signal_photons - The number of photons that develops signal
        %   noise_photons - The number of photons that develops noise
        %   signal - The number of electrons (electrons from emission) that
        %       produce a signal within the camera
        %   noise_signal_error - The noise generated from the signal error
        %   noise_from_scattering - The number of electrons that produce
        %       noise within the camera
        %   noise_from_dark_current - The number of electrons that produce
        %       noise from the dark current of the camera
        %   noise_from_readout_noise - The number of electrons that produce
        %       noise from the readout noise of the camera
        %   signal_to_noise_ratio - The signal to noise ratio
        %
        % Other m-files required: Experiment.m
        % Subfunctions: none
        % MAT-files required: none
        noise = struct( ...
            'signal_photons', [], ...
            'noise_photons', [], ...
            'signal', [], ...
            'noise_signal_error', [], ...
            'noise_from_scattering', [], ...
            'noise_from_dark_current', [], ...
            'noise_from_readout_noise', [], ...
            'signal_to_noise_ratio', []);
    end
    methods
        function obj = Experiment(varargin)
            %Constructor of Experiment class
            %Experiment() constructs the object without filling
            %   initial properties
            %Experiment(lightsource, filterset, sample,
            %objective, camera, default_wavelength, debuglevel) constructs
            %   the object with initial properties filled and executes all
            %   functions in the object and fills all properties
            %Experiment(lightsource, filterset, sample,
            %objective, camera, default_wavelength, debuglevel, descriptor)
            %   constructs the object with initial properties filled and
            %   executes all functions in the object and fills all
            %   properties with a descriptor
            %
            % Syntax:   Experiment
            %           Experiment();
            %           Experiment(lightsource, filterset,
            %           sample, objective, camera, default_wavelength,
            %           debuglevel);
            %           Experiment(lightsource, filterset,
            %           sample, objective, camera, default_wavelength,
            %           debuglevel, descriptor);
            %           
            %           f = Experiment();
            %           f = Experiment(__);
            %
            % Inputs:
            %   lightsource - Holds the spectral radiance, wavelength, and name of the lightsource 
            %   filterset - Holds the transmission spectra and wavelength of each filter 
            %   sample - Holds the quantum and optical properties of the sample 
            %   objective - Holds the optical properties of the objective lens 
            %   camera - Holds the quantum efficiency and wavelength of the camera  
            %   default_wavelength - Sets the default wavelength of the
            %       object
            %   debuglevel - Sets the amount of data and figures shown
            %   descriptor - A descriptor to add onto figures and displays
            %   
            % Outputs:
            %   f - Returns the Experiment object
            %
            % Other m-files required: See EXPERIMENT
            % Subfunctions: See EXPERIMENT
            % MAT-files required: none
            %
            % See also: EXPERIMENT
            if nargin ~= 7
            end
            if nargin == 7
                obj.executeAll(varargin{1}, varargin{2}, varargin{3}, ...
                    varargin{4}, varargin{5}, varargin{6}, varargin{7});
            end
            if nargin == 8
                obj.executeAllIntTime(varargin{1}, varargin{2}, varargin{3}, ...
                    varargin{4}, varargin{5}, varargin{6}, ...
                    varargin{7}, varargin{8});
            end
            
                
        end
        function set.integration_time(obj, val)
            obj.integration_time = val;
        end
        function set.c(obj, val)
            obj.c = val;
        end
        function set.h(obj, val)
            obj.h = val;
        end
        function set.electron(obj, val)
            obj.electron = val;
        end
        function set.avogadro(obj, val)
            obj.avogadro = val;
        end
        function setAllConstants(obj, val)
            %SETALLCONSTANTS - Sets all constants of the class
            %
            % Syntax:  f = Experiment
            %          f.setAllConstants(val)
            %
            % Inputs:
            %    val - A struct that contains the following constants in
            %       this order: 
            %           integration_time - Integration time
            %           c - Speed of light
            %           h - Plank's Constant
            %           electron - Charge of Electron
            %           avogadro - Avogadros Constant
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, CHECKALLCONSTANTS
            if(isa(val, 'numeric') || isa(val, 'float') || ...
                    isa(val, 'integer') && val.size == 5)
                try
                    obj.integration_time = val(1);
                    obj.c = val(2);
                    obj.h = val(3);
                    obj.electron = val(4);
                    obj.avogadro = val(5);
                catch exception
                    disp('All constants could not be set.');
                   disp('Try again or use each individual setter methods');
                end
            else
                disp('An array was not inputted to set all the constants');
            end
        end
        function val = get.integration_time(obj)
            val = obj.integration_time;
        end
        function val = get.c(obj)
            val = obj.c;
        end
        function val = get.h(obj)
            val = obj.h;
        end
        function val = get.electron(obj)
            val = obj.electron;
        end
        function val = get.avogadro(obj)
            val = obj.avogadro;
        end
        function setLightsource(obj, lightsource)
            %SETLIGHTSOURCE - Sets all initial data required for the
            %lightsource struct within the object
            %
            % Syntax:  f = Experiment
            %          f.setLightsource(lightsource)
            %
            % Inputs:
            %   lightsource - Holds the spectral radiance, wavelength, and name of the lightsource 
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, SETINITIALDATA
            obj.lightsource.wavelength = lightsource.wavelength;
            obj.lightsource.spectral_radiance = ...
                lightsource.spectral_radiance;
            obj.lightsource.name = lightsource.name;
        end
        function setFilterset(obj, filterset) 
            %SETFILTERSET - Sets all initial data required for the filterset
            %
            % Syntax:  f = Experiment
            %          f.setFilterset(filterset)
            %
            % Inputs:
            %   filterset - Holds the transmission spectra and wavelength of each filter 
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, SETINITIALDATA
            obj.filterset.wavelength = filterset.wavelength;
            obj.filterset.excitation_transmission = ...
                filterset.excitation_transmission;
            obj.filterset.emission_transmission = ...
                filterset.emission_transmission;
            obj.filterset.dichroic_transmission = ...
                filterset.dichroic_transmission;
        end
        function setDye(obj, dye)
            %SETDYE - Sets all initial data for the sample
            %
            % Syntax:  f = Experiment
            %          f.setDye(dye)
            %
            % Inputs:
            %   dye - Holds the quantum and optical properties of the sample
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, SETINITIALDATA
            obj.dye.wavelength = dye.wavelength;
            obj.dye.excitation_spectrum = dye.excitation_spectrum;
            obj.dye.emission_spectrum = dye.emission_spectrum;
            obj.dye.absorption_coefficent = dye.absorption_coefficent;
            obj.dye.scattering_coefficent = dye.scattering_coefficent;
            obj.dye.quantum_yield = dye.quantum_yield;
            obj.dye.lifetime = dye.lifetime;            
        end
        function setObjective(obj, objective)
            %SETOBJECTIVE - Sets all initial data for the objective lens
            %
            % Syntax:  f = Experiment
            %          f.setObjective(objective)
            %
            % Inputs:
            %   objective - Holds the optical properties of the objective lens 
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, SETINITIALDATA
            obj.objective.n_medium = objective.n_medium;
            obj.objective.M = objective.M;
            obj.objective.NA = objective.NA;
        end
        function setCamera(obj, camera)
            %SETCAMERA - Sets all initial data for the camera
            %
            % Syntax:  f = Experiment
            %          f.setCamera(camera)
            %
            % Inputs:
            %   camera - Holds the quantum efficiency and wavelength of the camera
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, SETINITIALDATA
            obj.camera.wavelength = camera.wavelength;
            obj.camera.quantum_efficiency = camera.quantum_efficiency;
            obj.camera.pixelcountx = camera.pixelcountx;
            obj.camera.pixelcounty = camera.pixelcounty;
            obj.camera.dark_current = camera.dark_current;
            obj.camera.readout_noise = camera.readout_noise;
        end
        function setInitialData ...
                (obj, lightsource, filterset, dye, ...
                objective, camera, wavelength)
            %SETINITIALDATA - Sets all initial data for the class
            %
            % Syntax:  f = Experiment
            %          f.FUNCTION_NAME(lightsource, filterset, dye,
            %          objective, camera, wavelength);
            %
            % Inputs:
            %   lightsource - Holds the spectral radiance, wavelength, and name of the lightsource 
            %   filterset - Holds the transmission spectra and wavelength of each filter 
            %   dye - Holds the quantum and optical properties of the sample 
            %   objective - Holds the optical properties of the objective lens 
            %   camera - Holds the quantum efficiency and wavelength of the camera
            %   wavelength - The default wavelength of the class
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT
            obj.setLightsource(lightsource);
            obj.setFilterset(filterset);
            obj.setDye(dye);
            obj.setObjective(objective);
            obj.setCamera(camera);
            obj.default_wavelength = wavelength;
        end
        function displayAllConstants(obj)
            %DISPLAYALLCONSTANTS - Displays all constant values of the class
            %
            % Syntax:  f = Experiment
            %          f.displayAllConstants()
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, SETALLCONSTANTS,
            % CHECKALLCONSTANTS
            disp('Integration time');
            disp(obj.integration_time);
            disp('Speed of Light');
            disp(obj.c);
            disp('Planks Constant');
            disp(obj.h);
            disp('Electron Charge');
            disp(obj.electron);
            disp('Avagadro Constant');
            disp(obj.avogadro);
        end
        function check = checkAllConstants(obj, val)
            %CHECKALLCONSTANTS - Checks if all the constant values of the class are correct
            %
            % Syntax:  f = Experiment
            %          f.setAllConstants(val)
            %
            % Inputs:
            %    val - A struct that contains the following constants in
            %       this order: 
            %           integration_time - Integration time
            %           c - Speed of light
            %           h - Plank's Constant
            %           electron - Charge of Electron
            %           avogadro - Avogadros Constant
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, SETALLCONSTANTS
            if(isa(val, 'numeric') || isa(val, 'float') || ...
                    isa(val, 'integer') && val.size == 5)
                try
                    test1 = isequal(obj.integration_time, val(1));
                    test2 = isequal(obj.c, val(2));
                    test3 = isequal(obj.h, val(3));
                    test4 = isequal(obj.electron, val(4));
                    test5 = isequal(obj.avogadro, val(5));
                    alltest = isequal(test1, test2, test3, test4, test5);
                    check = alltest;
                catch exception
                    disp('All constants could not be checked.');
                end
            else
              disp('An array was not inputted to check all the constants');
            end
            clear test1 test2 test3 test4 test5 alltest;
        end    
        function set.default_wavelength(obj, val)
            obj.default_wavelength = val;
        end
        function val = get.default_wavelength(obj)
            val = obj.default_wavelength;
        end
        function check = checkDefaultWavelength(obj, val)
            %CHECKDEFAULTWAVELENGTH - Checks that the default wavelength is
            %valid
            %
            % Syntax:  f = Experiment
            %          f.checkDefaultWavelength(val)
            %
            % Inputs:
            %   val - The default wavelength
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT
            check = isequal(obj.default_wavelength, val);
        end
        function yy = linterp(~,x,y,xx)
            %LINTERP Linear interpolation.
            %
            % YY = LINTERP(X,Y,XX) does a linear interpolation for the given
            %      data:
            %
            %           y: given Y-Axis data
            %           x: given X-Axis data
            %          xx: points on X-Axis to be interpolated
            %
            %      output:
            %
            %          yy: interpolated values at points "xx"
            % R. Y. Chiang & M. G. Safonov 9/18/1988
            % Copyright 1988-2004 The MathWorks, Inc.
            %       $Revision: 1.1.6.1 $
            % Added allocation of output vector to speed operation
            % 14 Jan 2014
            %
            % All Rights Reserved.
            % ------------------------------------------------------------------
            nx = max(size(x));
            nxx = max(size(xx));
            if xx(1) < x(1)
                error('You must have min(x) <= min(xx)..')
            end
            if xx(nxx) > x(nx)
                error('You must have max(xx) <= max(x)..')
            end
            %
            yy = zeros(size(xx));   % Pre-allocate output vector
            j = 2;
            for i = 1:nxx
                while x(j) < xx(i)
                    j = j+1;
                end
                alfa = (xx(i)-x(j-1))/(x(j)-x(j-1));
                yy(i) = y(j-1)+alfa*(y(j)-y(j-1));
            end
            clear nx nxx i j alfa;
            %
            % ------ End of INTERP.M % RYC/MGS %
        end
        function resampled_data=resample_data(obj, y, xi, xf)
            %RESAMPLE_DATA - Resamples y over xf given xi
            %
            % Syntax:  f = Experiment
            %          resampled_data = f.resample_data(y, xi, xf)
            %
            % Inputs:
            %   y - The data to be resampled
            %   xi - The x-axis of y
            %   xf - The x-axis y is resampled to
            %
            % Outputs:
            %   resampled_data - y resampled over xf
            %   
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, LINTERP, TRAPNI, RESAMPLE_ALL
            resampled_data = zeros(size(xf));
            test = find((xi(2)<xf)&(xi(end-1)>xf));
            resampled_data(test) = obj.linterp(xi,y,xf(test));
        end
        function resampleAll(obj)
            %RESAMPLEALL - Resamples initial data based off default wavelength
            %
            % Syntax:  f = Experiment
            %          f.resampleAll()
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, LINTERP, TRAPNI,
            % RESAMPLE_DATA
            if(isequal(obj.lightsource.wavelength, obj.default_wavelength))
                obj.filterset.excitation_transmission = ...
                    obj.resample_data(obj.filterset.excitation_transmission, ...
                    obj.filterset.wavelength, obj.default_wavelength);
                obj.filterset.dichroic_transmission = ...
                    obj.resample_data(obj.filterset.dichroic_transmission, ...
                    obj.filterset.wavelength, obj.default_wavelength);        
                obj.dye.excitation_spectrum = ...
                    obj.resample_data(obj.dye.excitation_spectrum, ...
                    obj.dye.wavelength , obj.default_wavelength);
                obj.dye.emission_spectrum = ...
                    obj.resample_data(obj.dye.emission_spectrum, ...
                    obj.dye.wavelength , obj.default_wavelength);
                obj.camera.quantum_efficiency = ... 
                    obj.resample_data(obj.camera.quantum_efficiency, ...
                    obj.camera.wavelength, obj.default_wavelength);
            end
            if(isequal(obj.filterset.wavelength, obj.default_wavelength))
                obj.lightsource.spectral_radiance = ...
                    obj.resample_data(obj.lightsource.spectral_radiance, ...
                    obj.lightsource.wavelength, obj.default_wavelength);       
                obj.dye.excitation_spectrum = ...
                    obj.resample_data(obj.dye.excitation_spectrum, ...
                    obj.dye.wavelength , obj.default_wavelength);
                obj.dye.emission_spectrum = ...
                    obj.resample_data(obj.dye.emission_spectrum, ...
                    obj.dye.wavelength , obj.default_wavelength);
                obj.camera.quantum_efficiency = ... 
                    obj.resample_data(obj.camera.quantum_efficiency, ...
                    obj.camera.wavelength, obj.default_wavelength);
            end
            if(isequal(obj.dye.wavelength, obj.default_wavelength))
                obj.lightsource.spectral_radiance = ...
                    obj.resample_data(obj.lightsource.spectral_radiance, ...
                    obj.lightsource.wavelength, obj.default_wavelength);
                obj.filterset.excitation_transmission = ...
                    obj.resample_data(obj.filterset.excitation_transmission, ...
                    obj.filterset.wavelength, obj.default_wavelength);
                obj.filterset.dichroic_transmission = ...
                    obj.resample_data(obj.filterset.dichroic_transmission, ...
                    obj.filterset.wavelength, obj.default_wavelength);        
                obj.camera.quantum_efficiency = ... 
                    obj.resample_data(obj.camera.quantum_efficiency, ...
                    obj.camera.wavelength, obj.default_wavelength);
            end
            if(isequal(obj.camera.wavelength, obj.default_wavelength))
                obj.lightsource.spectral_radiance = ...
                    obj.resample_data(obj.lightsource.spectral_radiance, ...
                    obj.lightsource.wavelength, obj.default_wavelength);
                obj.filterset.excitation_transmission = ...
                    obj.resample_data(obj.filterset.excitation_transmission, ...
                    obj.filterset.wavelength, obj.default_wavelength);
                obj.filterset.dichroic_transmission = ...
                    obj.resample_data(obj.filterset.dichroic_transmission, ...
                    obj.filterset.wavelength, obj.default_wavelength);        
                obj.dye.excitation_spectrum = ...
                    obj.resample_data(obj.dye.excitation_spectrum, ...
                    obj.dye.wavelength , obj.default_wavelength);
                obj.dye.emission_spectrum = ...
                    obj.resample_data(obj.dye.emission_spectrum, ...
                    obj.dye.wavelength , obj.default_wavelength);
            end
        end
        function trapni=trapni(~, y,x)
            %TRAPNI - Conducts trapizoidal integration
            %Integrates y over x using trapizoidal integration
            %
            % Syntax:  f = Experiment
            %          trapni = f.trapni(y, x)
            %
            % Inputs:
            %   y - Data on Y-Axis (must be same size as x)
            %   x - Data on X-Axis (must be same size as y)
            %
            % Outputs:
            %   trapni - y integrated over x
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, LINTERP, RESAMPLE_DATA,
            % RESAMPLE_ALL
            trapni=(-sum(y(1:end-1).*x(1:end-1))...
            -sum(y(2:end).*x(1:end-1))...
            +sum(y(1:end-1).*x(2:end))...
            +sum(y(2:end).*x(2:end)))/2;
        end
        function calculateEmission(obj)
            %CALCULATEEMISSION - Calculates all the values from the sample emission 
            %
            % Syntax:  f = Experiment
            %          f.calculateEmission()
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, CALCULATEALL
            obj.emission.spectral_radiance_on_sample = ...
                obj.lightsource.spectral_radiance.*...
                obj.filterset.excitation_transmission.*...
                (1 - obj.filterset.dichroic_transmission)*...
                ((obj.objective.n_medium)^2);
            obj.emission.photon_spectral_radiance_on_sample_rate = ...
                obj.emission.spectral_radiance_on_sample./...
                (obj.h*obj.c./obj.default_wavelength);
            obj.emission.photon_radiance_on_sample_rate = ... 
                obj.trapni(...
                obj.emission...
                .photon_spectral_radiance_on_sample_rate, ... 
                obj.default_wavelength);
            obj.emission.Omega = ...
                2*pi*(1 - sqrt(1 - ( ... 
                obj.objective.NA/obj.objective.n_medium)^2));
            obj.emission.photon_irradiance_on_sample_rate = ...
                obj.emission.photon_radiance_on_sample_rate*...
                obj.emission.Omega;
            obj.emission. ... 
                photon_spectral_irradiance_on_sample_rate = ...
                obj.emission. ...
                photon_spectral_radiance_on_sample_rate*...
                obj.emission.Omega;
            obj.emission.photons_absorbed_by_sample_rate = ...
                obj.emission.photon_irradiance_on_sample_rate...
                *obj.dye.absorption_coefficent;
            obj.emission.photons_emitted_by_sample_rate = ...
                obj.dye.quantum_yield*...
                1/( ...
                (1/...
                obj.emission.photons_absorbed_by_sample_rate) ...
                + obj.dye.lifetime);
            obj.emission. ...
                photons_from_emission_in_objective_rate = ...
                obj.emission.photons_emitted_by_sample_rate*...
                obj.emission.Omega/4/pi;
            obj.emission.norm = obj.trapni( ...
                obj.dye.emission_spectrum, obj.default_wavelength);
            obj.emission. ...
                photons_spectral_from_emission_in_filters_rate = ...
                obj.emission. ...
                photons_from_emission_in_objective_rate*...
                obj.dye.emission_spectrum/obj.emission.norm;
            obj.emission. ...
                photons_spectral_from_emission_from_filters_rate = ...
                obj.emission. ...
                photons_spectral_from_emission_in_filters_rate.*...
                obj.filterset.emission_transmission.*...
                obj.filterset.dichroic_transmission;
            obj.emission. ...
                photons_from_emission_from_filters_rate = obj.trapni(...
                obj.emission. ...
                photons_spectral_from_emission_from_filters_rate, ...
                obj.default_wavelength);
            obj.emission. ...
                electrons_spectral_from_emission_camera_rate = ...
                obj.emission. ...
                photons_spectral_from_emission_from_filters_rate.*...
                (obj.camera.quantum_efficiency/100);
            obj.emission.electrons_spectral_from_emission_camera = ...
                obj.emission. ...
                electrons_spectral_from_emission_camera_rate*...
                obj.integration_time;
            obj.emission.number_of_electrons_from_emission = ...
                obj.trapni( ... 
                obj.emission. ...
                electrons_spectral_from_emission_camera, ...
                obj.default_wavelength);
            obj.emission.photons_spectral_emission_from_filters = ...
                obj.emission. ...
                photons_spectral_from_emission_from_filters_rate*...
                obj.integration_time;
        end
        function calculateScattering(obj)
            %CALCULATESCATTERING - Calculates all the values from the sample scattering 
            %
            % Syntax:  f = Experiment
            %          f.calculateScattering()
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, CALCULATEALL
            obj.scattering. ...
                photons_spectral_scattering_from_sample_rate = ...
                obj.emission. ...
                photon_spectral_irradiance_on_sample_rate*...
                obj.dye.scattering_coefficent;
            obj.scattering.photons_scattering_from_sample_rate = ...
                obj.trapni( ...
                obj.scattering. ...
                photons_spectral_scattering_from_sample_rate, ...
                obj.default_wavelength);
            obj.scattering. ...
                photons_spectral_from_scattering_in_objective_rate = ...
                obj.scattering. ...
                photons_spectral_scattering_from_sample_rate*...
                (obj.emission.Omega/(4*pi));
            obj.scattering.photons_scattered_in_objective_rate = ...
                obj.trapni( ...
                obj.scattering. ...
                photons_spectral_from_scattering_in_objective_rate, ...
                obj.default_wavelength);
            obj.scattering. ...
                photons_spectral_from_scattering_from_filters_rate = ...
                obj.scattering. ...
                photons_spectral_from_scattering_in_objective_rate.*...
                obj.filterset.emission_transmission.*...
                obj.filterset.dichroic_transmission;
            obj.scattering.photons_from_scattering_from_filters_rate = ...
                obj.trapni( ...
                obj.scattering. ...
                photons_spectral_from_scattering_from_filters_rate, ...
                obj.default_wavelength);
            obj.scattering. ...
                electrons_spectral_from_scattering_camera_rate = ...
                obj.scattering. ...
                photons_spectral_from_scattering_from_filters_rate.*...
                (obj.camera.quantum_efficiency/100);
            obj.scattering.electrons_spectral_from_scattering_camera = ...
                obj.scattering. ...
                electrons_spectral_from_scattering_camera_rate*...
                obj.integration_time;
            obj.scattering.number_of_electrons_from_scattering = ...
                obj.trapni( ...
                obj.scattering. ...
                electrons_spectral_from_scattering_camera, ...
                obj.default_wavelength);
            obj.scattering.photons_spectral_scattered_from_filters = ...
                obj.scattering. ...
                photons_spectral_from_scattering_from_filters_rate*...
                obj.integration_time;
            obj.scattering. ...
                ratio_electrons_from_emission_electrons_from_scattering...
                = ...
                obj.emission.number_of_electrons_from_emission/...
                obj.scattering.number_of_electrons_from_scattering;
        end
        function calculateNumberOfParticles(obj)
            %CALCULATENUMBEROFPARTICLES - Calculates the number of particles at each experiment stage
            %
            % Syntax:  f = Experiment
            %          f.calculateNumberOfParticles()
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, CALCULATEALL
            obj.number_of_particles.photons_emitted_by_sample = ...
                obj.emission.photons_emitted_by_sample_rate*...
                obj.integration_time;
            obj.number_of_particles. ... 
                photons_from_emission_in_objective = ...
                obj.emission. ...
                photons_from_emission_in_objective_rate*...
                obj.integration_time;
            obj.number_of_particles. ... 
                photons_from_emission_from_filters = ...
                obj.emission.photons_from_emission_from_filters_rate*...
                obj.integration_time;
            obj.number_of_particles.number_of_electrons_from_emission = ...
                obj.emission.number_of_electrons_from_emission;
            obj.number_of_particles.photons_scattered_by_sample = ...
                obj.scattering.photons_scattering_from_sample_rate*...
                obj.integration_time;
            obj.number_of_particles. ...
                photons_from_scattering_in_objective = ...
                obj.scattering.photons_scattered_in_objective_rate*...
                obj.integration_time;
            obj.number_of_particles. ...
                photons_from_scattering_from_filters = ...
                obj.scattering.photons_from_scattering_from_filters_rate*...
                obj.integration_time;
            obj.number_of_particles. ...
                number_of_electrons_from_scattering = ...
                obj.scattering.number_of_electrons_from_scattering;
            obj.number_of_particles.stage_number = [1, 2, 3, 4];
            obj.number_of_particles.stage_number_size = ...
                size(obj.number_of_particles.stage_number);
            obj.number_of_particles.particles_each_stage_emission = ...
                [ ...
                obj.number_of_particles.photons_emitted_by_sample, ...
                obj.number_of_particles.photons_from_emission_in_objective, ...
                obj.number_of_particles.photons_from_emission_from_filters, ...
                obj.number_of_particles.number_of_electrons_from_emission, ...
                ];
            obj.number_of_particles.particles_each_stage_scattering = ...
                [ ...
                -1e10, ...
                -1e10, ...
                obj.number_of_particles.photons_from_scattering_from_filters, ...
                obj.number_of_particles.number_of_electrons_from_scattering, ...
                ];
        end 
        function calculatePercents(obj)
            %CALCULATEPERCENTS - Calculates the percent of particles remaining at each stage
            %
            % Syntax:  f = Experiment
            %          f.calculatePercents()
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, CALCULATEALL
            obj.percentages. ...
                percent_remained_from_emission_sample_to_objective = ...
                100*...
                obj.number_of_particles.photons_from_emission_in_objective/...
                obj.number_of_particles.photons_emitted_by_sample;
            obj.percentages. ...
                percent_remained_from_emission_objective_to_filters = ...
                100*...
                obj.number_of_particles.photons_from_emission_from_filters/...
                obj.number_of_particles.photons_from_emission_in_objective;
            obj.percentages. ...
                percent_remained_from_emission_filters_to_electrons = ...
                100*...
                obj.number_of_particles.number_of_electrons_from_emission/...
                obj.number_of_particles.photons_from_emission_from_filters;
            obj.percentages. ...
                percent_remained_from_scattering_sample_to_objective = ...
                100*...
                obj.number_of_particles.photons_from_scattering_in_objective/...
                obj.number_of_particles.photons_scattered_by_sample;
            obj.percentages. ...
                percent_remained_from_scattering_objective_to_filters = ...
                100*...
                obj.number_of_particles.photons_from_scattering_from_filters/...
                obj.number_of_particles.photons_from_scattering_in_objective;
            obj.percentages. ...
                percent_remained_from_scattering_filters_to_electrons = ...
                100*...
                obj.number_of_particles.number_of_electrons_from_scattering/...
                obj.number_of_particles.photons_from_scattering_from_filters;
        end
        function calculateNoise(obj)
            %CALCULATENOISE - Calculates the percent of particles remaining at each stage
            %
            % Syntax:  f = Experiment
            %          f.calculatePercents()
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, CALCULATEALL
            obj.noise.signal_photons = ...
                obj.number_of_particles.photons_from_emission_from_filters;
            obj.noise.noise_photons = ...
                obj.number_of_particles. ...
                photons_from_scattering_from_filters;
            obj.noise.signal = ...
                obj.number_of_particles.number_of_electrons_from_emission;
            obj.noise.noise_signal_error = ...
                sqrt(obj.noise.signal_photons);
            obj.noise.noise_from_scattering = ...
                obj.number_of_particles.number_of_electrons_from_scattering;
            obj.noise.noise_from_dark_current = ...
                obj.integration_time*obj.camera.dark_current;
            obj.noise.noise_from_readout_noise = obj.camera.readout_noise;
            obj.noise.signal_to_noise_ratio = ...
                obj.noise.signal/sqrt(obj.noise.signal + ...
                obj.camera.readout_noise + ...
                obj.noise.noise_from_dark_current + ...
                obj.noise.noise_from_scattering);
        end
        function calculateAll(obj)
            %CALCULATEALL - Calculates all required calculated data for the class
            %
            % Syntax:  f = Experiment
            %          f.calculateAll()
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT
            obj.calculateEmission();
            obj.calculateScattering();
            obj.calculateNumberOfParticles();
            obj.calculatePercents();
            obj.calculateNoise();
        end
        function dispData(obj, debuglevel)
            %DISPDATA - Displays all the data of the class
            %
            % Syntax:  f = Experiment
            %          f.dispData(debuglevel)
            %
            % Inputs:
            %   debuglevel - Determines how many figures are shown
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, DISPFIGURES, DISPFIGURESDESC,
            % DISPDATADESC
            order = 1;
            while(order <= 14)
                if(debuglevel >= 100)
                end
                if(debuglevel >= 75)
                    if(order == 13)
                        disp(...
                            'Percent remained of photons (from emission) from sample to objective')
                        disp(obj.percentages.percent_remained_from_emission_sample_to_objective)
                        disp(...
                            'Percent remained of photons (from emission) from objective to filters')
                        disp(obj.percentages.percent_remained_from_emission_objective_to_filters)
                        disp(...
                            'Percent remained of particles (from emission) from filters to camera')
                        disp(obj.percentages.percent_remained_from_emission_filters_to_electrons)
                        disp(...
                            'Percent remained of photons (from scattering) from sample to objective')
                        disp(obj.percentages.percent_remained_from_scattering_sample_to_objective)
                        disp(...
                            'Percent remained of photons (from scattering) from objective to filters')
                        disp(obj.percentages.percent_remained_from_scattering_objective_to_filters)
                        disp(...
                            'Percent remained of particles (from scattering) from filters to camera')
                        disp(obj.percentages.percent_remained_from_scattering_filters_to_electrons)
                    end
                end
                if(debuglevel >= 50)
                    if(order == 1)
                        disp('Photons per second per mm^2 per sterradian on sample')
                        disp(obj.emission.photon_radiance_on_sample_rate/1e6)
                    end
                    if(order == 2)
                        disp('Photons per second per mm^2 on sample')
                        disp(obj.emission.photon_irradiance_on_sample_rate/1e6)
                    end
                    if(order == 3)
                        disp('Photons per second absorbed by sample')
                        disp(obj.emission.photons_absorbed_by_sample_rate)
                        disp('Photons per second emitted by sample')
                        disp(obj.emission.photons_emitted_by_sample_rate)
                    end
                    if(order == 5)
                        disp('Photons through objective lens per second')
                        disp(obj.emission.photons_from_emission_in_objective_rate)
                    end
                    if(order == 6)
                        disp('Photons emitted through filters per second')
                        disp(obj.emission.photons_from_emission_from_filters_rate)
                    end
                    if(order == 8)
                        disp('Photons per second scattered by sample')
                        disp(obj.scattering.photons_scattering_from_sample_rate)
                    end
                    if(order == 9)
                        disp('Photons scattered through objective lens per second')
                        disp(obj.scattering.photons_scattered_in_objective_rate)
                    end
                    if(order == 10)
                        disp('Photons scattered through filters per second')
                        disp(obj.scattering.photons_from_scattering_from_filters_rate)
                    end
                end
                if(debuglevel >= 25)
                    if(order == 7)
                        disp('Number of electrons from emission')
                        disp(obj.emission.number_of_electrons_from_emission)
                    end
                    if(order == 11)
                        disp('Number of electrons from scattering')
                        disp(obj.scattering.number_of_electrons_from_scattering)
                    end
                    if(order == 14)
                        disp('Signal (photons)');
                        disp(obj.noise.signal_photons);
                        disp('Noise (photons)');
                        disp(obj.noise.noise_photons);
                        disp('Noise From Dark Current (electrons)');
                        disp(obj.noise.noise_from_dark_current);
                        disp('Noise From Readout Noise (electrons');
                        disp(obj.noise.noise_from_readout_noise);
                    end
                end
                if(order == 4)
                    if(obj.emission.photons_absorbed_by_sample_rate > ...
                            1/obj.dye.lifetime)
                        disp('Warning: Fluorescence Saturation')
                    end
                end
                if(order == 12)
                    if(obj.scattering.ratio_electrons_from_emission_electrons_from_scattering < 1)
                        disp('Warning: Excessive Noise')
                    end
                end
                order = order + 1;
            end
            clear order;
        end
        function dispDataDesc(obj, debuglevel, desc)
            %DISPDATA - Displays all the data of the class with a descriptor
            %
            % Syntax:  f = Experiment
            %          f.dispData(debuglevel, desc)
            %
            % Inputs:
            %   debuglevel - Determines how many figures are shown
            %   desc - The descriptor
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, DISPFIGURES, DISPFIGURESDESC,
            % DISPDATA
            order = 1;
            while(order <= 14)
                if(debuglevel >= 100)
                    if(order == 13)
                        str = strcat(desc, ' Percent remained of photons (from emission) from sample to objective');
                        disp(str); disp(obj.percentages.percent_remained_from_emission_sample_to_objective);
                        str = strcat(desc, ' Percent remained of photons (from emission) from objective to filters');
                        disp(str); disp(obj.percentages.percent_remained_from_emission_objective_to_filters);
                        str = strcat(desc, ' Percent remained of particles (from emission) from filters to camera');
                        disp(str); disp(obj.percentages.percent_remained_from_emission_filters_to_electrons);
                        str = strcat(desc, ' Percent remained of photons (from scattering) from sample to objective');
                        disp(str); disp(obj.percentages.percent_remained_from_scattering_sample_to_objective);
                        str = strcat(desc, ' Percent remained of photons (from scattering) from objective to filters');
                        disp(str); disp(obj.percentages.percent_remained_from_scattering_objective_to_filters);
                        str = strcat(desc, ' Percent remained of particles (from scattering) from filters to camera');
                        disp(str); disp(obj.percentages.percent_remained_from_scattering_filters_to_electrons);
                        clear str;
                    end
                end
                if(debuglevel >= 75)
                end
                if(debuglevel >= 50)
                    if(order == 1)
                        str = strcat(desc, ' Photons per second per mm^2 per sterradian on sample');
                        disp(str); disp(obj.emission.photon_radiance_on_sample_rate/1e6);
                        clear str;
                    end
                    if(order == 2)
                        str = strcat(desc, ' Photons per second per mm^2 on sample');
                        disp(str); disp(obj.emission.photon_irradiance_on_sample_rate/1e6);
                        clear str;
                    end
                    if(order == 3)
                        str = strcat(desc, ' Photons per second absorbed by sample');
                        disp(str); disp(obj.emission.photons_absorbed_by_sample_rate);
                        str = strcat(desc, ' Photons per second emitted by sample');
                        disp(str); disp(obj.emission.photons_emitted_by_sample_rate);
                        clear str;
                    end
                    if(order == 5)
                        str = strcat(desc, ' Photons through objective lens per second');
                        disp(str); disp(obj.emission.photons_from_emission_in_objective_rate);
                        clear str;
                    end
                    if(order == 6)
                        str = strcat(desc, ' Photons emitted through filters per second');
                        disp(str); disp(obj.emission.photons_from_emission_from_filters_rate);
                        clear str;
                    end
                    if(order == 8)
                        str = strcat(desc, ' Photons per second scattered by sample');
                        disp(str); disp(obj.scattering.photons_scattering_from_sample_rate);
                        clear str;
                    end
                    if(order == 9)
                        str = strcat(desc, ' Photons scattered through objective lens per second');
                        disp(str); disp(obj.scattering.photons_scattered_in_objective_rate);
                        clear str;
                    end
                    if(order == 10)
                        str = strcat(desc, ' Photons scattered through filters per second');
                        disp(str); disp(obj.scattering.photons_from_scattering_from_filters_rate);
                        clear str;
                    end
                end
                if(debuglevel >= 25)
                    if(order == 7)
                        str = strcat(desc, ' Number of electrons from emission');
                        disp(str); disp(obj.emission.number_of_electrons_from_emission);
                        clear str;
                    end
                    if(order == 11)
                        str = strcat(desc, ' Number of electrons from scattering');
                        disp(str); disp(obj.scattering.number_of_electrons_from_scattering);
                        clear str;
                    end
                    if(order == 14)
                        disp('Signal (photons)');
                        disp(obj.noise.signal_photons);
                        disp('Noise (photons)');
                        disp(obj.noise.noise_photons);
                        disp('Noise From Dark Current (electrons)');
                        disp(obj.noise_from_dark_current);
                        disp('Noise From Readout Noise (electrons');
                        disp(obj.noise.noise_from_readout_noise);
                    end
                end
                if(order == 4)
                    if(obj.emission.photons_absorbed_by_sample_rate > ...
                            1/obj.dye.lifetime)
                        str = strcat(desc, ' Warning: Fluorescence Saturation');
                        disp(str);
                        clear str;
                    end
                end
                if(order == 12)
                    if(obj.scattering.ratio_electrons_from_emission_electrons_from_scattering < 1)
                        str = strcat(desc, ' Warning: Excessive Noise');
                        disp(str);
                        clear str;
                    end
                end
                order = order + 1;
            end
            clear order;
        end
        function generateFigureGUI(~)
            %GENERATEFIGUREGUI - Generates a GUI to select figures generated by the class
            %
            % Syntax:  f = Experiment
            %          f.generateFigureGUI()
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, DISPFIGURES,
            % DISPFIGURESDESC
            fid = fopen('testmgui.m' ,'w');
            fprintf(fid, "function testmgui\n");
            fprintf(fid, "figure('Name', 'Figure Display GUI');\n");
            for i=1:get(gcf, 'Number')
                f = figure(i);
                axisval = i*30;
                fprintf(fid, "uicontrol(gcf, 'Style', 'pushbutton', 'String', '");
                fprintf(fid, f.Name);
                fprintf(fid, "', 'Position', [10 "); fprintf(fid, '%d', axisval);
                fprintf(fid, " 480 40], 'callback', @gui"); fprintf(fid, '%d', i);
                fprintf(fid, ");\n");
            end
            for i=1:get(gcf, 'Number')
                fprintf(fid, "function gui"); fprintf(fid, '%d', i);
                fprintf(fid, "(obj, event)\n");
                fprintf(fid, "\tfigure("); fprintf(fid, '%d', i);
                fprintf(fid, ");\n");
                fprintf(fid, "end\n");
            end
            fprintf(fid, 'end\n');
            fclose(fid);
            clear fid;
            testmgui;
        end
        function dispFigures(obj, debuglevel)
            %DISPFIGURES - Displays all the figures of the class
            %
            % Syntax:  f = Experiment
            %          f.dispFigures(debuglevel)
            %
            % Inputs:
            %   debuglevel - Determines how many figures are shown
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, DISPFIGURESDESC, DISPDATA,
            % DISPDATADESC
            order = 1;
            while(order <= 20)
                if(debuglevel >= 100)
                    if(order == 1)
                        t = 'Transmission and Reflection through Filters from Source';
                        figure('Name', t);
                        semilogy(obj.default_wavelength*1e9, obj.filterset.excitation_transmission, 'b', ...
                            obj.default_wavelength*1e9, 1 - obj.filterset.dichroic_transmission, 'g', ...
                            obj.default_wavelength*1e9, obj.filterset.excitation_transmission.* ...
                            (1 - obj.filterset.dichroic_transmission), 'r');
                        limits = axis;
                        axis([limits(1:2), limits(4)*[0,1]]);
                        grid on;
                        title('Transmission and Reflection through Filters from Source');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('Filter');
                        legend('Excitation Transmission', 'Dichroic Reflection', 'Product');
                        clear t;
                    end
                    if(order == 5)
                        t = 'Transmission of Photons Through Filters from Sample';
                        figure('Name', t);
                        semilogy(obj.default_wavelength*1e9, obj.filterset.dichroic_transmission, 'b', ...
                            obj.default_wavelength*1e9, obj.filterset.emission_transmission, 'g', ...
                            obj.default_wavelength*1e9, obj.filterset.emission_transmission.* ...
                            obj.filterset.dichroic_transmission, 'r');
                        limits = axis;
                        axis([limits(1:2), limits(4)*[0,1]]);
                        grid on;
                        title('Transmission of Photons Through Filters from Sample');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('Filter');
                        legend('Dichroic Transmission','Emission Transmission','Product');
                        clear t;
                    end
                    if(order == 8)
                        t = 'Photons Entering Camera and Electrons in Camera from Emission';
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, obj.emission.photons_spectral_emission_from_filters, ...
                            obj.default_wavelength*1e9, obj.emission.electrons_spectral_from_emission_camera);
                        grid on;
                        title('Photons Entering Camera and Electrons in Camera from Emission');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('N_\lambda, Particles');
                        legend('Photons', 'Electrons');
                        clear t;
                    end    
                    if(order == 9)
                        t = 'Photons Entering Camera and Electrons in Camera from Scattering';
                        figure('Name', t);
                        plot(1e9*obj.default_wavelength, obj.scattering.photons_spectral_scattered_from_filters, ...
                            1e9*obj.default_wavelength, obj.scattering.electrons_spectral_from_scattering_camera);
                        grid on;
                        title(...
                            'Photons Entering Camera and Electrons in Camera from Scattering');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('N_\lambda, Particles');
                        legend('Photons', 'Electrons');
                        clear t;
                    end
                end
                if(debuglevel >= 75)
                    if(order == 2)
                        t = 'Spectral Radiance At Source and On Sample';
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, ...
                            obj.lightsource.spectral_radiance/1e6/1e3, ...
                            'b', ...
                            obj.default_wavelength*1e9, ...
                            obj.emission.spectral_radiance_on_sample/1e6/1e3, 'r');
                        grid on;
                        title('Spectral Radiance At Source and On Sample');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('L_\lambda, Spectral Radiance, W/mm^2/sr/mm');
                        legend('At Source', 'On Sample');
                        clear t;
                    end
                    if(order == 3)
                        t = 'Photon Spectral Radiance on Sample Rate';
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, ...
                            obj.emission.photon_spectral_radiance_on_sample_rate/1e6/1e3, 'r');
                        grid on;
                        title('Photon Spectral Radiance on Sample Rate');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('L_{P\lambda}, Photon Spectral Radiance, Photons/s/mm^2/sr/mm');
                        clear t;
                    end
                    if(order == 4)
                        t = 'Dye Emission and Excitation Spectrum';
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, ...
                            obj.dye.emission_spectrum, ...
                            obj.default_wavelength*1e9, ...
                            obj.dye.excitation_spectrum);
                        grid on;
                        title('Dye Emission and Excitation Spectrum');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('Value');
                        legend('Emission Spectrum', 'Excitation Spectrum');
                        clear t;
                    end
                    if(order == 6)
                        t = 'Photon Emission Rate Before and After Filter Set';
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, ...
                            obj.emission.photons_spectral_from_emission_in_filters_rate/1e9, ...
                            'b', obj.default_wavelength*1e9, ...
                            obj.emission.photons_spectral_from_emission_from_filters_rate/1e9, 'r');
                        grid on;
                        title('Photon Emission Rate Before and After Filter Set');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('N_\lambda, Photons emitted per nm per second');
                        legend('Before Filter Set','After Filter Set');
                        clear t;
                    end
                end
                if(debuglevel >= 50)
                    if(order == 7)
                        t = 'Photon Scattering Rate Before and After Filter Set';
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, ...
                            obj.scattering.photons_spectral_from_scattering_from_filters_rate/1e9, 'r');
                        grid on;
                        title('Photon Scattering Rate After Filter Set');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('N_\lambda, Photons scattered per nm per second');
                        legend('Scattering After Filter Set');
                        clear t;
                    end
                end
                if(debuglevel >= 25) 
                end
                if(debuglevel >= 0)
                    if(order == 10)
                        t = 'Electrons from Emission and Scattering';
                        figure('Name', t);
                        plot(1e9*obj.default_wavelength, obj.emission.electrons_spectral_from_emission_camera, ...
                            1e9*obj.default_wavelength, obj.scattering.electrons_spectral_from_scattering_camera);
                        grid on;
                        title('Electrons from Emission and Scattering');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('N_\lambda, Electrons');
                        legend('Electrons from Emission', 'Electrons from Scattering');
                        clear t;
                    end
                    if(order == 11)
                        t = 'Number of Particles at Each Stage';
                        figure('Name', t);
                        for i = 1:obj.number_of_particles.stage_number_size(2)
                            plot(obj.number_of_particles.stage_number(i), obj.number_of_particles.particles_each_stage_emission(i), 'b--o');
                            hold on;
                        end
                        for j = 1:obj.number_of_particles.stage_number_size(2)
                            plot(obj.number_of_particles.stage_number(j), obj.number_of_particles.particles_each_stage_scattering(j), 'r--o');
                            hold on;
                        end
                        grid on;
                        xticks(obj.number_of_particles.stage_number);
                        try
                            axis([obj.number_of_particles.stage_number_size(1) obj.number_of_particles.stage_number_size(2) ...
                            0 max(max(obj.number_of_particles.particles_each_stage_emission, ...
                            obj.number_of_particles.particles_each_stage_scattering))]);
                        catch
                        end
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
                        clear t;
                    end
                end
                order = order + 1;
            end
            clear order;
            obj.generateFigureGUI()
        end
        function dispFiguresDesc(obj, debuglevel, desc)
            %DISPFIGURESDESC - Displays all the figures of the class
            %
            % Syntax:  f = Experiment
            %          f.dispFiguresDesc(debuglevel, desc)
            %
            % Inputs:
            %   debuglevel - Determines how many figures are shown
            %   desc - The descriptor
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, DISPFIGURES, DISPDATA,
            % DISPDATADESC
            order = 1;
            while(order <= 20)
                if(debuglevel >= 100)
                    if(order == 1)
                        t = strcat(desc, ' Transmission and Reflection through Filters from Source');
                        figure('Name', t);
                        semilogy(obj.default_wavelength*1e9, obj.filterset.excitation_transmission, 'b', ...
                            obj.default_wavelength*1e9, 1 - obj.filterset.dichroic_transmission, 'g', ...
                            obj.default_wavelength*1e9, obj.filterset.excitation_transmission.* ...
                            (1 - obj.filterset.dichroic_transmission), 'r');
                        limits = axis;
                        axis([limits(1:2), limits(4)*[0,1]]);
                        grid on;
                        title('Transmission and Reflection through Filters from Source');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('Filter');
                        legend('Excitation Transmission', 'Dichroic Reflection', 'Product');
                        clear t;
                    end
                    if(order == 5)
                        t = strcat(desc, ' Transmission of Photons Through Filters from Sample'); 
                        figure('Name', t);
                        semilogy(obj.default_wavelength*1e9, obj.filterset.dichroic_transmission, 'b', ...
                            obj.default_wavelength*1e9, obj.filterset.emission_transmission, 'g', ...
                            obj.default_wavelength*1e9, obj.filterset.emission_transmission.* ...
                            obj.filterset.dichroic_transmission, 'r');
                        limits = axis;
                        axis([limits(1:2), limits(4)*[0,1]]);
                        grid on;
                        title('Transmission of Photons Through Filters from Sample');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('Filter');
                        legend('Dichroic Transmission','Emission Transmission','Product');
                        clear t;
                    end
                    if(order == 8)
                        t = strcat(desc, ' Photons Entering Camera and Electrons in Camera from Emission');
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, obj.emission.photons_spectral_emission_from_filters, ...
                            obj.default_wavelength*1e9, obj.emission.electrons_spectral_from_emission_camera);
                        grid on;
                        title('Photons Entering Camera and Electrons in Camera from Emission');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('N_\lambda, Particles');
                        legend('Photons', 'Electrons');
                        clear t;
                    end
                    if(order == 9)
                        t = strcat(desc, ' Photons Entering Camera and Electrons in Camera from Scattering');
                        figure('Name', t);
                        plot(1e9*obj.default_wavelength, obj.scattering.photons_spectral_scattered_from_filters, ...
                            1e9*obj.default_wavelength, obj.scattering.electrons_spectral_from_scattering_camera);
                        grid on;
                        title(...
                            'Photons Entering Camera and Electrons in Camera from Scattering');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('N_\lambda, Particles');
                        legend('Photons', 'Electrons');
                        clear t;
                    end
                end
                if(debuglevel >= 75)
                    if(order == 2)
                        t = strcat(desc, ' Spectral Radiance At Source and On Sample');
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, ...
                            obj.lightsource.spectral_radiance/1e6/1e3, ...
                            'b', ...
                            obj.default_wavelength*1e9, ...
                            obj.emission.spectral_radiance_on_sample/1e6/1e3, 'r');
                        grid on;
                        title('Spectral Radiance At Source and On Sample');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('L_\lambda, Spectral Radiance, W/mm^2/sr/mm');
                        legend('At Source', 'On Sample');
                        clear t;
                    end
                    if(order == 3)
                        t = strcat(desc, ' Photon Spectral Radiance on Sample Rate');
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, ...
                            obj.emission.photon_spectral_radiance_on_sample_rate/1e6/1e3, 'r');
                        grid on;
                        title('Photon Spectral Radiance on Sample Rate');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('L_{P\lambda}, Photon Spectral Radiance, Photons/s/mm^2/sr/mm');
                        clear t;
                    end
                    if(order == 4)
                        t = strcat(desc, ' Dye Emission and Excitation Spectrum');
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, ...
                            obj.dye.emission_spectrum, ...
                            obj.default_wavelength*1e9, ...
                            obj.dye.excitation_spectrum);
                        grid on;
                        title('Dye Emission and Excitation Spectrum');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('Value');
                        legend('Emission Spectrum', 'Excitation Spectrum');
                        clear t;
                    end
                    if(order == 6)
                        t = strcat(desc, ' Photon Emission Rate Before and After Filter Set');
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, ...
                            obj.emission.photons_spectral_from_emission_in_filters_rate/1e9, ...
                            'b', obj.default_wavelength*1e9, ...
                            obj.emission.photons_spectral_from_emission_from_filters_rate/1e9, 'r');
                        grid on;
                        title('Photon Emission Rate Before and After Filter Set');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('N_\lambda, Photons emitted per nm per second');
                        legend('Before Filter Set','After Filter Set');
                        clear t;
                    end
                end
                if(debuglevel >= 50)
                    if(order == 7)
                        t = strcat(desc, 'Photon Scattering Rate Before and After Filter Set');
                        figure('Name', t);
                        plot(obj.default_wavelength*1e9, ...
                            obj.scattering.photons_spectral_from_scattering_from_filters_rate/1e9, 'r');
                        grid on;
                        title('Photon Scattering Rate After Filter Set');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('N_\lambda, Photons scattered per nm per second');
                        legend('Scattering After Filter Set');
                        clear t;
                    end
                end
                if(debuglevel >= 25)
                end
                if(debuglevel >= 0)
                    if(order == 10)
                        t = strcat(desc, ' Electrons from Emission and Scattering');
                        figure('Name', t);
                        plot(1e9*obj.default_wavelength, obj.emission.electrons_spectral_from_emission_camera, ...
                            1e9*obj.default_wavelength, obj.scattering.electrons_spectral_from_scattering_camera);
                        grid on;
                        title('Electrons from Emission and Scattering');
                        xlabel('\lambda, Wavelength, nm');
                        ylabel('N_\lambda, Electrons');
                        legend('Electrons from Emission', 'Electrons from Scattering');
                        clear t;
                    end
                    if(order == 11)
                        t = strcat(desc, ' Number of Particles at Each Stage');
                        figure('Name', t);
                        for i = 1:obj.number_of_particles.stage_number_size(2)
                            plot(obj.number_of_particles.stage_number(i), obj.number_of_particles.particles_each_stage_emission(i), 'b--o');
                            hold on;
                        end
                        for j = 1:obj.number_of_particles.stage_number_size(2)
                            plot(obj.number_of_particles.stage_number(j), obj.number_of_particles.particles_each_stage_scattering(j), 'r--o');
                            hold on;
                        end
                        grid on;
                        xticks(obj.number_of_particles.stage_number);
                        axis([obj.number_of_particles.stage_number_size(1) obj.number_of_particles.stage_number_size(2) ...
                            0 max(max(obj.number_of_particles.particles_each_stage_emission, ...
                            obj.number_of_particles.particles_each_stage_scattering))]);
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
                        clear t;
                    end
                end
                order = order + 1;
            end
            clear order;
            obj.generateFigureGUI();
        end
        function executeAll ...
                (obj, lightsource, filterset, ...
                dye, objective, camera, wavelength, debuglevel)
            %EXECUTEALL - Executes all functions in the class
            %
            % Syntax:  f = Experiment
            %          f.executeAll(lightsource, filterset, dye,
            %          objective, camera, wavelength, debuglevel)
            %
            % Inputs:
            %   lightsource - Holds the spectral radiance, wavelength, and name of the lightsource 
            %   filterset - Holds the transmission spectra and wavelength of each filter 
            %   dye - Holds the quantum and optical properties of the sample 
            %   objective - Holds the optical properties of the objective lens 
            %   camera - Holds the quantum efficiency and wavelength of the camera
            %   wavelength - The default wavelength of the class
            %   debuglevel - Determines how much data and figures are shown
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, EXECUTEALLDESC
            obj.setInitialData ...
                (lightsource, filterset, dye, ...
                objective, camera, wavelength);
            obj.resampleAll();
            obj.calculateAll();
            obj.dispData(debuglevel);
            obj.dispFigures(debuglevel);
        end
        function executeAllDesc ...
                (obj, lightsource, filterset, ...
                dye, objective, camera, wavelength, debuglevel, desc)
            %EXECUTEALLDESC - Executes all functions in the class with a descriptor
            %
            % Syntax:  f = Experiment
            %          f.executeAllDesc(lightsource, filterset, dye,
            %          objective, camera, wavelength, debuglevel, desc)
            %
            % Inputs:
            %   lightsource - Holds the spectral radiance, wavelength, and name of the lightsource 
            %   filterset - Holds the transmission spectra and wavelength of each filter 
            %   dye - Holds the quantum and optical properties of the sample 
            %   objective - Holds the optical properties of the objective lens 
            %   camera - Holds the quantum efficiency and wavelength of the camera
            %   wavelength - The default wavelength of the class
            %   debuglevel - Determines how much data and figures are shown
            %   desc - The descriptor
            %
            % Other m-files required: none
            % Subfunctions: none
            % MAT-files required: none
            %
            % See also: EXPERIMENT, EXECUTEALL
            obj.setInitialData ...
                (lightsource, filterset, dye, ...
                objective, camera, wavelength);
            obj.resampleAll();
            obj.calculateAll();
            obj.dispDataDesc(debuglevel, desc);
            obj.dispFiguresDesc(debuglevel, desc);
        end
        function executeAllIntTime ...
                (obj, lightsource, filterset, ...
                dye, objective, camera, wavelength, integration_time, debuglevel)
            obj.integration_time = integration_time;
            obj.setInitialData ...
                (lightsource, filterset, dye, ...
                objective, camera, wavelength);
            obj.resampleAll();
            obj.calculateAll();
            obj.dispData(debuglevel);
            obj.dispFigures(debuglevel);
        end
    end
end