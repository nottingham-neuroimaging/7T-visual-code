function r = getTriggerSPMIC(mydisplay)
% getTriggerSPMIC - get the trigger from key 5 via USB
%
% ds 2024-05-24 getting ready for VPIXX reprise

if ieNotDefined('mydisplay')
    error('(uhoh) need to provide mydisplay for keycodes');
end

t1 = GetSecs;

while 1 % && (GetSecs()-t1)  < M.duration
    
    % Check for abortion:
    mydisplay.abortit = 0;
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    
    if (keyIsDown == 1 && keyCode(mydisplay.keys.esc))
        % Set the abort-demo flag.
        mydisplay.abortit = 2;
        r = 2;
        disp('@ABORT!');
        break;
    end

    % check for trigger
    if (keyIsDown == 1 && keyCode(mydisplay.keys.trigger))
        % Set the abort-demo flag.
        mydisplay.abortit = 2; % TODO
        r = 2;
        disp('@TRIGGER');
        break;
    end

end

end