function camera=andorX8250camera()
camera.model='DU897U-CS0-#BV';
camera.serial='X-8250';
camera.pixelpitchx=16e-6; % pixel pitch in meters
camera.pixelpitchy=16e-6; % pixel pitch in meters
camera.pixelsizex=16e-6; % pixel size in meters
camera.pixelsizey=16e-6; % pixel size in meters
camera.pixelcountx=512;
camera.pixelcounty=512;
camera.dark_current=0.0014; % Electron per pixel per second
camera.gainconstant=5.31; % Electrons per ADU
% Check the line above.  Need the amplifier and gain setting
camera.fullwell=182304; % Electrons per Pixel
camera.bits=16;
camera.qeplot_nm=[530,0.95];
camera.readout_noise=1; % Electrons RMS at 20MHz.
load andorX8250.mat;
camera.wavelength=qedata(:,1)/1e9;
camera.quantum_efficiency=qedata(:,2);

clear qedata;
end
