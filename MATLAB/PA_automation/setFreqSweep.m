function setFreqSweep(PNA_obj, startFreq, stopFreq, powerPort, numOfPoints, ifBandwidth)

PNA_obj.Channels.Item(1).SweepType        = 0;
PNA_obj.Channels.Item(1).StartFrequency   = startFreq;
PNA_obj.Channels.Item(1).StopFrequency    = stopFreq;
% PNA_obj.Channels.Item(1).set('TestPortPower', 1, powerPort); % see https://community.keysight.com/thread/3859
PNA_obj.Channels.Item(1).NumberOfPoints   = numOfPoints;
PNA_obj.Channels.Item(1).IFBandwidth      = ifBandwidth;

end