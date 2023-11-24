function handle=MWaterfall(parent, iPlotData)
%UIWATERFALL creates a waterfall plot with memory
%
% Usage:
%       handle=uiWaterfall(fig,position)
%
%       fig is the parent figure you whish to put the Waterfall plot
%       position is the subplot position to put the axis.
%
%       h is a structure that's fields act like methods on an object.
%

%   Copyright 1996-2012 The MathWorks, Inc.

if ishandle(parent)
    parenthandle = parent;
else
    parenthandle = parent.handle;
end

% Define the interface to the waterfall plot
handle.update    = @update;
handle.visible   = @myvisible;
handle.clear     = @myclear;
handle.setxlabel = @mysetx;
handle.setylabel = @mysety;
handle.setzlabel = @mysetz;
handle.delete    = @mydelete;
handle.view      = @myview;

% Define the Axis for the plot (We could change this so that we don't use
% subplot if the subplot method of position does not work for us.  This was
% just a quick and dirty way to give some positions.
% hAxis = subplot(position(1),position(2),position(3),'parent',parent);

% Define variabls so they stays around. (Basically this is a way to have
% internal properties that the inner methods can access and will stay in
% memory.  (just like an objects private properties)
width = 10;
offset = 0;
data = [];
iterationNo = [];
time = [];

% The following is just a guess at what an interesting angle would be.
viewData = [60,70];
grid(parenthandle, 'on');

% Keep the handle to the plot so we can update the data in the background
hSurf = [];

%Keep handle to the X,Y so we don't need to create it each time.
X = [];
Y = [];
offsetVector = [];

hXLabel = get(parenthandle, 'XLabel');
hYLabel = get(parenthandle, 'YLabel');
hZLabel = get(parenthandle, 'ZLabel');

view(parenthandle, viewData);
update(iPlotData);

%% initialize GUI, handle incoming data is null.
%update plot
    function update(iPlotData)
        mysetx(iPlotData.XData.label);
        mysety(iPlotData.YData.label);
        mysetz(iPlotData.ZData.label);
        
        iterationNo = iPlotData.YData.data;
        time        = iPlotData.XData.data;
        newData     = iPlotData.ZData.data;
        width       = length(iterationNo);
        if (length(time) > 0)
            if isempty(hSurf)
                %delete(get(parenthandle, 'Children'));
                [X,Y] = meshgrid(time,iterationNo);
                data  = ones(size(X))*NaN;
                offsetVector = 1:width;
            end
       
            % Make offset point to the next position in the buffer.
            % offset = mod(offset-1, width)+1;
            offset = offsetVector(1);
        
            l1 = length(data(offset, :));
            l2 = length(newData);
            if (l1 ~= l2) %data size mismatch
                if (abs(l1 - l2) < .3*l1) %if it is a minor mismatch, pad
                    %fprintf('Minor mismatch %d vs\t %d\n', l1, l2);
                    if (size(data,2)>length(newData))
                        data(offset,:)=[newData(:);ones(size(data,2)-length(newData),1)*NaN]';
                    else
                        data(offset,:)=newData(1:size(data,2));
                    end
                else %it is a major mismatch and recalculate the new surface
                    %fprintf('MAJOR mismatch %d vs\t %d\n', l1, l2);
                    if (ishandle(hSurf))
                        delete(hSurf);
                    end
                    hSurf = [];
                    update(iPlotData);
                    return;
                end
            else
                data(offset,:)=newData;
            end
            
            if (isempty(hSurf))
                hSurf = surf(X,Y,data,'parent',parenthandle, 'FaceColor', 'interp', 'EdgeColor', 'none');
                view(parenthandle, viewData);
            else
                set(hSurf,'ZData',data(offsetVector,:));
            end
            offsetVector = circshift(offsetVector,[1, 1]);
        end
    end


    % set X axis label
    function mysetx(label)
        set(hXLabel, 'String', label);
    end

    % set Y axis label
    function mysety(label)
        set(hYLabel, 'String', label);
    end

    % set Z axis label
    function mysetz(label)
        set(hZLabel, 'String', label);
    end

    % set visible flag
    function myvisible(flag)
        if flag
            set(parenthandle,'Visible','on');
            set(hSurf,'Visible','on');
        else
            set(parenthandle,'Visible','off');
            set(hSurf,'Visible','off');
        end
    end

    % get my view points
    % TODO: since we don't have set view method, why we need this?
    function myview(newview)
        viewData = newview;
    end

% clear memory
    function myclear()
        iterationNo = [];
        time = [];
        X = [];
        Y = [];
        data = [];
        width=10;
        offset = width;
        delete(parenthandle);
    end

    % delete plot
    % TODO: do we need this?
    function mydelete()
        delete(hSurf);
        %delete(parenthandle);
    end
end
