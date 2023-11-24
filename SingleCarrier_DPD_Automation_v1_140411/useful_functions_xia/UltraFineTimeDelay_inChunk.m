function [In_I_delayed, In_Q_delayed] = UltraFineTimeDelay_inChunk(In_I, In_Q, FsampleTx, ResampleRate, ResampleOrder, FineTimedelay)

%% Time delay resolution is 0.1 ns
ChunkSize   = 10000;
TotalPoints = length(In_I);
ChunkNumber = floor(TotalPoints/ChunkSize);
Remainder   = TotalPoints - ChunkSize * ChunkNumber;
DummyPoints  = 2 * ResampleOrder;

if Remainder <1000  % if the remaining points is less than 1000, combine with the last chunk
NumOfIter   = ChunkNumber;
else
NumOfIter   = ChunkNumber + 1;
end

In_I_delayed = [];
In_Q_delayed = [];

% Break the large data into chunks for memory efficient processing
% Each chunk is padded with redundant data of 2*ResampleOrder points
% The redundant points must be removed after each delay adjustment
for ind = 1 : NumOfIter   
    progressbar(ind/NumOfIter, 0, 0)
	if ind == 1
		ChunckEndIndex   = ChunkSize * (ind - 0) + DummyPoints;        
		[I_section, Q_section] ...
				= UltraFineTimeDelay_Adjust(In_I(1:ChunckEndIndex), In_Q(1:ChunckEndIndex), FsampleTx, ResampleRate, ResampleOrder, FineTimedelay);
		I_section = I_section(1:(ChunckEndIndex-DummyPoints));
		Q_section = Q_section(1:(ChunckEndIndex-DummyPoints));
	elseif ind == NumOfIter
		ChunckStartIndex = ChunkSize * (ind - 1) - DummyPoints + 1;
		[I_section, Q_section] ...
				= UltraFineTimeDelay_Adjust(In_I(ChunckStartIndex:end), In_Q(ChunckStartIndex:end), FsampleTx, ResampleRate, ResampleOrder, FineTimedelay);
		I_section = I_section((DummyPoints + 1):end);
		Q_section = Q_section((DummyPoints + 1):end);
	else
		ChunckStartIndex = ChunkSize * (ind - 1) - DummyPoints + 1;
		ChunckEndIndex   = ChunkSize * (ind - 0) + DummyPoints;                 
		[I_section, Q_section] ...
				= UltraFineTimeDelay_Adjust(In_I(ChunckStartIndex:ChunckEndIndex), In_Q(ChunckStartIndex:ChunckEndIndex), FsampleTx, ResampleRate, ResampleOrder, FineTimedelay);
		I_section = I_section((DummyPoints + 1):(end - DummyPoints));
		Q_section = Q_section((DummyPoints + 1):(end - DummyPoints));		
	end
	In_I_delayed = [In_I_delayed;I_section];
	In_Q_delayed = [In_Q_delayed;Q_section];
end

end    