function [hButtonAlpha, hButtonBravo] = genButtons(hParent, sAlpha, hFunAlpha, sBravo, hFunBravo, height)
% 
% GENBUTTONS Generate two MButtons in at the bottom of a figure or panel.  
%
%     [hButtonAlpha, hButtonBravo] = genButtons(hParent, sAlpha, hFunAlpha,
%     sBravo, hFunBravo)
%
%     hParent is the handle to a figure or panel.
%     sAlpha and SBravo are the strings for the button labels.
%     hFunAlpha and hFunBravo are function handles for the button
%      callbacks.
%
%     hButtonAlpha and hButtonBravo are handles to the generated MButtons.
%
% See also CENTERBUTTONS

%   Copyright 1996-2012 The MathWorks, Inc.

hButtonAlpha = MButton(hParent, 'Alpha', sAlpha);
stButtonOKOpts.Callback = hFunAlpha;
hButtonAlpha.setUIProperties(stButtonOKOpts);
position = hButtonAlpha.getUIProperties('Position');
position(1:2) = [4, height];
hButtonAlpha.setUIProperties('Position', position);

hButtonBravo = MButton(hParent, 'Bravo', sBravo);
stButtonBravoOpts.Callback = hFunBravo;
hButtonBravo.setUIProperties(stButtonBravoOpts);
position = hButtonBravo.getUIProperties('Position');
position(1:2) = [25, height];
hButtonBravo.setUIProperties('Position', position);

end %genButtons