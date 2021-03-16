%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code generates all the cash-flow dates for all the Treasury bonds
% used in the arbitrage strategy
%
% Last Edit: 2/26/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import Data

%Gets the pairs table and the bond overview table for U.S. Treasury 
if mode == "fleck_rep"
    [~,str]     = xlsread([data_dir, bond_excel],8); 
    [num2,str2] = xlsread([data_dir, bond_excel],2);
else
    [~,str]     = xlsread([data_dir, bond_excel],4); 
    [num2,str2] = xlsread([data_dir, bond_excel],2);
end 


%% loop through bonds to store coupon payment dates
CUSIP = str;
 
bond_num = num2;
bond_str = str2;

i = 1;
while i <= length(CUSIP)-1
    IndexC = strfind(bond_str(:,18),CUSIP((i+1),2));
    Index = find(not(cellfun('isempty', IndexC)));
    
    %SYNTAX:
    %CFlowDates = cfdates(Settle, ...
    % Maturity,Period,Basis,EndMonthRule, ...
    % IssueDate,FirstCouponDate,LastCouponDate,StartDate)
    
    %12- ISSUE DATE. 2- MATURITY DATE. 6- FIRST COUPON DATE.
    CFlowDates = cfdates(x2mdate(bond_num((Index-1),12),0), ...
        x2mdate(bond_num((Index-1),2),0), 2, 0, 1, ...
        x2mdate(bond_num((Index-1),12),0),x2mdate(bond_num((Index-1),6),0)); 
    
    %stores the cash flow dates
    placeholder_real(2:(length(CFlowDates)+1),(i)) = transpose(m2xdate(CFlowDates,0));
    i = i + 1
end


tips_and_trea = transpose(CUSIP(2:end,:))
trea = tips_and_trea(2,:)












