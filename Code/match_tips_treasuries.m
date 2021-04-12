% This code creates the bond pairs, by matching U.S. TIPS and Treasuries

clearvars -except root_dir;

% Import the TIPS and Treasury Data Tables
load DATA TIPS TREASURYS PRICE_T


%% Matching TIPS issues with Treasury

[T1, ~] = size(TIPS);

% will be stored for database construction (unfiltered)
database = cell(T1, 2);

% iterate through each tips issue
for row = 1:T1
    
    % if tips matures before 2004 or if tips is when-issued, we skip
    if (year(TIPS{row, 'Maturity'}) < 2004) || (TIPS{row, 'Ticker'} == "WITII")  
        continue 
    end 
    
    % find maturity matched bonds (less than or equal to 31 days for maturity)
    maturity_match = find(abs(TIPS{row, 'Maturity'} - ...  
        TREASURYS{:, 'Maturity'}) <= 31);        % difference is duration (24 hr)  
    
    % if maturity matches does not match the hard cut off, we skip 
    if isempty(maturity_match)
       continue 
    end
    
    % filter the matching Treasury securities for maturity window
    matched_treasury = TREASURYS(maturity_match, :);
    check2004 = matched_treasury(matched_treasury{:, 'Issue_Date'} ...                % check if issue is before 2004
        < datetime(2004,1,1), :);
    
    % if no treasury is issued before 1/1/2004, find earliest issue to 2004
    if isempty(check2004)
        % NOTE: the closer the issuance is to 2004 the better
        [~, closest_2004_issue] = min(matched_treasury{:, 'Issue_Date'});
        newest_match = matched_treasury(closest_2004_issue,:);
        
    % otherwise find all bonds issued before 1/1/2004
    else
        newest_match = check2004;
    end
    
    % find the bond(s) with issue date closest to that of the tips 
    [~, closest_issue] = min(abs(TIPS{row, 'Issue_Date'} - ...
        newest_match{:, 'Issue_Date'}));
    
    % select the bond(s) with the closest issue date to that of the TIPS 
    bond_match = newest_match(closest_issue, :);
    
    % -----------------------------------------------------------
    % Check Against Bond Price Data
    % -----------------------------------------------------------
    
    % boolean array to check presence of Treasury price series
    isavailable = zeros(size(bond_match, 1), 1);

    % we may have more than one bond which match the minimum differential
    for i = size(bond_match, 1)
        
        bond_issue_date = bond_match{:, 'Issue_Date'};  % issue date for bonds

        % select the correct Treasury bond column by CUSIP
        col_select = bond_match{:, 'CUSIP'} + " Govt";  % the CUSIP price selection
        col_list = PRICE_T.Properties.VariableNames;    % all available CUSIP prices

        % error handling for CUSIP selection 
        if ismember(col_select, col_list)
            
            % we select the Treasury prices that correspond with our assign CUSIP 
            % smf the issue date of the matching TIPS
            treasury_prices = PRICE_T{PRICE_T.Var1 >= bond_issue_date, col_select};
            
            % check for the presence of NaN values in reduced series
            if ~isnan(treasury_prices)
                isavailable(i, 1) = 1;      % if no nan present we flag True boolean
            else
                isavailable(i, 1) = 0;      % if nan present we flag False boolean
            end

        else
            
            isavailable(i, 1) = 0;
            
        end
        
    end
    % -----------------------------------------------------------
    
    % select the new bond(s) with active price series 
    new_bond_match = bond_match(isavailable, :);
    
    % find the bond with the smallest difference in maturity versus TIPS 
    [~, smallest_diff] = min(abs(TIPS{row, 'Maturity'} - ...                          % compute maturity differential
        new_bond_match{:, 'Maturity'}));   
    treasury_bond_match = new_bond_match(smallest_diff, :);
    
    % issue date for Treasury must be smaller than the TIPS maturity date
    treasury_bond = treasury_bond_match(treasury_bond_match{:, 'Issue_Date'} ...
        < TIPS{row, 'Maturity'}, :); 
    
    % -----------------------------------------------------------
    %                Data Matching Construction 
    % *We make the assumption that me watch only 1 treasury bond*
    % -----------------------------------------------------------
    if ~isempty(treasury_bond)
        database{row,1} = TIPS{row, "CUSIP"};              % current TIPS CUSIP
        database{row,2} = treasury_bond{:, "CUSIP"};       % current Treasury CUSIP  
    end
    % -----------------------------------------------------------
    
end

%% Cleaning Relevant Database for omissions

% omit blank rows (empty rows) from our TIPS-Treasury Match
index = find(~cellfun(@isempty, database(:, 1)));
database_clean = database(index, :);

% convert cell matrix to table and recast the table rows
tips_treasury_match = cell2table(database_clean);

tips_treasury_match.Properties.VariableNames = {'TIPS_CUSIP', 'Treasury_CUSIP'}; 

% save contents of table to temporary file
save('Temp/MATCH', 'tips_treasury_match')

fprintf('Bond pairs have been created, for U.S. TIPS and Treasuries.\n'); 
