function mydisplay = initDisplay(mydisplay)
% initDisplay - set up display settings for VPIXX set up
%
%  input: myscreen (struct) with fields that you might want to change.
% 
%         backgroundMask = [0 0 0] % by default
%
% ds 2024-03-13, wrote it

% TODO: default values for things that can be over-ridden by input. 
%       a solution for this is here:
%       https://uk.mathworks.com/matlabcentral/answers/461008-how-to-set-missing-fields-in-a-structure-array-to-default-values-stored-in-another-structure-array#answer_374183


% movie stuff...
mydisplay.backgroundMaskOut = [ 0 0 0]./256; % try black? 
mydisplay.tolerance = 0.01; % play with this to just catch bg
mydisplay.rate = 1.0;

% colors
mydisplay.black=BlackIndex(mydisplay.screen);
mydisplay.gray=GrayIndex(mydisplay.screen);
mydisplay.white=WhiteIndex(mydisplay.screen);

% screen / PTB related stuff
mydisplay.screenNums = Screen('Screens');
mydisplay.pixelFormat = []; % default
mydisplay.maxThreads = []; % default

if ~isfield(mydisplay,'bg'), mydisplay.bg = 0.5*(mydisplay.gray+mydisplay.white); end
if ~isfield(mydisplay,'smallerWindow'), mydisplay.smallerWindow = false; end
if ~isfield(mydisplay,'screen'), mydisplay.screen = 0; end
if ~isfield(mydisplay,'rect'), mydisplay.rect = [0 0 960 540]/2+100; end
if ~isfield(mydisplay,'smallerWindow') 
        mydisplay.smallerWindow = true; % draw in smaller window 1/4 of the total screen?
        mydisplay.rect = [0 0 960 540]/2+100;
end
if ~isfield(mydisplay,'stereoMode'), mydisplay.stereoMode = []; end
if ~isfield(mydisplay,'fixationType'), mydisplay.fixationType = 'cross'; end


if ismac(), Screen('Preference', 'SkipSyncTests', 1); end

%% Make sure things are going to be possible!
AssertOpenGL();

%% Initialize with unified keynames and normalized colorspace:
PsychDefaultSetup(2);

% Open onscreen window with gray background:
mydisplay.allScreens = Screen('Screens');
PsychImaging('PrepareConfiguration');
    
if mydisplay.smallerWindow
    [mydisplay.win, mydisplay.winrect] = PsychImaging('OpenWindow', mydisplay.screen, mydisplay.bg, mydisplay.rect,[],[],mydisplay.stereoMode);
else
    %Open a display on the Propixx
    [mydisplay.win, mydisplay.winrect] = PsychImaging('OpenWindow', mydisplay.screen, mydisplay.bg,[],[],[],mydisplay.stereoMode);
end

[mydisplay.w, mydisplay.h] = Screen('WindowSize', mydisplay.win);
[mydisplay.w_mm, mydisplay.h_mm] = Screen('DisplaySize', mydisplay.win);

% Get the centre coordinate of the window in pixels
[mydisplay.xCenter, mydisplay.yCenter] = RectCenter(mydisplay.winrect);



%% blending, cursor, shader stuff

% ON for bg removal... not for gratings?
Screen('Blendfunction', mydisplay.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
% Screen('Blendfunction', mydisplay.win, GL_SRC_ALPHA, GL_SRC_ALPHA);
HideCursor(mydisplay.win);



%% Initial display and sync to timestamp:
Screen('FillRect',mydisplay.win, mydisplay.bg);
Screen('Flip', mydisplay.win);

%% set keypress abort to 0
mydisplay.abortit = 0;

end