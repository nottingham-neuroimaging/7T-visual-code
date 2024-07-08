function [out] = setupKeysSPMIC()
% setupKeysSPMIC - set up ReponsePixx stuff for reading keys
%
% see also: DatapixxDinBasicDemo
%
% 2024-06-20, in console room

%TODO think about returning some settings / params in a struct
% for logging ind ata filas.
AssertOpenGL;   % We use PTB-3
    
% Open Datapixx, and stop any schedules which might already be running
Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache

% Show how many TTL input bits are in the Datapixx
nBits = Datapixx('GetDinNumBits');
fprintf('\nDATAPixx has %d TTL input bits\n', nBits);
out.nBits = nBits;

% RESPONSEPixx has 5 illuminated buttons.
% We drive those button lights by turning around 5 DIN bits to outputs.
% Test paradigms could illuminate only the buttons which are valid in context.
% (eg: 1 button when waiting for subject to initiate a trial,
% 2 other buttons when waiting for 2-alternative forced-choice response).
Datapixx('SetDinDataDirection', hex2dec('1F0000'));
Datapixx('SetDinDataOut', hex2dec('1F0000')); 
Datapixx('SetDinDataOutStrength', 1);   % Set brightness of buttons

% We'll say that we want to calculate response times
% from a stimulus appearing at the next vertical sync.
Datapixx('SetMarker');
Datapixx('RegWrRdVideoSync');
stimulusOnsetTime = Datapixx('GetMarker');
out.stimulusOnsetTime = stimulusOnsetTime;

% Fire up the logger
Datapixx('EnableDinDebounce');      % Filter out button bounce
%Datapixx('DisableDinDebounce');    % Uncomment this line to log gruesome details of button bounce
Datapixx('SetDinLog');              % Configure logging with default values
Datapixx('StartDinLog');
Datapixx('RegWrRd');

% clean up console
if (exist('OCTAVE_VERSION'))
    fflush(stdout);
end


end
