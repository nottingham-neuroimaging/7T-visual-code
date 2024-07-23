function out = getDigIOSPMIC(stimulusOnsetTime, debugMode)
% getDigIOSPMIC - read out ResponsePixx DIO presses
%
% just gets an instantaneous readout of dig PORTs 
%
%    in: [stimulusOnsetTime] (optional) - a t0 for timestamps 
%                          [default: at start of this function call]
%        [debugMode] - show additional debug info 
%
%    out: a struct with fields
%         .bits
%         .keyColour
%         .keyPosition
%         .timeStamp
%
% 2024-07-08, denis schluppeck

if nargin < 1 || isempty(stimulusOnsetTime)
    stimulusOnsetTime = Datapixx('GetMarker');
end


% dereferencing from struct causes errors w/ intersect, union / WTF?
% so unpack here...
validBits = 1:11; 
triggerBit = 11; % new pin for TTL pulse w/ 10 button ResponsePIXX
% keyPosition = {'right', 'top', 'left', 'bottom', 't'};
keyPosition = {'little', 'ring', 'middle', 'index','thumb', ...
                'thumb', 'index', 'middle', 'ring', 'little', ...
                't'};
keyColour = {'blue', 'green', 'yellow', 'red','white', ...
             'white', 'red', 'yellow', 'green', 'blue', ...
                't'};

if nargin < 2 || isempty(debugMode)
    debugMode = false;
end
% init return argument
out = []; % default, nothing!

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
            out(i).timeStamp = tt - stimulusOnsetTime;
            if length(c) == 1
                fprintf('(getDigIOSPMIC) %s, %s at %.2f **\n',out(i).keyColour, out(i).keyPosition, out(i).timeStamp);
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
                fprintf('***** received something *****\n');
            end
        end % debugMode   
    
    
    end
    if (exist('OCTAVE_VERSION'))
        fflush(stdout);
    end
end


end
