% 
% Author, Rajesh Rao 
% 
% Performs a set intersection against multiple vectors
% 
% MINTERSECT repeatedly evaluates INTERSECT on successive pairs of sets, 
% which may not be very efficient.  For a large number of sets, this should
% probably be reimplemented using some kind of tree algorithm.
% 
% See also the Matlab INTERSECT function
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: varargin (type array) - N X 1 vector
%       Accepts a variable number of array arguments, each with N rows
%       e.g. mintersect(A,B,C,...) where A,B,C... are numeric vectors 
% 
% Output:
%   :param: intersections (type array) - M x 1 vector
%       Intersection amongst all provided arrays to the function 
% 


function intersections = mintersect(varargin)

    % error checking through assertions of input argument
    assert(~isempty(varargin), 'No inputs are specified');
    
    % initialize the first interesection set
    intersections = varargin{1};
    
    % iterate through each of the input array arguments
    for arg = 2:length(varargin)

        % compute the iterative intersection of each array argument
        % NOTE: If alternating argument types are provided that are not
        %       compatible with the parameters of the intersect function we
        %       raise an error, caught as an Error using intersect
        intersections = intersect(intersections, varargin{arg});
        
    end
    
end
