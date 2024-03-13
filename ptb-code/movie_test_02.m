function movie_test_02(moviename, backgroundMaskOut, tolerance )
% movie_test_02 - taking code from PlayMoviesDemo and turning it into a
% task
%
%
%  see also: PlayMovieDemo, PsychDemos 
%
% ds 2024-02-29 - started

% force... to work on macos
Screen('Preference', 'SkipSyncTests', 1)

if ieNotDefined('moviename')
    
    moviename = [pwd() filesep() 'assets' filesep() 'surprise.mp4'];

end

% make sure error handling is ok and we don't get stuck behind a black
% screen

cleanup = onCleanup(@myCleanup);

% provide details for experiment / display in general
% TODO .. break out video / stim stuff.
mydisplay.backgroundMaskOut = [ 0 0 0]./256; % try black? could green screen as well!
mydisplay.tolerance = 0.02; % play with this to just catch bg
mydisplay.rate = 1.5;

mydisplay.screenNums = Screen('Screens');
mydisplay.smallerWindow = 1; % draw in smaller window 1/4 of the total screen?


mydisplay.pixelFormat = []; % default
mydisplay.maxThreads = []; % default


mydisplay.bg = [1 1 1]*0.5;
mydisplay.rect = [0 0 800, 600]+100;

% History:
% 06/17/13  mk  Add new (c)ool movies, remove Apple PRopaganda videos, cleanup.
% 2024-02-29 ds - transmogrified into experiment code.



 
%% Initialize with unified keynames and normalized colorspace:
PsychDefaultSetup(2);

%% Setup key mapping:
keys = setupKeys()

mydisplay = setupExperiment(mydisplay);
% mydisplay.screen .win .w .h .shader

       
%% Initial display and sync to timestamp:
Screen('Flip', mydisplay.win);
mydisplay.abortit = 0;

% Use blocking wait for new frames by default:
blocking = 1;

% Default preload setting:
preloadsecs = [];


% Endless loop, runs until ESC key pressed:
while (mydisplay.abortit < 2)


    % Show title while movie is loading/prerolling:
    DrawFormattedText(mydisplay.win, ['Loading ...\n' moviename], 'center', 'center', 0, 40);
    Screen('Flip', mydisplay.win);

    % Open movie file and retrieve basic info about movie:
    %[movie, movieduration, fps, imgw, imgh, ~, ~, hdrStaticMetaData] = Screen('OpenMovie', mydisplay.win, moviename, [], preloadsecs, [], mydisplay.pixelFormat, mydisplay.maxThreads, []);
    [movie, movieduration, fps, imgw, imgh, ~, ~, hdrStaticMetaData] = Screen('OpenMovie', mydisplay.win, moviename, [], preloadsecs, [], mydisplay.pixelFormat, mydisplay.maxThreads, []);
    
    fprintf('Movie: %s  : %f seconds duration, %f fps, w x h = %i x %i...\n', moviename, movieduration, fps, imgw, imgh);
    if imgw > mydisplay.w || imgh > mydisplay.h
        % Video frames too big to fit into window, so define size to be window size:
        dstRect = CenterRect((mydisplay.w / imgw) * [0, 0, imgw, imgh], Screen('Rect', mydisplay.win));
    else
        dstRect = [];
    end

    %% make some static noise
    noisePattern = rand(imgw*2, imgh*2);
    imNoise(:,:,1) = noisePattern;
    imNoise(:,:,2) = noisePattern;
    imNoise(:,:,3) = noisePattern;

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
end

% Show cursor again:
ShowCursor(mydisplay.win);

% Close screens.
% sca;

end

%% cleanup

function myCleanup()
% making use of matlab onCleanup / when function exist abnormally
% ds

 sca;
 % only want to do this if an error occurred... look into this TODO
 % rethrow(lasterror); %#ok<LERR>
 
end

function keys = setupKeys()
% set up keycodes / return in struct

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

 % Open onscreen window with gray background:
 mydisplay.screen = max(Screen('Screens'));
 PsychImaging('PrepareConfiguration');
 
 if mydisplay.smallerWindow
    mydisplay.win = PsychImaging('OpenWindow', mydisplay.screen, mydisplay.bg, mydisplay.rect);
 else
    mydisplay.win = PsychImaging('OpenWindow', mydisplay.screen, mydisplay.bg);
 end

 [mydisplay.w, mydisplay.h] = Screen('WindowSize', mydisplay.win);
 Screen('Blendfunction', mydisplay.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 HideCursor(mydisplay.win);

 %% set up background filtering
 mydisplay.shader = CreateSinglePassImageProcessingShader(mydisplay.win, 'BackgroundMaskOut', mydisplay.backgroundMaskOut, mydisplay.tolerance);

 % returns mydisplay with various fields.
end