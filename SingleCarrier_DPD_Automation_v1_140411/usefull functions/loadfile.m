%% This function is used to load a text file
function x = loadfile( path , Length )
    x = load( path ) ;
    switch nargin
        case 2    
            Length = min(Length,length(x));
            if Length
                x = x( 1:Length ) ;
            end
    end
    %% Make the variable a tall vector/matrix
    [ L , C ] = size( x ) ;
    if L < C
        x = transpose( x ) ;
    end