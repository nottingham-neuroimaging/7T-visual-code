function SPMIC_demo_02(varargin)
% SPMIC_demo_02 - play movie stimuli in a block design
%
%  purpose: load in one big movie w/ associated movietimes...
%           then play movies for, say, 12s and dynamic texture noised
%           for another 12
%
%  TODO:  -[ ] dynamic bg noise (change noise pattern every N frames)
%         -[ ] address movie at different times, ie cue to a segment
%         -[ ] play movie backwards? rate = -1.0 or similar idea.
%
%  **Very much work in progress as of March 2024**
%
% ds 2024-03-12 wrote it based on docs & demo

% get additional inputs?
eval(evalargs(varargin));

if ieNotDefined('screen'), mydisplay.screen = 1; else  mydisplay.screen = screen, end
if ieNotDefined('smallerWindow'), mydisplay.smallerWindow = true; else mydisplay.smallerWindow = smallerWindow; end

% check for PIXX presence
mydisplay.isPIXX = initPIXX(); % can check / false if not connected

% set up defaults for display etc.
mydisplay = initDisplay(mydisplay);

%% Setup key mapping:
mydisplay.keys = initKeys();

%% setup a cleanup function that gets called if problems
cleanup = onCleanup(@myCleanup);

% set up 1..N movies
[mydisplay, allM] = loadAllMovies(mydisplay);

% set movie to first on list
M = allM(1);

% add the image texture to the movie struct, too
N = makeNoiseTextures(mydisplay, 10);
M.imageTexture = N.imageTexture;

% wait for a buttn press - convert to wait for trigger??
tStart = KbWait();

% N = updateNoiesTextures;

% display a movie block
[mydisplay, M] = displayBlock(mydisplay, M, 12);

[mydisplay] = displayBlank(mydisplay, 12); % a blank block
% display a static block

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

function N = makeNoiseTextures(mydisplay, N_textures)

% make some static noise for N_textures frames...
%
%

% N_textures = 10; % magic number
noisePattern = rand(mydisplay.w*2, mydisplay.h*2, N_textures);
%imNoise(:,:,1) = noisePattern;
%imNoise(:,:,:,2) = noisePattern;
%imNoise(:,:,:,3) = noisePattern;
imNoise = repelem(noisePattern,1,1,1,3);

N.n = N_textures;
N.current = 1;
N.imNoise = permute(imNoise, [1,2,4,3]);

%% TODO -- for now, only pick one ... but reallyLOOP!
N.imageTexture = Screen('MakeTexture', mydisplay.win, N.imNoise(:,:,:,1));


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

if isstr(M) && isfile(M)
    moviename = M;
    clear('M'); % free it up first
    M.moviename = moviename;
    M.segLens = [];
    M.segStarts = [];
end

if ieNotDefined('M') || ~isfield(M, 'moviename'),
    M.moviename = [pwd() filesep() 'assets/ALL_MOVIES.mp4'];
    M.segLens = load('assets/movietimes.txt');
    M.segStarts = [0;cumsum(M.segLens)(1:end-1)];
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

disp('movie loaded and set up')
toc(t);
end

function [mydisplay, allM] = loadAllMovies(mydisplay)
% load all movies -- for now hardcoded - refactor at some point
%
% returns a struct with movie information (can pick 1..N)
inM = struct('moviename',{}, 'backgroundMaskOut', {}, 'tolerance', {}, 'scaled', {})
inM(1).moviename = [pwd(), '/assets/0_up.avi'];
inM(1).backgroundMaskOut = [17,17,17]/256;
inM(1).tolerance = 0.02;
inM(1).scaled = true;
inM(1).scaleFac = 0.75;


inM(2) = inM(1);
inM(2).moviename = [pwd(), '/assets/90_up.avi'];
inM(3) = inM(1);
inM(3).moviename = [pwd(), '/assets/180_up.avi'];


% loop over
for iMovie = 1:numel(inM)
    [mydisplay, allM(iMovie)] = setupMovieStimulus(mydisplay, inM(iMovie) );
end

end



function [mydisplay, M] = displayBlock(mydisplay, M, duration)
% displayBlock - display a block of a certain duration
%
% consider - calling into displayMovie(), displayBG(), displayStatic, displayDynamic()

if ieNotDefined('duration') && ~isfield(M, 'duration'),
    warning('setting default duration -- fix!!')
    M.duration = 1.5;
else
    M.duration = duration;
    fprintf('-- showing block for %.2f s\n', duration);
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
        Screen('DrawTexture', mydisplay.win, M.imageTexture, [], [], 0);
        Screen('DrawTexture', mydisplay.win, M.tex, [], M.dstRect, [], [], [], [], mydisplay.shader);

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
end
