function centerbuttons(hButtonAlpha, hButtonBravo)
%%
% CENTERBUTTONS shift two buttons right or left so that they are
% centered in a dialog.

%   Copyright 1996-2012 The MathWorks, Inc.

positionAlpha = hButtonAlpha.getUIProperties('Position');
positionBravo = hButtonBravo.getUIProperties('Position');
positionParent = get(hButtonAlpha.getUIProperties('Parent'), 'Position');
borderwidth = positionAlpha(1) + ...
    (positionParent(3) - (positionBravo(1) + positionBravo(3)));
borderoffset = borderwidth/2;
positionAlpha(1) = borderoffset;
positionBravo(1) = positionParent(3) - (positionBravo(3) + borderoffset);
hButtonBravo.setUIProperties('Position', positionBravo);
hButtonAlpha.setUIProperties('Position', positionAlpha);
end
