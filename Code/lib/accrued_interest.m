%
% Author, Rajesh Rao 
% 
% Accrued interest of security with periodic interest payments 
% ------------------------------------------------------------------------
% 
% Inputs:
%   :param: IssueDate (type datetime)
%       Issue date of the security being observed
%   :param: Settlement (type datetime)
%       Settlement date of the security being observed, take this to be
%       the current date in the timeseries
%   :param: FirstCouponDate (type datetime)
%       First cupon data of the security being observed
%   :param: Coupon (type float)
%       Coupon rate of the security being observed
%   :param: Maturity (type datetime)
%       Maturity date for the underlying bond
% 
% Output:
%   :param: acrI (type float) - 1x1
%       The accrued interest of the calculated security 
% 

function [acrI] = accrued_interest(IssueDate, Settlement, ...
    FirstCouponDate, Coupon, Maturity)
    
    % check to see Issue date before first coupon and settlement
    if (IssueDate <= Settlement) && (IssueDate <= FirstCouponDate) && ...
            (Settlement <= Maturity)

        % compute accrued interest and map to correct index
        % 2 = semi-annual coupon, 0 = ACT/ACT day count basis, 0 = EndMonthRule
        NextCouponDate = cpndaten(Settlement, Maturity, 2, 0, 0, ...
            IssueDate, FirstCouponDate);
        PreviousCouponDate = cpndatep(Settlement, Maturity, 2, 0, 0, ...
            IssueDate, FirstCouponDate);

        daysInCouponPeriod = daysact(PreviousCouponDate, NextCouponDate);
        accruedDays = daysact(PreviousCouponDate, Settlement);
        accrualFactor = accruedDays / daysInCouponPeriod;
        acrI = (Coupon / 2) * accrualFactor;
        
    else
        acrI = 0;   % default to Zero accrued interest
    end
                
end
