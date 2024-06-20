function cleanupKeysSPMIC()
% cleanupKeysSPMIC - tear down function that stops response pixx logging, etc
%
% 2024-06-20, in console room

% Show final status of digital input logger
fprintf('\nStatus information for digital input logger:\n');
disp(Datapixx('GetDinStatus'));

% Job done
Datapixx('StopDinLog');
Datapixx('RegWrRd');
Datapixx('Close');
fprintf('\nReponsePixx cleaned up\n\n');

end