function out = getDigIOSPMIC(stimulusOnsetTime, params, debugMode)
% getDigIOSPMIC - read out ResponsePixx DIO presses
%
% just gets an instantaneous readout of dig PORTs 
%
% can take a params struct as 2nd input
%    params.validBits
%    params.tiggerBit
%    params.keyColour
%    params.keyPosition
%
% 2024-07-08, denis schluppeck

if nargin < 1 || isempty(stimulusOnsetTime)
    stimulusOnsetTime = Datapixx('GetMarker');
end

if nargin < 2 || isempty(params)
    params = struct('validBits', [1; 2; 3; 4; 6], 'triggerBit', 6, ...
                    'keyColour', {'red', 'yellow', 'green', 'blue', 't'}, ...
                    'keyPosition', {'right', 'top', 'left', 'bottom', 't'});
end

% dereferencing from struct causes errors w/ intersect, union / WTF?
% so unpack here...
validBits = params.validBits;
triggerBit = params.triggerBit;
keyPosition = {'right', 'top', 'left', 'bottom', 't'};
keyColour = {'red', 'yellow', 'green', 'blue', 't'};

if nargin < 3 || isempty(debugMode)
    debugMode = false;
end
% init return argument
out = struct();

Datapixx('RegWrRd');
status = Datapixx('GetDinStatus');
if (status.newLogFrames > 0)
    % get data for N newLogFrames
    [data tt] = Datapixx('ReadDinLog');

    % then loop over the frames, data(i) stores that number
    for i = 1:status.newLogFrames

        % one approach is to convert dec2bin and look at where the 1's are
        % are . FLIPLR as we want to start with least sig bits (so read off from RIGHT to left, really!)
        dataString = fliplr( dec2bin(data(i)) );
        pinsHigh = strfind(dataString,'1');
        [c, ia] = intersect(validBits, pinsHigh);
        if any(c)
            out(i).bits = c;
            out(i).keyColour = keyColour{ia};
            out(i).keyPosition = keyPosition{ia};
            out(i).timeStamp = tt;
            if length(c) == 1
                fprintf('** %s, %s at %.2f **\n',out(i).keyColour, out(i).keyPosition, out(i).timeStamp);
            end

        end
        
        if debugMode
            fprintf('frame: %00d | rtime = %f', i, tt(i)-stimulusOnsetTime);
            fprintf(', button states = ');
            
            % go from high bit to low bit... 16 bits in total
            % print from left to right:
            for bit = 15:-1:0 % only do 6 low bits not 16??              
                if (bitand(data(i), 2^bit) > 0)
                    fprintf('1');
                else
                    fprintf('0');
                end
                % every 4 insert _
                if rem(bit,4) == 0 && bit > 0
                    fprintf('_');
                end
            end
            fprintf('\n');
        
            % print out str converted / bits...

            fprintf('%s\n',dataString)
            fprintf('buttons pressed / pins ON: [');
            fprintf('%d ', pinsHigh);
            fprintf(' | \n');

            if any(intersect(validBits, pinsHigh) )
                fprintf('***** received something\n');
            end
        end % debugMode   
    
    
    end
    if (exist('OCTAVE_VERSION'))
        fflush(stdout);
    end
end


end
