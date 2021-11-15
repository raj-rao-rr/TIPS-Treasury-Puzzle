% This code matches STRIPS to each cash-flow date for the U.S. Treasury bonds 

clearvars -except root_dir inflation_adj_flag winsor_flag;

% Import the STRIPS and Treasury Data Tables, as well as STRIPS prices
load DATA STRIPS TREASURYS PRICE_S

% Import the TIPS and Treasury pairs as well as cash flow dates
load MATCH tips_treasury_match cashflow_dates


%% Matching STRIPS issues with Treasury

fprintf('\n4) Creating bond pairs for U.S. STRIPS and Treasuries.\n'); 

% filter only the unique CUSIPS from the Treasury match 
cusips = unique(tips_treasury_match{:, 'Treasury_CUSIP'});
[T1, ~] = size(cusips);

% will be stored for database construction
database = cell(1, T1);

% iterate through each CUSIP within TIPS-Treasury pairs
for j = 1:T1
   
    % select Treasury CUSIP name from pair matches
    treasury_cusip = cusips(j);
    
    % select the Treasury bond corresponding with CUSIP
    current_bond = TREASURYS(ismember(TREASURYS{:, 'CUSIP'}, treasury_cusip), :); 
    
    % select the coupon dates for the correspond CUSIP
    current_dates = cashflow_dates{:, treasury_cusip};                                % cash flow dates for Treasury coupon
    active_dates = current_dates(~cellfun('isempty', current_dates));                 % filter out empty cash flow dates   
    active_dates = datetime(active_dates);                                            % recast cell array to datetime array                        
    
    % iterate through each of the accompanying coupon dates to find STRIP
    for i = 1:size(active_dates, 1)
        
        % select the coupon date for all active cashflow dates
        coupon_date = active_dates(i);
        
        % select maturity matched STRIPS (less than or equal to 31 days for coupon)
        filtered_strips = STRIPS(abs(STRIPS{:, 'Maturity'} - coupon_date) <= 31, :);
        
        % -----------------------------------------------------------
        if isempty(filtered_strips)
            % if we find no maturities matching 31 day condition, skip
            continue    
        end
        % -----------------------------------------------------------

        % selecting CUSIPS for proper price series (refer to assumptions below) 
        isTherePrice = zeros(size(filtered_strips, 1), 1);
        allIndices = zeros(size(filtered_strips, 1), 1);
        
        % -----------------------------------------------------------
        % Check Against STRIPS Price Data
        % -----------------------------------------------------------
        
        col_list = PRICE_S.Properties.VariableNames;                                  % CUSIP columns for STRIP price
        
        % iterate through the filtered STRIPS to secure correct prices
        for idx = 1:size(filtered_strips{:, 'CUSIP'}, 1)
            strip_cusip = filtered_strips{idx, 'CUSIP'};    % CUSIP for STRIP
            col_name = strcat(strip_cusip, ' Govt');        % column name for price
            
            % error handling for CUSIP selection (make sure present)
            if ismember(col_name, col_list)
                
                % if cusip present in STRIP price we strip NaNs and zeros
                prices = PRICE_S(~isnan(PRICE_S{:, col_name}) & ...
                    (PRICE_S{:, col_name} ~= 0), col_name(:));                 
                
                % -----------------------------------------------------------
                % After filtering NaN and Zero (we assume the following)
                % -----------------------------------------------------------  
                if isempty(prices)
                   % if no price series is returned (empty) we skip CUSIP
                   isTherePrice(idx, 1) = 0; 
                elseif sum(prices.Dates <= current_bond.Issue_Date + 5) > 0
                   % check to see if the STRIP has prices before or at
                   % (five days after) the issue date of the most recent
                   % bond (we sum to check boolean presense of 1)
                   isTherePrice(idx, 1) = 1; 
                else
                   isTherePrice(idx, 1) = 0; 
                end
                
            end
            
        end
                
        % if there are more prices that meet condition we test on first available 
        if sum(isTherePrice) > 1
             filter = find(isTherePrice);                                             % select only STRIPS that match
             cond_strips = filtered_strips(filter, :);                    
             
             % count the number of NaN present for a given CUSIP 
             col_name = strcat(cond_strips.CUSIP, ' Govt');                           % column name for price
             nan_count = sum(isnan(PRICE_S{PRICE_S.Dates >= current_bond.Issue_Date, ...
                 col_name}));                            
             row_count = length(PRICE_S{:, 1});                                       % length of full price series list
             
             % determines CUSIP with most price points. NOTE, if more than
             % one STRIP is flagged, we default to choose the first
             [~, max_index] = max(row_count - nan_count);                             
             
             % the CUSIP selection for STRIP
             cusip_selection = cond_strips.CUSIP{max_index};
             
        % if there is only one price series that matches, map directly
        elseif sum(isTherePrice) == 1
            filter = find(isTherePrice);                                              % select only STRIPS that match
            cusip_selection = filtered_strips{filter, 'CUSIP'};
            
        % if there is no matching STRIPs, then we take the one with most points     
        else
            % count the number of NaN present for a given CUSIP
            col_name = strcat(filtered_strips.CUSIP, ' Govt');                        % column name for price
            nan_count = sum(isnan(PRICE_S{PRICE_S.Dates >= current_bond.Issue_Date, ...
                 col_name}));    
            row_count = length(PRICE_S{:, 1});                                        % length of full price series list
            [~, max_index] = max(row_count - nan_count);                              % determines CUSIP with most price points
             
            % the CUSIP selection for STRIP
            cusip_selection = filtered_strips.CUSIP{max_index};
            
        end
        
        % -----------------------------------------------------------
        % Database Construction for all corresponding CUSIP
        % -----------------------------------------------------------
        
        % match STRIP CUSIP for each of the Treasury bond coupon dates
        database(i, j) = {cusip_selection};     
        
    end
    
end

%% Reporting relevant database for matches

% convert cell matrix to table and recast the table rows
strips_treasury_match = cell2table(database);

% convert the table column names to match the CUSIPS (in order of iteration) 
% all column names correspond to unique Treasury CUSIPS 
strips_treasury_match.Properties.VariableNames = cusips; 

% save contents of table to temporary file
save('Temp/MATCH', 'strips_treasury_match', '-append')
