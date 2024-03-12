function [ok] = initPIXX()
% initPIXX()
%
% ds 2024-03-12 wrote it

try
    % Check connection and open Datapixx if it's not open yet
    isConnected = Datapixx('isReady');
    if ~isConnected
        Datapixx('Open'); %Push command to device register
    end
        
    Datapixx('SetPropixxDlpSequenceProgram', 0);        %Set Propixx to 120Hz refresh (also known as Quad4x)
    Datapixx('RegWrRd'); 
    ok = true;  
catch ME

    disp('uhoh!')
    %  rethrow(ME)
    ok = false;
end

end