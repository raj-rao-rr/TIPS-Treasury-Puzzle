%
% Author, Rajesh Rao 
% 
% This function is responsible for calculating the reference base CPI for
% the ZCIS contracts. This value is used to determine the base inflation adj. 
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: cpival (type float)
%       Consumer Price Index for All Urban Consumers take from Fred
%   :param: settleDate (type datetime)
%       Settlement date of the security being observed, take this to be
%       the current date in the timeseries
% 
% Output:
%   :param: ZCISReferenceIndex (type float) - 1x1
%       The base inflation adjustment as computed from 
% 

function [cpi_adj_reference] = cpireferenceindex(cpival, start_date)

    days_in_payment_month = eomday(year(start_date),month(start_date));
    
    % if year turns month number be negative
    if month(start_date)-3 <= 0
        start_month = month(start_date)-3+12;
        start_year = year(start_date)-1;
    else
        start_month = month(start_date)-3;
        start_year = year(start_date);
    end
    
    % determine the range for which we extract the CPI measure
    ref_idx = cpival((cpival.YEAR == start_year) & (cpival.MONTH == start_month), :);
    startCPI = ref_idx.DATE;
    endCPI = datemnth(startCPI, 1);
    
    % gets relevant CPI values for the series
    startCPIIndexVal = cpival{ismember(cpival.DATE, startCPI), 'CPIAUCNS'};
    endCPIIndexVal = cpival{ismember(cpival.DATE, endCPI), 'CPIAUCNS'};
    
    % Uses linear interpolation 
    % https://developers.opengamma.com/quantitative-research/Inflation-Instruments-OpenGamma.pdf
    alphaV = (day(start_date)-1) / days_in_payment_month;
    cpi_adj_reference = alphaV*endCPIIndexVal+(1-alphaV)*startCPIIndexVal; 

end
