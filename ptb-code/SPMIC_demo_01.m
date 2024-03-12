function SPMIC_demo_01
% SPMIC_demo_01 - initial stimulus test / getting simple images up
%
% ds 2024-03-12 wrote it based on docs & demo

ok = initPIXX(); % can check

% movie stuff...
mydisplay.backgroundMaskOut = [ 0 0 0]./256; % try black? could green screen as well!
mydisplay.tolerance = 0.02; % play with this to just catch bg
mydisplay.rate = 1.5;

mydisplay.screenNums = Screen('Screens');

mydisplay.pixelFormat = []; % default
mydisplay.maxThreads = []; % default

mydisplay.bg = [1 1 1]*0.5;
mydisplay.rect = [0 0 800, 600]+100;


if ok 
    myscreen.screen = 2;
    mydisplay.smallerWindow = 0; 
else % debug mode
    % likely to be on a mac, so also skip screen tests
    myscreen.screen = 0;
    mydisplay.smallerWindow = 1; % draw in smaller window 1/4 of the total screen?
    Screen('Preference', 'SkipSyncTests', 1)
end


%% Setup key mapping:
keys = setupKeys()

mydisplay = setupExperiment(mydisplay);
% mydisplay.screen .win .w .h .shader

       
%% Initial display and sync to timestamp:
Screen('Flip', mydisplay.win);
mydisplay.abortit = 0;



cleanup = onCleanup(@myCleanup);



%Set up some stimulus characteristics
dotRadius = 30;

%Create some positions based on the regular display
center = [mydisplay.rect(3), mydisplay.rect(4)] - ...
    [mydisplay.rect(1), mydisplay.rect(2)]./2;
radius = 200;
        
%Start displaying dots
dispAngle = 0;
dispAngleDiff = 0.005; % radians
colour = [1, 1, 0]; % yellow?!
while (mydisplay.abortit < 2) 

    % Check for abortion:
    mydisplay.abortit = 0;
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if (keyIsDown == 1 && keyCode(keys.esc))
        % Set the abort-demo flag.
        mydisplay.abortit = 2;
        break;
    end

    dispAngle = mod(dispAngle + dispAngleDiff, 2*pi())

    x = center(1) + radius * sin(dispAngle);
    y = center(2) + radius * cos(dispAngle);

    Screen('FillOval', mydisplay.win, colour, ...
        [x-dotRadius, y-dotRadius, x+dotRadius, y+dotRadius]);

    Screen('FillRect', mydisplay.win, [0.1, 0.1, 0.1], ...
         [-10 -10 +10 +10]+[center  center]);

    %Flip
    Screen('Flip',mydisplay.win);

end
        
Screen('Closeall');


ok = cleanupPIXX();


end

function myCleanup()
% making use of matlab onCleanup / when function exist abnormally
% ds

    sca;
    % only want to do this if an error occurred... look into this TODO
    % rethrow(lasterror); %#ok<LERR>

end

function keys = setupKeys()
% set up keycodes / return in struct

    KbName('UnifyKeyNames');
    
    keys.space = KbName('SPACE');
    keys.esc=KbName('ESCAPE');
    keys.right=KbName('RightArrow');
    keys.left=KbName('LeftArrow');
    keys.up=KbName('UpArrow');
    keys.down=KbName('DownArrow');
    keys.shift=KbName('RightShift');
    keys.colorPicker=KbName('c');
    
end
    
    
function mydisplay = setupExperiment(mydisplay)
% setup and open window

    AssertOpenGL();
    %% Initialize with unified keynames and normalized colorspace:
    PsychDefaultSetup(2);

    % Open onscreen window with gray background:
    mydisplay.screen = max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    
    if mydisplay.smallerWindow
        mydisplay.win = PsychImaging('OpenWindow', mydisplay.screen, mydisplay.bg, mydisplay.rect);
    else
        %Open a display on the Propixx
        mydisplay.win = PsychImaging('OpenWindow', mydisplay.screen, mydisplay.bg);
    end

    [mydisplay.w, mydisplay.h] = Screen('WindowSize', mydisplay.win);
    Screen('Blendfunction', mydisplay.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    HideCursor(mydisplay.win);

    %% set up background filtering
    mydisplay.shader = CreateSinglePassImageProcessingShader(mydisplay.win, 'BackgroundMaskOut', mydisplay.backgroundMaskOut, mydisplay.tolerance);

    % returns mydisplay with various fields.
end