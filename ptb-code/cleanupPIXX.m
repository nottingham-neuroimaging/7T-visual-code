function [ok] = cleanupPIXX()
% cleanupPIXX() - function for making sure DataPIXX is reset
%
% ds 2024-03-12 wrote it

% catch exceptions... if something goes wrong
try
    Datapixx('RegWrRd');
    Datapixx('Close');
    ok = true;  

catch ME
    disp('(cleanupPIXX) uhoh!')
    ok = false;
end

end