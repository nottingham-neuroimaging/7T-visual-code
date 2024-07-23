% script for testing key presses on ResponsePixx
%
%  gets key presses and trigger with good precision
% 
%  TODO: if you want to catch multiple keypresses at the same time, 
%        this needs some more work, as code "debounces" by default.
%
% 2024-06-20, rh, ez, ds testing in console room

WaitSecs(1.0); % make sure we don't catch "enter" key hit from running this script

% set up: this is important -- the DataPIXX hardware 
%         needs to be initialised. When writing your own, code, make sure you do 
%         this at the start of your experiment code
s = setupKeysSPMIC();

% run a loop and check buttons.
fprintf('(test) hit Q or Escape to quit this demo\n');

while ~KbCheck

    % use the function that also gets trigger
    o = getDigIOSPMIC([],true);

    % if that function returns something, display
    if ~isempty(o)
        if strcmp(o.keyColour, 't')
            disp("(test) @ TRIGGER!")
        else
            disp(['(test) X BUTTON ', o.keyColour]);
        end

        if numel(o) > 1
            disp('-- caught multiple key presses --');
        end
    end

end

% clean up (like adults). You should do this at the end of your
% experiment
cleanupKeysSPMIC();

disp('(test) got here in one piece - demo is finished')