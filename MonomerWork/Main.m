%% INITIAL DATA
lightsource_white = whiteLEDmcwhl5(); 
lightsource_blue = blueLEDm470L3();

filterset = filterset1;         
lambda = filterset.wavelength;

dye = alexa488();
dye.absorption_coefficent = dye.sigma;
dye.scattering_coefficent = 1e-13;

objective.M = 60;
objective.NA = 1.45; 
objective.n_medium = 1.56;

camera = andorX8250camera();

%% EXECUTE

f_blue =  Experiment(lightsource_blue, filterset, dye, objective, camera, lambda, 100, 'Blue Light |');
f_white = Experiment(lightsource_white, filterset, dye, objective, camera, lambda, 100, 'White Light |');

clear lightsource_white lightsource_blue filterset lambda objective camera dye;
close all;