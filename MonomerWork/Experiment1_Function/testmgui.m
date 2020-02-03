function testmgui
figure;
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'GUI 1', 'Position', [10 30 60 40], 'callback', @gui1);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'GUI 2', 'Position', [10 60 60 40], 'callback', @gui2);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'GUI 3', 'Position', [10 90 60 40], 'callback', @gui3);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'GUI 4', 'Position', [10 120 60 40], 'callback', @gui4);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'GUI 5', 'Position', [10 150 60 40], 'callback', @gui5);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'GUI 6', 'Position', [10 180 60 40], 'callback', @gui6);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'GUI 7', 'Position', [10 210 60 40], 'callback', @gui7);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'GUI 8', 'Position', [10 240 60 40], 'callback', @gui8);
uicontrol(gcf, 'Style', 'pushbutton', 'String', 'GUI 9', 'Position', [10 270 60 40], 'callback', @gui9);
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
end
