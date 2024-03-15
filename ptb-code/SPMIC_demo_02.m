function SPMIC_demo_02
% SPMIC_demo_02 - play movie stimuli in a block design
%
%  purpose: load in one big movie w/ associated movietimes...
%           then play movies for, say, 12s and dynamic texture noised
%           for another 12
%
%  **Very much work in progress as of March 2024**
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

% s = setupStimulus();
% M = setupMovieStimulus(); % to be done
M.moviename = [pwd() filesep() 'assets/ALL_MOVIES.mp4'];
M.segLens = load('assets/movietimes.txt');
M.segStart = [0;cumsum(M.segLens)(1:end-1)]; 

% Use blocking wait for new frames by default:
blocking = 1;

% Default preload setting:
preloadsecs = [];

% Show title while movie is loading/prerolling:
[M.path, M.fileStem, M.format] = fileparts(M.moviename);
DrawFormattedText(mydisplay.win, ['Loading ...\n' M.fileStem], 'center', 'center', 0, 40);
Screen('Flip', mydisplay.win);

% Open movie file and retrieve basic info about movie:
%[movie, movieduration, fps, imgw, imgh, ~, ~, hdrStaticMetaData] = Screen('OpenMovie', mydisplay.win, moviename, [], preloadsecs, [], mydisplay.pixelFormat, mydisplay.maxThreads, []);
[movie, movieduration, fps, imgw, imgh, ~, ~, hdrStaticMetaData] = Screen('OpenMovie', mydisplay.win, M.moviename, [], preloadsecs, [], mydisplay.pixelFormat, mydisplay.maxThreads, []);

fprintf('Movie: %s  : %f seconds duration, %f fps, w x h = %i x %i...\n', M.fileStem, movieduration, fps, imgw, imgh);
if imgw > mydisplay.w || imgh > mydisplay.h
    % Video frames too big to fit into window, so define size to be window size:
    dstRect = CenterRect((mydisplay.w / imgw) * [0, 0, imgw, imgh], Screen('Rect', mydisplay.win));
else
    dstRect = [];
end

N = makeNoiseTextures(mydisplay);

tStart = KbWait();


% N = updateNoiesTextures;

imageTexture = Screen('MakeTexture', mydisplay.win, imNoise);

% Play 'movie', at a playbackrate = 1, with endless loop=1 and
% 0.0 == 0% audio volume.
Screen('PlayMovie', movie, mydisplay.rate, 1, 0.0);

t1 = GetSecs;

i=0;

% Infinite playback loop: Fetch video frames and display them...
while 1

    % Check for abortion:
    mydisplay.abortit = 0;
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if (keyIsDown == 1 && keyCode(keys.esc))
        % Set the abort-demo flag.
        mydisplay.abortit = 2;
        break;
    end


    % Only perform video image fetch/drawing if playback is active
    % and the movie actually has a video track (imgw and imgh > 0):
    if ((abs(mydisplay.rate)>0) && (imgw > 0) && (imgh > 0))
        % Return next frame in movie, in sync with current playback
        % time and sound.
        % tex is either the positive texture handle or zero if no
        % new frame is ready yet in non-blocking mode (blocking == 0).
        % It is -1 if something went wrong and playback needs to be stopped:
        tex = Screen('GetMovieImage', mydisplay.win, movie, blocking);

        % Valid texture returned?
        if tex < 0, break; end
        
        % No new frame in polling wait (blocking == 0). Just sleep 
        if tex == 0, WaitSecs('YieldSecs', 0.005); continue; end

        % Draw the new texture immediately to screen:
        Screen('DrawTexture', mydisplay.win, imageTexture, [], [], 0);
        Screen('DrawTexture', mydisplay.win, tex, [], dstRect, [], [], [], [], mydisplay.shader);

        % draw fixation point
        drawFixation(mydisplay);


        % Regular without real use of imaging pipeline. Skip waiting
        % for flip completion, to squeeze out a bit more fps:
        Screen('Flip', mydisplay.win, [], [], 1);


        % Release texture:
        Screen('Close', tex);

        % Framecounter:
        i=i+1;
    end


end

telapsed = GetSecs - t1;
fprintf('Elapsed time %f seconds, for %i frames. Average framerate %f fps.\n', telapsed, i, i / telapsed);

Screen('Flip', mydisplay.win);
KbReleaseWait;

% Done. Stop playback:
Screen('PlayMovie', movie, 0);

% Close movie object:
Screen('CloseMovie', movie);

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

function N = makeNoiseTextures(mydisplay)
% make some static noise

N_textures = 10; % magic number
noisePattern = rand(mydisplay.w*2, mydisplay.h*2, N_textures);
%imNoise(:,:,1) = noisePattern;
%imNoise(:,:,:,2) = noisePattern;
%imNoise(:,:,:,3) = noisePattern;
imNoise = repelem(noisePattern,1,1,1,3);

N.n = N_textures;
N.current = 1;
N.imNoise = permute(imNoise, [1,2,4,3]);

end