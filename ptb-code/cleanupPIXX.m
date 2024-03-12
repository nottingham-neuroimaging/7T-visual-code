function [ok] = cleanupPIXX()
% cleanupPIXX()
%
% ds 2024-03-12 wrote it

try
    Datapixx('RegWrRd');
    Datapixx('Close');
    ok = true;  
catch ME

    disp('uhoh!')
    %  rethrow(ME)
    ok = false;
end

end