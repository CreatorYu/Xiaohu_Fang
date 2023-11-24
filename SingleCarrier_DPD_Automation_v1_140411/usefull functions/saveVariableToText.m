%% This function is used to save a variable to a text file
function saveVariableToText( x , path )
	% Open a text file 
        fid = fopen( path, 'wt' ) ;
    % write the variable on the text
        fprintf( fid , '%12.20f\n' , x ) ;
    % close the text file
        fclose( fid ) ;