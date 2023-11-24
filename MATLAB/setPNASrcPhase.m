function setPNASrcPhase(PNA_obj, portNum, phaseVal)

PNA_obj.Channels.Item(1).PhaseControl.set('FixedPhase', portNum, phaseVal); 

end