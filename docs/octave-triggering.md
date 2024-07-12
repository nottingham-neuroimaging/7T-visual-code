# Triggering your experiment

If you are using `octave` and `Psychtoolbox` to run your experiment, you can make use of the following functions to a) set up the digital IO interface, b) get the current state (response), and c) to take down/clean up at the end of an experiment:

a. `setupKeysSPMIC()`

b. `getDigIOSPMIC()`

c. `cleanupKeysSPMIC()`


## Pseudo-code

An experiment might be structured as follows. You have to be a bit careful about timing, requesting the state of bits, etc. with ``DataPixx('ReadDinLog');`` There are / will be some code to check timing accuracy.

```matlab
% set up code
% - precompute stimuli
% - load images, etc
% - ...

% wait for scanner to send trigger
while true
    output = getDigIOSPMIC();
    if ~isempty(output) && strcmp(output.key, 't')
        break
    end
end

% display loop / draw + flip
while experimentRunning

    % clear screen, draw, flip
    % Screen('DrawRect', [0, 0, 0]); % not even needed, Screen('Flip') does this by default
    drawStimuliToBuffer();
    Screen('Flip');

    % get user response
    response = getDigIOSPMIC();

    % do something with that response0
end

% take-down code
```
