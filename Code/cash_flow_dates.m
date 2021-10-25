% This code generates all the cash-flow dates for all the Treasury bonds

clearvars -except root_dir inflation_adj_flag winsor_flag;

% Import the Treasury Data table
load DATA TREASURYS

% Import the TIPS=Treasury Match Pairs
load MATCH tips_treasury_match


%% loop through bonds to store coupon payment dates

% use unique CUSIP for Treasuries (avoid duplicates)
cusips = unique(tips_treasury_match{:, 'Treasury_CUSIP'});
[T, ~] = size(cusips);

cashflow_dates = cell(1, T);        % initialize memory for cash flow dates

% iterate through each CUSIP
for i = 1:T
    
    % filter the corresponding Treasury bond for each CUSIP selection
    filter_treasury = TREASURYS(ismember(TREASURYS.CUSIP, cusips(i)), :);
    
    % SYNTAX: Refer to Matlab Documentaion (Financial Toolbox)
    % https://www.mathworks.com/help/finance/cfdates.html
    %
    % CFlowDates = cfdates(Settle, Maturity, Period, Basis, EndMonthRule, ...
    %                      IssueDate, FirstCouponDate, LastCouponDate)
    
    % Compute cash flow dates for fixed-income security
    % period = 2 (semi-annual payments)
    % basis = 0 (actual/actual)
    % EndMonthRule = 1 (coupon payment last day of month)
    CFlowDates = cfdates(filter_treasury{:, 'Issue_Date'}, ...
        filter_treasury{:, 'Maturity'}, 2, 0, 1, ...
        filter_treasury{:, 'Issue_Date'}, ...
        filter_treasury{:, 'First_Coupon_Date'}); 
    
    % stores the cash flow dates for each corresponding CUSIP
    cashflow_dates(1:length(CFlowDates), i) = cellstr(CFlowDates');
    
end

%% Map Cashflow dates to table and rename variables 

% convert the cell matrix to a table
cashflow_dates = cell2table(cashflow_dates);

% assign the first row the corresponding CUSIPS for Treasuries
cashflow_dates.Properties.VariableNames = transpose(cusips);

% save contents of table to temporary file
save('Temp/MATCH', 'cashflow_dates', '-append')

fprintf('Cashflow dates have been determined for U.S. Treasuries.\n'); 
