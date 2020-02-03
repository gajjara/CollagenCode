clear;andorX8250camera();
settings.camera
figure;
plot(settings.camera.qeplot_nm(:,1),...
     settings.camera.qeplot_nm(:,2));
grid on;
xlabel('\lambda, Wavelength, nm');
ylabel('\eta, Quantum Efficiency');
title('Andor');

clear;coolsnap_ez_monochrome;
settings.camera
figure;
plot(settings.camera.qeplot_nm(:,1),...
     settings.camera.qeplot_nm(:,2));
grid on;
xlabel('\lambda, Wavelength, nm');
ylabel('\eta, Quantum Efficiency');
title('CoolSnap');