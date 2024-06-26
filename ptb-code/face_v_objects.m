 function mydisplay = face_v_objects(varargin)
% face_v_objects - simple localiser scan / testing
%
%  purpose: run a simple faces v object localiser scan
%           - trigger from fORP (for now)
%           - timing approx 12s on 12s off / 24s full cucle
%           - but adjust to TR
%
%
% ds 2024-03-12 wrote it based on docs & demo
% ds 2024-06-26 getting ready for scanning

% get additional inputs?
eval(evalargs(varargin));

if ieNotDefined('screen')
    mydisplay.screen = 0;
else
    mydisplay.screen = screen;
end
if ieNotDefined('smallerWindow')
    mydisplay.smallerWindow = false; 
else
    mydisplay.smallerWindow = smallerWindow; 
end

% check for PIXX presence
mydisplay.isPIXX = initPIXX(); % can check / false if not connected

% set up defaults for display etc.
mydisplay = initDisplay(mydisplay);

%% Setup key mapping:
mydisplay.keys = initKeys();

%% setup a cleanup function that gets called if problems
cleanup = onCleanup(@myCleanup);

%% general stimulus block durations (in seconds)
TR = 2.0;
nTRsPerBlock = 6;

restPeriod = nTRsPerBlock*TR; % 12
stimPeriod = nTRsPerBlock*TR; % 12?

% set up 1..N movies
[mydisplay, allM] = loadAllMovies(mydisplay);

% set movie to first on list
M = allM(1);

% add the image texture to the movie struct, too
N = makeNoiseTextures(mydisplay);
M.noiseid = N.noiseid;

% TO DO - break this out into setup function
% set up images stimuli (for static, rotating, expanind imaged on bg)
I.imagePath = [pwd(), filesep(), 'assets', filesep(), 'object-images' filesep() '*.jpg'];
[mydisplay, I] = setupStaticImageStimulus(mydisplay, I);
I.noiseid = N.noiseid;

F.imagePath = [pwd(), filesep(), 'assets', filesep(), 'face-images' filesep() '*.jpg'];
[mydisplay, F] = setupStaticImageStimulus(mydisplay, F);
F.noiseid = N.noiseid;


% mydisplay is better place for noiseid // remove from M, I etc.
mydisplay.noiseid = N.noiseid;

% wait for a buttn press - convert to wait for trigger??

% tStart = KbWait();
% tStart = GetSecs();
[r, tStart] = getTriggerSPMIC(mydisplay);

% N = updateNoiesTextures;

mydisplay.iBlock = 0; % start counting at 1
mydisplay.nBlocks = 10;

stimOrder = {};

while mydisplay.iBlock < mydisplay.nBlocks && ~mydisplay.abortit < 2
    
    % TODO - update seed for perlin procedural noise...
    mydisplay.noiseid = M.noiseid;
    
    % display a movie block
    % M.doubleup = true;
    % [mydisplay, M] = displayMovieBlock(mydisplay, M, stimPeriod);

    % blank
    [mydisplay] = displayBlank(mydisplay, restPeriod); % a blank block
    stimOrder{end+1} = ['r,', num2str(restPeriod), ',', sprintf('%.4f', GetSecs()-tStart)];
    
    fprintf('running block %d (of %d)\n', mydisplay.iBlock, mydisplay.nBlocks);
    
    % on odd blocks, show objects 
    if isodd(mydisplay.iBlock)
        % display a objects block
        [mydisplay, I] = displayImageBlock(mydisplay, I, stimPeriod);
        stimOrder{end+1} = ['o,', num2str(stimPeriod), ',', sprintf('%.4f', GetSecs()-tStart)];
    else % faces
        % display a faces block
        [mydisplay, F] = displayImageBlock(mydisplay, F, stimPeriod);
        stimOrder{end+1} = ['f,', num2str(stimPeriod), ',', sprintf('%.4f', GetSecs()-tStart)];
    end

    
end

% package data
data.mydisplay = mydisplay;
data.finished = datestr(now());
data.restPeriod = restPeriod;
data.stimPeriod = stimPeriod;
data.TR = TR;
data.stimOrder = stimOrder;

% and now save it
saveData(data); % with current timestamp

Screen('Flip', mydisplay.win);
KbReleaseWait;

% Done. Stop playback:
Screen('PlayMovie', M.movie, 0);

% Close movie object:
Screen('CloseMovie', M.movie);

% Show cursor again:
ShowCursor(mydisplay.win);

Screen('Closeall');

mydisplay.closedDownOK = cleanupPIXX();

% show what ran
disp(stimOrder)


end

function saveData(data)
% saveData - save out a single data struct for now

tmstamp = datestr(now(), 30);
fname = [tmstamp, 'data-fvo-' ,'mat'];
% options, files, variables...
save("-mat7-binary",fname, "data")
end

function myCleanup()
% making use of matlab onCleanup / when function exist abnormally
% ds

sca;
% only want to do this if an error occurred... look into this TODO
% rethrow(lasterror); %#ok<LERR>

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


function N = makeNoiseTextures(mydisplay)
% make some static noise for N_textures frames...
%
% N_textures determines how many different samples

% for now... make it coarser (TODO: break this out and pass in as factor
scaleFac = 6;
assert(rem(mydisplay.w,scaleFac)==0, 'scaleFac causes non-integer tex size')
assert(rem(mydisplay.h,scaleFac)==0, 'scaleFac causes non-integer tex size')

[N.noiseid, N.noiserect] = CreateProceduralNoise(mydisplay.win, mydisplay.w/scaleFac, mydisplay.h/scaleFac, ...
    'ClassicPerlin', [0.5 0.5 0.5 0.0]); 

% the following does not work on procedural textures...
% disp('blurring via GPU')
% % Example: Convolution with 13x13 gaussian blur operator:
% blurop = CreateGLOperator(mydisplay.win); 
% Add2DConvolutionToGLOperator(blurop, fspecial('gaussian', 13, 5.5));
% 
% % Applying the blurring
% N.noiseid = Screen('TransformTexture', N.noiseidIn, blurop);

end


function [mydisplay, I] = setupStaticImageStimulus(mydisplay, I)
% setupStaticImageStimulus - set up and return images stimulus
%
% either
%  I.imagePath = [pwd(), filesep(), 'assets', filesep(), 'object-images' filesep() '*.jpg'];
%  I = setupStaticImageStimulus(mydisplay, I)
%
% 

MAX_FILES_TO_LOAD = 100;

t = tic();

if ~isfield(I, 'imagePath') 
    error('need to provide image path field ')
end

% try
% loading all the images in path
files = dir(I.imagePath);
nFiles = numel(files);
fprintf('there are %d files\n', nFiles);

if ~isfield(I, 'loadAll'), I.loadAll = false(); end

I.n = nFiles;
I.images = struct();
I.backgroundMaskOut =  [1, 1, 1];
I.tolerance = 0.08;

if I.loadAll 
    filesToLoad = 1:nFiles;
else
    filesToLoad = randperm(nFiles);
    filesToLoad = filesToLoad(1:max(MAX_FILES_TO_LOAD,nFiles)); %only keep maxfiles or 100, whichever is greater
end

for iFile = 1:nFiles
    pname = files(iFile).folder;
    fname = files(iFile).name;
    
    if mod(iFile, 5) == 0
        fprintf('processing file: %s [%d/%d]\n', fname, iFile, nFiles);
    end
    theImage = imread(fullfile(pname, fname));

    % Get the size of the image
    I.images(iFile).sz = size(theImage);
    
    % Make the image into a texture
    I.images(iFile).tex = Screen('MakeTexture', mydisplay.win, theImage);
end

%% set up background filtering
if isfield(I, 'backgroundMaskOut') && ...
        isfield(I, 'tolerance')
    mydisplay.shader = CreateSinglePassImageProcessingShader(mydisplay.win, 'BackgroundMaskOut', I.backgroundMaskOut, I.tolerance);
end

% figure out how big they need to be
% 256 pixels in some kind of destRect

end


function [mydisplay, M] = setupMovieStimulus(mydisplay, M)
% setupMovieStimulus - set up and return movie stimulus
%
% either
%  M.moviename = [pwd(), filesep(), 'assets', filesep(), 'ALL_MOVIES.mp4' ];
%  M = setupMovieStimulus(mydisplay, M)
%
% or
%  M = setupMovieStimulus(mydisplay, [pwd(), '/assets/0_up.avi'] )

t = tic();
% user called with a string that contains filename

if ischar(M) && isfile(M)
    moviename = M;
    clear('M'); % free it up first
    M.moviename = moviename;
    M.segLens = [];
    M.segStarts = [];
end

if ieNotDefined('M') || ~isfield(M, 'moviename')
    M.moviename = [pwd() filesep() 'assets/face-movies/ALL_MOVIES.mp4'];
    M.segLens = load('assets/movietimes.txt');
    M.segStarts = [0;cumsum(M.segLens)];
    M.segStarts = M.segStarts(1:end-1);
end


%% set up background filtering
if isfield(M, 'backgroundMaskOut') && ...
        isfield(M, 'tolerance')
    mydisplay.shader = CreateSinglePassImageProcessingShader(mydisplay.win, 'BackgroundMaskOut', M.backgroundMaskOut, M.tolerance);
end

% Use blocking wait for new frames by default:
M.blocking = 1;

% Default preload setting:
M.preloadsecs = [];

% Show title while movie is loading/prerolling:
[M.path, M.fileStem, M.format] = fileparts(M.moviename);
DrawFormattedText(mydisplay.win, ['Loading ...\n' M.fileStem], 'center', 'center', 0, 40);
Screen('Flip', mydisplay.win);

% Open movie file and retrieve basic info about movie:
%[movie, movieduration, fps, imgw, imgh, ~, ~, hdrStaticMetaData] = Screen('OpenMovie', mydisplay.win, moviename, [], preloadsecs, [], mydisplay.pixelFormat, mydisplay.maxThreads, []);
[M.movie, M.movieduration, ...
    M.fps, M.imgw, M.imgh, ~, ~, ...
    M.hdrStaticMetaData] = Screen('OpenMovie', mydisplay.win, M.moviename, [], M.preloadsecs, [], mydisplay.pixelFormat, mydisplay.maxThreads, []);

fprintf('Movie: %s  : %f seconds duration, %f fps, w x h = %i x %i...\n', M.fileStem, M.movieduration, M.fps, M.imgw, M.imgh);
if M.imgw > mydisplay.w || M.imgh > mydisplay.h
    % Video frames too big to fit into window, so define size to be window size:
    M.dstRect = CenterRect((mydisplay.h / M.imgh) * [0, 0, M.imgw, M.imgh], Screen('Rect', mydisplay.win));
elseif isfield(M, 'scaled') && M.scaled == true
    M.dstRect = CenterRect((mydisplay.h / M.imgh) * M.scaleFac * [0, 0, M.imgw, M.imgh], Screen('Rect', mydisplay.win));
else
    M.dstRect = [];
end

% Color the screen bg color
if isfield(mydisplay, 'noiseid')
    Screen('DrawTexture', mydisplay.win, mydisplay.noiseid, [], mydisplay.winrect, 0);
else
    Screen('FillRect', mydisplay.win, mydisplay.bg);
end

drawFixation(mydisplay);
Screen('Flip', mydisplay.win);

disp('movie loaded and set up')
toc(t);
end

function [mydisplay, allM] = loadAllMovies(mydisplay)
% load all movies -- for now hardcoded - refactor at some point
%
% returns a struct with movie information (can pick 1..N)
% inM = struct('moviename',{}, 'backgroundMaskOut', {}, 'tolerance', {}, 'scaled', {});
% inM(1).moviename = [pwd(), '/assets/face-movies/0_up.avi'];
% inM(1).backgroundMaskOut = [17,17,17]/256;
% inM(1).tolerance = 0.02;
% inM(1).scaled = true;
% inM(1).scaleFac = 0.75;
% 
% 
% inM(2) = inM(1);
% inM(2).moviename = [pwd(), '/assets/face-movies/90_up.avi'];
% inM(3) = inM(1);
% inM(3).moviename = [pwd(), '/assets/face-movies/180_up.avi'];


inM = struct('moviename',{}, 'backgroundMaskOut', {}, 'tolerance', {}, 'scaled', {});
inM(1).moviename = [pwd(), '/assets/face-movies/ALL_MOVIES.mp4'];
inM(1).backgroundMaskOut = [0,0,0]/256;
inM(1).tolerance = 0.02;
inM(1).scaled = true;
inM(1).scaleFac = 0.9;


% loop over
for iMovie = 1:numel(inM)
    [mydisplay, allM(iMovie)] = setupMovieStimulus(mydisplay, inM(iMovie) );
end

end

function [mydisplay, M] = displayMovieBlock(mydisplay, M, duration)
% displayBlock - display a block of a certain duration
%
% consider - calling into displayMovie(), displayBG(), displayStatic, displayDynamic()

if ieNotDefined('duration') && ~isfield(M, 'duration')
    warning('setting default duration -- fix!!')
    M.duration = 1.5;
else
    M.duration = duration;
    fprintf('-- showing block for %.2f s\n', duration);
end

% make sure mask out color is updated (black for movies, white for
% images...)
if isfield(M, 'backgroundMaskOut') && ...
        isfield(M, 'tolerance')
    mydisplay.shader = CreateSinglePassImageProcessingShader(mydisplay.win, 'BackgroundMaskOut', M.backgroundMaskOut, M.tolerance);
end


% Play 'movie', at a playbackrate = 1, with endless loop=1 and
% 0.0 == 0% audio volume.
Screen('PlayMovie', M.movie, mydisplay.rate, 1, 0.0);

t1 = GetSecs;

i=0;

% Infinite playback loop: Fetch video frames and display them...
while 1 && (GetSecs()-t1) < M.duration
    
    % Check for abortion:
    mydisplay.abortit = 0;
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if (keyIsDown == 1 && keyCode(mydisplay.keys.esc))
        % Set the abort-demo flag.
        mydisplay.abortit = 2;
        break;
    end
    
    
    % Only perform video image fetch/drawing if playback is active
    % and the movie actually has a video track (imgw and imgh > 0):
    if ((abs(mydisplay.rate)>0) && (M.imgw > 0) && (M.imgh > 0))
        % Return next frame in movie, in sync with current playback
        % time and sound.
        % tex is either the positive texture handle or zero if no
        % new frame is ready yet in non-blocking mode (blocking == 0).
        % It is -1 if something went wrong and playback needs to be stopped:
        M.tex = Screen('GetMovieImage', mydisplay.win, M.movie, M.blocking);
        
        % Valid texture returned?
        if M.tex < 0, break; end
        
        % No new frame in polling wait (blocking == 0). Just sleep
        if M.tex == 0, WaitSecs('YieldSecs', 0.005); continue; end
        
        % Draw the new texture immediately to screen:
        contrast = 1.0;
        seed = 1;
        % Screen('DrawTexture', windowPtr, noiseid, [], dstRect, [], [], [], ...
        %         modulateColor, [], [], [contrast, seed, 0, 0]);
        % Screen('DrawTexture', mydisplay.win, M.noiseid, [], mydisplay.winrect,[], [], [], ...
        %    [], [],[], [contrast, seed, 0, 0]);
        
        if isfield(M,'doubleup') && M.doubleup == true
            delta = [1 0 1 0]*mydisplay.w/5;
            Screen('DrawTexture', mydisplay.win, M.tex, [], M.dstRect-delta, [], [], [], [], mydisplay.shader);
            Screen('DrawTexture', mydisplay.win, M.tex, [], M.dstRect+delta, [], [], [], [], mydisplay.shader);
        else
            Screen('DrawTexture', mydisplay.win, M.tex, [], M.dstRect, [], [], [], [], mydisplay.shader);
        end

        % draw fixation point
        drawFixation(mydisplay);
        
        
        % Regular without real use of imaging pipeline. Skip waiting
        % for flip completion, to squeeze out a bit more fps:
        Screen('Flip', mydisplay.win, [], [], 1);
        
        
        % Release texture:
        Screen('Close', M.tex);
        
        % Framecounter:
        i=i+1;
    end
    
    
end

telapsed = GetSecs - t1;
fprintf('Elapsed time %f seconds, for %i frames. Average framerate %f fps.\n', telapsed, i, i / telapsed);

% increase block count!
mydisplay.iBlock = mydisplay.iBlock + 1;

end

function [mydisplay, M] = displayBlank(mydisplay, duration)
% displayBlank - show a blank screen w/ fixation for duration
%
%

% Get timestamp
t1 = GetSecs();

while 1 && (GetSecs()-t1) < duration
    
    % Check for abortion:
    mydisplay.abortit = 0;
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if (keyIsDown == 1 && keyCode(mydisplay.keys.esc))
        % Set the abort-demo flag.
        mydisplay.abortit = 2;
        break;
    end
    
    
    % Color the screen bg color
    if isfield(mydisplay, 'noiseid')
        Screen('DrawTexture', mydisplay.win, mydisplay.noiseid, [], mydisplay.winrect, 0);
    else
        Screen('FillRect', mydisplay.win, mydisplay.bg);
    end
    
    drawFixation(mydisplay);
    
    % Flip to the screen
    Screen('Flip', mydisplay.win);
    
end

% do not increase block count!
% mydisplay.iBlock = mydisplay.iBlock + 1;
% this is to make sure we only count the stimulus blocks

end

%% 
function [mydisplay, I] = displayImageBlock(mydisplay, I, duration)
% displayImageBlock - display a block of a certain duration
%
% consider - calling into displayMovie(), displayBG(), displayStatic, displayDynamic()

if ieNotDefined('duration') && ~isfield(I, 'duration')
    warning('setting default duration -- fix!!')
    I.duration = 1.5;
else
    I.duration = duration;
    fprintf('-- showing block for %.2f s\n', duration);
end

if isfield(I, 'backgroundMaskOut') && ...
        isfield(I, 'tolerance')
    mydisplay.shader = CreateSinglePassImageProcessingShader(mydisplay.win, 'BackgroundMaskOut', I.backgroundMaskOut, I.tolerance);
end


t1 = GetSecs;

i=0;
elapsedT = GetSecs()-t1;
elapsedTex = 1;

I.iTex = 1;
% Infinite playback loop: Fetch image texture at a particular rate
while 1 && elapsedT < I.duration
    
    % Check for abortion:
    mydisplay.abortit = 0;
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if (keyIsDown == 1 && keyCode(mydisplay.keys.esc))
        % Set the abort-demo flag.
        mydisplay.abortit = 2;
        break;
    end
    
    
    % grab a prepared texture
    I.tex = I.images(I.iTex).tex;
    
    % Valid texture returned?
    if I.tex < 0, break; end
        
    % No new frame in polling wait (blocking == 0). Just sleep
    if I.tex == 0, WaitSecs('YieldSecs', 0.005); continue; end
    
    % check if texture counter needs to be updated
    if elapsedT > elapsedTex 
        % if time in s is bigger than counter, then switch
        % this means that stimuli should change at 1Hz?
        I.iTex = randi(I.n, 1); % pick a random one from the list
        elapsedTex = elapsedTex +1; 
    end  
    % Draw the new texture immediately to screen:
        
    modulateColor = [0 0 0];
    contrast = 0.5;
    seed = 1;
    % Screen(.DrawTexture., windowPointer, texturePointer [,sourceRect] [,destinationRect] ...
    % [,rotationAngle] [, filterMode] [, globalAlpha] ...
    % [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
    Screen('DrawTexture', mydisplay.win, I.noiseid, [], mydisplay.winrect, ...
        [], [], [], ...
        modulateColor, [], [], [contrast, seed, 0, 0]);
    % Screen('DrawTexture', mydisplay.win, I.imageTexture, [], mydisplay.winrect, 0);
    %                                               M.dstRect    
    
    Screen('DrawTexture', mydisplay.win, I.tex, [], []       , [], [], [], [], mydisplay.shader);
        
    % draw fixation point
    drawFixation(mydisplay);
        
        
    % Regular without real use of imaging pipeline. Skip waiting
    % for flip completion, to squeeze out a bit more fps:
    Screen('Flip', mydisplay.win, [], [], 1);
        
    % Framecounter:
    i=i+1;
    elapsedT = GetSecs()-t1;
end

% Release texture / not needed? causes error on esc, abort!
% Screen('Close', I.tex);

telapsed = GetSecs - t1;
fprintf('Elapsed time %f seconds, for %i frames. Average framerate %f fps.\n', telapsed, i, i / telapsed);

% increase block count!
mydisplay.iBlock = mydisplay.iBlock + 1;

end

