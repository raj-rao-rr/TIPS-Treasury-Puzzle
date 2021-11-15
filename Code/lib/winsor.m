%
% Author, Dimitri Shvorob, dimitri.shvorob@vanderbilt.edu, 4/15/07
% Updated by Rajesh Rao
% 
% Performs WINSOR algorithim to remove outlier(s) from data
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: x (type array) - N X 1 vector
%       Variable data vector looking to winsorize
%   :param: p (type array) - 2 X 1 vector 
%       Correspond to cut-off percentiles (left, right) 
%
% Output:
%   :param: y (type array) - N x 1 vector
%       Winsorized 'x' transformation 
%   :param: varargout (type array) - N x 1 vector 
%       Value-replaced-indicator vector (optional)
% 
% NOTE: Let p1 = prctile(x,p(1)), p2 = prctile(x,p(2)). (Note that PRCTILE 
%       ignores NaN values). Then if x(i) < p1, y(i) = min(x(j) | x(j) >= p1)
%       if x(i) > p2, y(i) = max(x(j) | x(j) <= p2)
% 


function [y, varargout] = winsor(x, p)

    % error checking through assertions of input argument
    assert(isvector(x), 'Input argument "x" must be a vector');
    assert(isvector(p), 'Input argument "p" must be a vector');
    assert(length(p) == 2, 'Input argument "p" must be 2x1 vector');
    
    assert(p(1) > 0 || p(1) < 100, 'Left percentile is out of [0,100] range');
    assert(p(2) > 0 || p(2) < 100, 'Right percentile is out of [0,100] range');
    assert(p(1) < p(2), 'Left percentile exceeds right percentile');
    
    % check to see if too few arguments are passed
    if nargin < 2
       error('Too few arguments were provided as input')
    end 
    
    % percentile break down of percentile range
    pct = prctile(x, p);
    
    idx1 = x < pct(1); v1 = min(x(~idx1));        % find the small extremes
    idx2 = x > pct(2); v2 = max(x(~idx2));        % find the large extremes    
    
    % return the reduced x vector stripping extrema
    y = x;  
    y(idx1) = v1;           % remapping low extrema to "normal-min"
    y(idx2) = v2;           % remapping high extrema to "normal-max"
    
    % conditional output contingent to number of output arguments
    if nargout > 1
       varargout(1) = {idx1 | idx2};
    end   
    
end    
    
    