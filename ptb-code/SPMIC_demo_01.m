function SPMIC_demo_01
% SPMIC_demo_01 - initial stimulus test / getting simple images up
%
% ds 2024-03-12 wrote it based on docs & demo

% check for PIXX presence
mydisplay.isPIXX = initPIXX(); % can check / false if not connected

% set up defaults for display etc.
mydisplay = initDisplay(mydisplay);

%% Setup key mapping:
keys = initKeys();
       
%% setup a cleanup function that gets called if problems
cleanup = onCleanup(@myCleanup);

s = setupStimulus();

while (mydisplay.abortit < 2) 

    % Check for abort / keypress:
    mydisplay.abortit = 0;
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if (keyIsDown == 1 && keyCode(keys.esc))
        % Set the abort-demo flag.
        mydisplay.abortit = 2;
        break;
    end

    % change display angle
    s.dispAngle = mod(s.dispAngle + s.dispAngleDiff, 2*pi());
    
    % compute new pos and display
    s = drawDotStim(mydisplay, s);

    % draw fixation point
    drawFixation(mydisplay);

    % Flip screen
    Screen('Flip',mydisplay.win);

end
        
Screen('Closeall');

mydisplay.closedDownOK = cleanupPIXX();


end

function myCleanup()
% making use of matlab onCleanup / when function exist abnormally
% ds

    sca;
    % only want to do this if an error occurred... look into this TODO
    % rethrow(lasterror); %#ok<LERR>

end

function drawFixation(mydisplay)
% draw a fixaton - make more generic later

Screen('FillRect', mydisplay.win, [0.1, 0.1, 0.1], ...
         CenterRectOnPoint([-10 -10 +10 +10], ...
            mydisplay.xCenter, mydisplay.yCenter));

end
    
function s = setupStimulus()
% set up dot stimulus as simple example

%% Set up some stimulus characteristics
s.dotRadius = 30;

%% Create some positions 
s.radius = 200;
        
%% set up angular displacement
s.dispAngle = 0;
s.dispAngleDiff = 0.005; % radians
s.colour = [1, 1, 0]; % yellow?!

end

function s = drawDotStim(mydisplay, s)
% drawDotStim - draw stimulus logic

s.x = mydisplay.xCenter + s.radius * sin(s.dispAngle);
s.y = mydisplay.yCenter + s.radius * cos(s.dispAngle);

Screen('FillOval', mydisplay.win, s.colour, ...
        CenterRectOnPoint([-s.dotRadius, -s.dotRadius, +s.dotRadius, +s.dotRadius], ...
                          s.x, s.y));

end
