function write_to_file(I, Q, I_path, Q_path)

fid = fopen(I_path,'wt'); % create a blank text file
for ind = 1:length(I)
fprintf(fid, '%f\n', I(ind));
end
fclose(fid);

fid = fopen(Q_path,'wt'); % create a blank text file
for ind = 1:length(Q)
fprintf(fid, '%f\n', Q(ind));
end
fclose(fid);

end