fid = fopen('testmgui.m' ,'w');

fprintf(fid, "function testmgui\n");
fprintf(fid, "figure;\n");

for i=1:get(gcf, 'Number')
    f = figure(i);
        
    
    axisval = i*30;
    
    fprintf(fid, "uicontrol(gcf, 'Style', 'pushbutton', 'String', 'GUI ");
    fprintf(fid, '%d', i);
    fprintf(fid, "', 'Position', [10 "); fprintf(fid, '%d', axisval);
    fprintf(fid, " 60 40], 'callback', @gui"); fprintf(fid, '%d', i);
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

testmgui;


%    
% pbh1 = uicontrol(gcf,'Style','pushbutton','String','GUI 1',...
%     'Position',[10 60 60 40],...
%     'callback',@gui1);
% pbh2 = uicontrol(gcf,'Style','pushbutton','String','GUI 2',...
%     'Position',[10 90 60 40],...
%     'callback',@gui2);
% pbh3 = uicontrol(gcf,'Style','pushbutton','String','GUI 3',...
%     'Position',[10 120 60 40],...
%     'callback',@gui3);
% 
% 
%       function gui1(obj,event)
%           figure(4)
%           txt1 = uicontrol(gcf,'Style','edit','String','1',...
%               'Position',[10 90 60 40]);
%           set(txt1,'Tag','txt1')
%       end
%       function gui2(obj,event)
%           figure(5)
%           txt1 = uicontrol(gcf,'Style','edit','String','2',...
%               'Position',[10 90 60 40]);
%           set(txt1,'Tag','txt2')
%       end
%       function gui3(obj,event)
%           figure(6)
%           txt3 = uicontrol(gcf,'Style','edit',...
%               'Position',[10 90 60 40]);
%           txt1=findall(0,'Tag','txt1');
%           txt2=findall(0,'Tag','txt2');
%           stxt1=get(txt1,'String')
%           stxt2=get(txt2,'String')
%           set(txt3,'String',num2str(str2num(stxt1)+str2num(stxt2)))
%       end
%   end