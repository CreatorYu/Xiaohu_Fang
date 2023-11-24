function MemMatrix = ProcessBasis(input, Basis, MaxMemDepth)

Mem = zeros(length(input)-MaxMemDepth+1, MaxMemDepth);
for t=1:MaxMemDepth
	Mem(:,t) = input((MaxMemDepth-t+1):(end-t+1));
end

for i=1:length(Basis)
	Basis(i).output = Basis(i).func(Mem);
end

MemMatrix = [Basis.output];

end
