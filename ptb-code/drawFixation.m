function drawFixation(mydisplay)
% draw a fixaton - make more generic later

fix.color = [0.6, 0.2, 0.2];
fix.width = 4;

if isfield(mydisplay,'fixationType') && strcmpi(mydisplay.fixationType,'cross');
    xy1 = [-15 +15 ;  0  0] + repelem([mydisplay.xCenter; mydisplay.yCenter], 1,2);
    xy2 = [ 0  0 ; -15 +15] + repelem([mydisplay.xCenter; mydisplay.yCenter], 1,2);

    % two layers

    Screen('DrawLines', mydisplay.win, xy1, fix.width*2, 1-fix.color, [], 1, []);
    Screen('DrawLines', mydisplay.win, xy2, fix.width*2, 1-fix.color, [], 1, []);

    Screen('DrawLines', mydisplay.win, xy1, fix.width, fix.color, [], 1, []);
    Screen('DrawLines', mydisplay.win, xy2, fix.width, fix.color, [], 1, []);

    % Screen('FillRect', mydisplay.win, color, ...
    %    CenterRectOnPoint([-5 -5 +5 +5], ...
    %    mydisplay.xCenter, mydisplay.yCenter));

else
    Screen('FillRect', mydisplay.win, [0.8, 0.1, 0.1], ...
        CenterRectOnPoint([-5 -5 +5 +5], ...
        mydisplay.xCenter, mydisplay.yCenter));
end

end