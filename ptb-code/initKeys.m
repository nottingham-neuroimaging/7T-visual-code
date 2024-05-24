function keys = initKeys()
% set up keycodes / return in struct
%

    KbName('UnifyKeyNames');
    
    keys.space = KbName('SPACE');
    keys.esc=KbName('ESCAPE');
    keys.right=KbName('RightArrow');
    keys.left=KbName('LeftArrow');
    keys.up=KbName('UpArrow');
    keys.down=KbName('DownArrow');
    keys.shift=KbName('RightShift');
    keys.colorPicker=KbName('c');
    keys.trigger=KbName('5'); % this is correct for SPMIC, fORP, 7T
    
end