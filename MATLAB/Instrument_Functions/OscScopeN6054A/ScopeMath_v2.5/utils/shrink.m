function shrink(hContainer)

% SHRINK Shrink the dimensions of a panel or figure to tightly contain the
% components inside.  The space between the leftmost object and the edge is
% used for the border on the right and the space between the bottommost
% object and the edge is used for the space on the top.

%   Copyright 1996-2012 The MathWorks, Inc.

% try
    if (isfield(hContainer, 'getUIProperties'))
        hChildren = hContainer.getUIProperties('Children');
    else
        hChildren = get(hContainer, 'Children');
    end %if/else

    if (~isempty(hChildren))

        extents = [];
        for i=1:length(hChildren)
            unitsTemp = get(hChildren(i), 'Units');
            set(hChildren(i), 'Units', 'pixels');
            posTemp = get(hChildren(i), 'Position');
            upperleft = posTemp(1:2) + posTemp(3:4);
            border    = posTemp(1:2);
            extents   = vertcat(extents, [border, upperleft]);
            set(hChildren(i), 'Units', unitsTemp);
        end %for
        
        if (isfield(hContainer, 'getUIProperties'))
            unitsTemp = hContainer.getUIProperties('Units');
            hContainer.setUIProperties('Units', 'pixels');
            posTemp = hContainer.getUIProperties('Position');
        else
            unitsTemp = get(hContainer, 'Units');
            set(hContainer, 'Units', 'pixels');
            posTemp = get(hContainer, 'Position');
        end %if/else


        if (size(extents,1) > 1)
            border = min(extents(:, 1:2));
            upperleft = max(extents(:, 3:4));
        else
            border = extents(:, 1:2);;
            upperleft = extents(:, 3:4);
        end %if/else
        
        posTemp(3:4) = border + upperleft;
        
        if (isfield(hContainer, 'setUIProperties'))
            hContainer.setUIProperties('Position', posTemp);
            hContainer.setUIProperties('Units', unitsTemp);
        else
            set(hContainer, 'Position', posTemp);
            set(hContainer, 'Units', unitsTemp);
        end %if/else


    end %if