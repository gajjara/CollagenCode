function testmgui
figure('Name', 'Figure Display GUI');
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Transmission and Reflection through Filters from Source', 'Position', [10 30 480 40], 'callback', @gui1);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Spectral Radiance At Source and On Sample', 'Position', [10 60 480 40], 'callback', @gui2);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Photon Spectral Radiance on Sample Rate', 'Position', [10 90 480 40], 'callback', @gui3);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Dye Emission and Excitation Spectrum', 'Position', [10 120 480 40], 'callback', @gui4);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Transmission of Photons Through Filters from Sample', 'Position', [10 150 480 40], 'callback', @gui5);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Photon Emission Rate Before and After Filter Set', 'Position', [10 180 480 40], 'callback', @gui6);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Photon Scattering Rate Before and After Filter Set', 'Position', [10 210 480 40], 'callback', @gui7);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Photons Entering Camera and Electrons in Camera from Emission', 'Position', [10 240 480 40], 'callback', @gui8);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Photons Entering Camera and Electrons in Camera from Scattering', 'Position', [10 270 480 40], 'callback', @gui9);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Electrons from Emission and Scattering', 'Position', [10 300 480 40], 'callback', @gui10);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'Number of Particles at Each Stage', 'Position', [10 330 480 40], 'callback', @gui11);
function gui1(obj, event)
	figure(1);
end
function gui2(obj, event)
	figure(2);
end
function gui3(obj, event)
	figure(3);
end
function gui4(obj, event)
	figure(4);
end
function gui5(obj, event)
	figure(5);
end
function gui6(obj, event)
	figure(6);
end
function gui7(obj, event)
	figure(7);
end
function gui8(obj, event)
	figure(8);
end
function gui9(obj, event)
	figure(9);
end
function gui10(obj, event)
	figure(10);
end
function gui11(obj, event)
	figure(11);
end
end
