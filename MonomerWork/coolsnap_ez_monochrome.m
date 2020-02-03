function camera=coolsnap_ez_monochrome();
camera.name='CoolSnap EZ Monochrome';
camera.pixelpitchx=6.45e-6; % pixel pitch in meters
camera.pixelpitchy=6.45e-6; % pixel pitch in meters
camera.pixelsizex=6.45e-6; % pixel size in meters
camera.pixelsizey=6.45e-6; % pixel size in meters
camera.pixelcountx=1392;
camera.pixelcounty=1040;
camera.dark_current=1; % Electron per pixel per second
camera.gainconstant=3; % Electrons per ADU
camera.fullwell=12300; % Electrons per Pixel
camera.bits=16;
camera.qeplot_nm=[350,0.2;400,0.45;450,0.58;...
		    500,0.62;530,0.62;...
		    600,0.62;700,0.48;800,0.3;900,0.12];
camera.readout_noise=8; % Electrons RMS at 20MHz.
camera.wavelength = 1e-9.*reshape(camera.qeplot_nm(1:size(camera.qeplot_nm, 1)), 9, 1);
camera.quantum_efficiency = 100.*reshape(camera.qeplot_nm(:,2), 9, 1);
end
