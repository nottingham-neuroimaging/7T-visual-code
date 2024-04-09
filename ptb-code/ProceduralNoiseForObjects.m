function ProceduralNoiseForObjects()
% ProceduralNoiseForObjects - idea for dynamic, procedural noise
%
%
%
% adapted from ProceduralNoiseDemo([benchmark=0])
%
% History:
% 03/18/2011 Written (MK).
% 02/26/2012 Updated (MK).
% 2024-04-08, chopped up, ds


% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;

% setup a cleanup function that gets called if problems
cleanup = onCleanup(@myCleanup);

% Size of the patch:
res = [512 512];

% Contrast of the noise:
contrast = 0.8;

% Disable synctests for this quick demo:
oldSyncLevel = Screen('Preference', 'SkipSyncTests', 2);


% Setup imagingMode
imagingMode = 0;

% Open a small onscreen window on that display, choose a background
% color of 128 = gray with 50% max intensity:
mydisplay.smallerWindow = true;
mydisplay.rect = [0 0 res(1) res(2)];
mydisplay.bg = 128;

mydisplay = initDisplay(mydisplay)

% dealing with alpha blending.
% https://psychtoolbox.discourse.group/t/screen-blendfunction-applying-different-versions-to-different-textures-on-the-same-screen/3465/3
% Screen('Blendfunction', mydisplay.win, GL_ONE, GL_ONE);
% Screen('Blendfunction', mydisplay.win, GL_SRC_ALPHA, GL_SRC_ALPHA);

% texture w/h (2^3 coarser)
tw = res(1)/8;
th = res(2)/8;

% Build a procedural patch texture for a patch with a support of tw x th
% pixels, and a RGB color offset of 0.5 -- a 50% gray.

% noisetex = CreateProceduralNoise(mydisplay.win, tw, th, 'ClassicPerlin', [0.5 0.5 0.5 0.0]);
noisetex = CreateProceduralNoise(mydisplay.win, tw, th, 'ClassicPerlin', [0 0 0 0.0]);

% Draw the patch once, just to make sure the gfx-hardware is ready for the
% benchmark run below and doesn't do one time setup work inside the
% benchmark loop: See below for explanation of parameters...
% Screen('FillRect', mydisplay.win, mydisplay.gray);
Screen('DrawTexture', mydisplay.win, noisetex, [], [], 0, [], [], [], [], [], [contrast, 0,  0,0]);
% Perform initial flip to gray background and sync us to the retrace:
vbl = Screen('Flip', mydisplay.win);
ts = vbl;
count = 0;
tilt = 0;


% initialise seed 0 this gets updated every n frames
seed = 1;
updateEveryNFrames = 15; % figure out TF with fps calculation (TODO)

% set correct blend function
% Screen('Blendfunction', mydisplay.win, GL_SRC_ALPHA, GL_SRC_ALPHA);


% Animation loop: Run for many iterations:
while count < 1000

    count = count + 1;

    % Set new seed value for this frame:
    % but only change every N frames
    if mod(count,updateEveryNFrames) == 0
        seed = count;
    end

    % Draw the patch patch: We simply draw the procedural texture as any other
    % texture via 'DrawTexture', but provide the parameters for the patch as
    % optional 'auxParameters'.
    Screen('BlendFunction', mydisplay.win, GL_SRC_ALPHA, GL_ONE);
    Screen('FillRect', mydisplay.win, mydisplay.gray);

    Screen('Blendfunction', mydisplay.win, GL_ONE, GL_ONE);
    Screen('DrawTexture', mydisplay.win, noisetex, [], mydisplay.rect, tilt, [], [], [], [], [], [contrast, seed, 1, 1]);

    % Go at normal refresh rate for good looking patchs:
    Screen('Flip', mydisplay.win);


    % Abort requested? Test for keypress:
    if KbCheck(-1)
        break;
    end
end

% A final synced flip, so we can be sure all drawing is finished when we
% reach this point:
tend = Screen('Flip', mydisplay.win);

% Done. Print some fps stats:
avgfps = count / (tend - ts);
fprintf('The average framerate was %f frames per second.\n', avgfps);

% Close window, release all ressources:
sca;

% Restore old settings for sync-tests:
Screen('Preference', 'SkipSyncTests', oldSyncLevel);

% Done.
end


function myCleanup()
% making use of matlab onCleanup / when function exist abnormally
% ds

    sca;
    % only want to do this if an error occurred... look into this TODO
    % rethrow(lasterror); %#ok<LERR>

end