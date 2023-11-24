function PNA_data = PNA_read_trace(traceID,  PNA_obj, data_type);

if nargin == 2
    data_type = 'others';
end

switch data_type
    case {'dBm' 'dB'}
      tmpData = PNA_obj.Measurements.Item(traceID).Trace.Measurement.getData(2,0);
      tmpData = cell2mat(tmpData);
      PNA_data= 20 * log10(tmpData);
    case ('others')
      tmpData = PNA_obj.Measurements.Item(traceID).Trace.Measurement.getData(2,0);
      PNA_data = cell2mat(tmpData);
end
        
      
end