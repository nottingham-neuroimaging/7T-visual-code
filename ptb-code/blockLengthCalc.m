function [BLC] = BlockLengthCalc(TargetBlockLength,TRin)
%
% Calculates the closest block length to a target block length that can .
%
% Input: Desired block length, TR.
%
% Output: Struc "BLC" with fields .BL (Block length) and .OnOff (Length of on and
% off periods, half of BL).
%
% Could add a check to ensure the BL > TR?

% Init
BL = TargetBlockLength;
TR = TRin;
i = 0;
CurrSq = 0;
PervSq = 1;

%% Calculations

% Iterates TR onto itself (i) until the closest time is found to target block length 
while CurrSq < PervSq
    i = i + TR;
    Cur = BL - i;
    Prev = Cur+ TR;
    CurrSq = Cur^2;
    PervSq = Prev^2;    
end

%% Assigning output

% To get previous BL which is the closest, unless it is a factor
if Prev ~= BL
    BLC.BL = i - TR;
else
    BLC.BL = i;
end

% Makes on/off times, assumes equal timings 
OnOffPre = BLC.BL / 2;
BLC.OnOff = round(OnOffPre, 3);

end