function camera=SPOTRT900Camera()
camera.model='RT SE6 Monochrome:';
camera.serial='RT900';
camera.pixelpitchx=6.45e-6; % pixel pitch in meters
camera.pixelpitchy=6.45e-6; % pixel pitch in meters
camera.pixelsizex=6.45e-6; % pixel size in meters
camera.pixelsizey=6.45e-6; % pixel size in meters
camera.pixelcountx=1360;
camera.pixelcounty=1024;
camera.dark_current=0.012; % Electron per pixel per second
camera.gainconstant=1; % Electrons per ADU
% Check the line above.  Need the amplifier and gain setting
camera.fullwell=182304; % Electrons per Pixel
camera.bits=16;
camera.qeplot_nm=[530,0.59];
camera.readout_noise=8; % Electrons RMS at 20MHz.
camera.wavelength=          1e-9*[400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900];
camera.quantum_efficiency=  100*[0.45,0.54,0.58,0.60,0.59,0.62,0.55,0.46,0.37,0.30,0.20];
end