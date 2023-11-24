function setFreqSweepQuadDisplay(PNA_obj)

% window 1
% PNA_obj.CreateMeasurement(1, 'S11',1 , 1);
PNA_obj.ActiveMeasurement.Format = 1;     % 1 - LogMag

% window 2
PNA_obj.CreateMeasurement(1, 'S22',1 , 2);
PNA_obj.ActiveMeasurement.Format = 1;     % 1 - LogMag

% window 3
PNA_obj.CreateMeasurement(1, 'S21',1 , 3);
PNA_obj.ActiveMeasurement.Format = 1;     % 1 - LogMag

% window 4
PNA_obj.CreateMeasurement(1, 'S11',1 , 4);
PNA_obj.ActiveMeasurement.Format = 4;     % 4 - Smith
PNA_obj.CreateMeasurement(1, 'S22',1 , 4);
PNA_obj.ActiveMeasurement.Format = 4;     % 4 - Smith

end