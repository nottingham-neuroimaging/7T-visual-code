function whichKeys = getKeysSPMIC(stimulusOnsetTime)
% getKeysSPMIC - read out ResponsePixx button presses
%
% just gets an instantaneous readout... need to run inside the main 
% display loop in stim program
%
% 2024-06-20, in console room

if nargin < 1 || isempty(stimulusOnsetTime)
    stimulusOnsetTime = Datapixx('GetMarker');
end

% Report logged button activity until keyboard is pressed
%fprintf('\nPlug button box into Digital IN db-25\n');
%fprintf('Press buttons to see new log entries\n');
%fprintf('Hit any key to stop...\n');

    Datapixx('RegWrRd');
    status = Datapixx('GetDinStatus');
    if (status.newLogFrames > 0)
        [data tt] = Datapixx('ReadDinLog');
        for i = 1:status.newLogFrames
            fprintf('responseTime = %f', tt(i)-stimulusOnsetTime);
            fprintf(', button states = ');
            for bit = 15:-1:0               % Easier to understand if we show in binary
                if (bitand(data(i), 2^bit) > 0)
                    fprintf('1');
                else
                    fprintf('0');
                end
            end
            fprintf('\n');
        end
        if (exist('OCTAVE_VERSION'))
            fflush(stdout);
        end
    end


end
