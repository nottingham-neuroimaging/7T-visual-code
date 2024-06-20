% script for testing key presses on ResponsePixx
%
% 2024-06-20, rh, ez, ds testing in console room

WaitSecs(1.0); % make sure we don't catch enter from running script

% set up
setupKeysSPMIC()

% run a loop and do some magic 
while ~KbCheck

    getKeysSPMIC()

end

% clean up (like adults)
cleanupKeysSPMIC();

disp('got here in one piece')