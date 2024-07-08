function pinsHigh = getDigIOSPMIC(stimulusOnsetTime)
% getDigIOSPMIC - read out ResponsePixx DIO presses
%
% just gets an instantaneous readout of dig PORTs 
%
% 2024-07-08, denis schluppeck

if nargin < 1 || isempty(stimulusOnsetTime)
    stimulusOnsetTime = Datapixx('GetMarker');
end

% init return argument
pinsHigh = [];

Datapixx('RegWrRd');
status = Datapixx('GetDinStatus');
if (status.newLogFrames > 0)
    % get data for N newLogFrames
    [data tt] = Datapixx('ReadDinLog');

    % then loop over the frames, data(i) stores that number
    for i = 1:status.newLogFrames
        fprintf('frame: %00d | bits: %s | responseTime = %f', i, class(data), tt(i)-stimulusOnsetTime);
        fprintf(', button states = ');
        % go from high bit to low bit... 16 bits in total
        % print from left to right:
        for bit = 5:-1:0 % only do 6 low bits not 16??              
            if (bitand(data(i), 2^bit) > 0)
                fprintf('1');
            else
                fprintf('0');
            end
        end
        fprintf('\n');
    
        % other approach is to convert dec2bin and look at where the 1's are
        dataString = dec2bin(data(i));
        pinsHigh = strfind(dataString,'1');
        fprintf('buttons pressed / pins ON: [');
        fprintf('%d', pinsHigh);
        fprintf(' | \n');
        fprintf('%d', 16-pinsHigh);
        
    
    
    end
    if (exist('OCTAVE_VERSION'))
        fflush(stdout);
    end
end


end
