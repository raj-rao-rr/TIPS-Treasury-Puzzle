% This code defines the actual cash-flow dates of the synthetic Treasurys 

clearvars -except root_dir inflation_adj_flag winsor_flag;

% Import the STRIPS Data Tables
load DATA STRIPS 

% Import the STRIPS and Treasury pairs as well as cash flow dates
load MATCH strips_treasury_match 


%% loop through bonds to store coupon payment dates

fprintf('\n5) Creating actual cash flow dates\n'); 

% treasury cusips corresponding to columns in .mat
cusips = strips_treasury_match.Properties.VariableNames;
[~, T1] = size(cusips);

% initialize memory for storing actual cash flow dates
database = cell(1,T1);

% iterate through the Treasury CUSIPS
for i = 1:T1
    current_cusip = cusips(i);      % current Treasury CUSIPS 
    
    % select all strips that corresponds to the Treasury CUSIPS
    current_strip = strips_treasury_match{:, current_cusip}; 
    active_strips = current_strip(~cellfun('isempty', current_strip));                % remove all empty rows  
    
    % iterate through each active STRIP match to Treasury
    for j = 1:length(active_strips')
        strip = active_strips(j);               % CUSIP corresponding to STRIP
        
        % check whether strip is present in CUSIP vector
        if ismember(strip{:}, STRIPS{:, 'CUSIP'})
            % find maturity date for STRIP that correspond to CUSIP
            database(j, i) = cellstr(STRIPS{ismember(STRIPS{:, 'CUSIP'}, strip{:}), ...
                'Maturity'});
        else
            database(j, i) = 0;      % if CUSIP not present we skip
        end
        
    end
    
    % NOTE: For each Treasury Bond, actual cash fow dates lists the maturity 
    %       dates of all STRIPS matched to the coupon dates of a given Treasury.
    
end

%% Reporting relevant database for matches

% convert cell matrix to table and recast the table rows
actual_cashflow_dates = cell2table(database);

% convert the table column names to match the CUSIPS (in order of iteration) 
% all column names correspond to unique Treasury CUSIPS that we search for
actual_cashflow_dates.Properties.VariableNames = cusips; 

% save contents of table to temporary file
save('Temp/MATCH', 'actual_cashflow_dates', '-append')
