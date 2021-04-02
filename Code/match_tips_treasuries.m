% This code creates the bond pairs, by matching U.S. TIPS and Treasuries

clearvars -except root_dir;

% Import the TIPS and Treasury Data Tables
load DATA TIPS TREASURYS


%% Matching TIPS issues with Treasury

[T1, ~] = size(TIPS);

% iterate through each tips issue
for row1 = 1:1
    
    % if tips matures before 2004 or if tips is when-issued, we skip 
    if (year(TIPS{row1,'Maturity'}) < 2004) || (TIPS{row1,'Ticker'}=="WITII")  
        j=j+1;
        continue 
    end 
    
    % get current TIPS ISIN number
    tips_isin = TIPS{row1, "ISIN"}; 
    
    % find maturity matched bonds (<= 31 days for maturity)
    maturity_match = find(abs(TIPS{row1,'Maturity'} - ...                    % difference is duration auto-map to days (24 hr)
        TREASURYS{:,'Maturity'}) <= 31);  
   
    % CUSIPs of all treasury fulfilling above criteria 
    cusip_matches = TREASURYS{maturity_match, 'CUSIP'};
    
    % filter the matching Treasury securities 
    matched_treasury = TREASURYS(maturity_match, :);
    check2004 = matched_treasury(matched_treasury.First_Coupon_Date ...     % check if issue is before 2004
        <= datetime(2004,1,1), :);
    
    % if no treasury is issued before 1/1/2004, find most-recent issue
    if isempty(check2004)
        newest_issue = max(matched_treasury{:, 'Issue_Date'});
        newest_match = matched_treasury(ismember(matched_treasury.Issue_Date, ...
            newest_issue),:);
        
    % otherwise find all bonds issued before 1/1/2004
    else
        newest_match = check2004;
    end

    % find the bond with issue date closest to that of the tips 
    differential = abs(TIPS{row1,'Issue_Date'} - ...
        newest_match{:,'Issue_Date'});
    
    % select the closest issue bond to match  
    bond_match = newest_match(differential == min(differential), :);
    
    % Retrieve Bond Prices
    % -----------------------------------------------------------
    issue_date = bond_match{:, 'Issue_Date'};
    
    
    while k <= length(treasury(range,18))
       issue_date = treasury_num(range(k), 12)
       IndexCU = strfind(treasuryp(1,:), treasury(range(k)+1, 18)); 
       IndexC = find(not(cellfun('isempty', IndexCU)));
       
       IndexID = find(treasuryp_num(:,IndexC) == issue_date)

       if isnan(treasuryp_num(IndexID+5,IndexC+1))
           isavailable(k) = 0;
       else
           isavailable(k) = 1;
       end    
       k = k + 1;
    end
    
    if ~(isempty(range))
        range = range(find(isavailable));
    end 
    
    %finds abs date difference in maturity on TIPS and Treasuries
    [val,index] = min(abs(tips_num(j,2)-treasury_num(range,2)));
    range = range(index);

    %issue date for Trea has to be smaller than
    %TIPS maturity date.
    range = range(find(treasury_num(range,12)<tips_num(j,2)));
    ISIN = treasury((range+1),18); %11 for ISIN

end

%%

j = 1;
range1 = zeros(0,0);

isavailable = zeros(0,0);
ISIN_ISIN = zeros(0,0);

while j <= length(tips_num(:,1))
    if tips_num(j,2) < 37987.00  % if tips matures before 2004 skip it. 
        j=j+1;
        continue 
    end 
    if tips(j+1,2) == "WITII" %if tips is when-issued, skip it. 
        j=j+1;
        continue 
    end 
       
    %get current tips_ISIN
    tips_ISIN = tips((j+1),18); %11 for ISIN
    
    %finds maturity matched bonds (less than or equal 31 days for maturity date)
    range=find(abs(tips_num(j,2)-treasury_num(:,2))<=31 & abs(treasury_num(:,2)-tips_num(j,2))<=31);
    range = unique(range);
    %CUSIPs of all treasury fulfilling above criteria 
    cusip = treasury(range+1,18);

    %if no treasury from above is issued before 01jan2004, find the
    %earliest issued bond
    if isempty(find((m2xdate(datenum('01-Jan-2004','dd-mmm-yyyy'),0)-treasury_num(range,12))>0))
        [~,index] = max(m2xdate(datenum('01-Jan-2004','dd-mmm-yyyy'),0)-treasury_num(range,12));
        range = range(index);
    %otherwise find all bonds issued before 01jan2004
    else
        range = range(find((m2xdate(datenum('01-Jan-2004','dd-mmm-yyyy'),0)-treasury_num(range,12))>0));
    end

    %find the bond with issue date closest to that of the tips
    [~,index] = min(abs(tips_num(j,12)-treasury_num(range,12)));
    range = range(index);

    k = 1;
    while k <= length(treasury(range,18))
       issue_date = treasury_num(range(k),12)
       IndexCU = strfind(treasuryp(1,:),treasury(range(k)+1,18)); 
       IndexC = find(not(cellfun('isempty', IndexCU)));
       
       IndexID = find(treasuryp_num(:,IndexC) == issue_date)

       if isnan(treasuryp_num(IndexID+5,IndexC+1))
           isavailable(k) = 0;
       else
           isavailable(k) = 1;
       end    
       k = k + 1;
    end
    
    if ~(isempty(range))
        range = range(find(isavailable));
    end 
    
    %finds abs date difference in maturity on TIPS and Treasuries
    [val,index] = min(abs(tips_num(j,2)-treasury_num(range,2)));
    range = range(index);

    %issue date for Trea has to be smaller than
    %TIPS maturity date.
    range = range(find(treasury_num(range,12)<tips_num(j,2)));
    ISIN = treasury((range+1),18); %11 for ISIN

    if isempty(ISIN)
   
    else
        ISIN_ISIN{j,5} = ISIN;
        ISIN_ISIN{j,6} = datestr(x2mdate(treasury_num(range,2),0));
        ISIN_ISIN{j,7} = datestr(x2mdate(treasury_num(range,12),0));
        ISIN_ISIN{j,8} = num2str(treasury_num(range,1));
    
        ISIN_ISIN{j,1} = tips_ISIN;
        ISIN_ISIN{j,2} = datestr(x2mdate(tips_num(j,2),0));
        ISIN_ISIN{j,3} = datestr(x2mdate(tips_num(j,12),0));
        ISIN_ISIN{j,4} = num2str(tips_num(j,1));
    end    
    
j = j + 1;
end

ISIN_ISIN_cusips = ISIN_ISIN(:,[1,5])
ISIN_ISIN_clean = zeros(0,0)
i = 1
j = 1
while i <= length(ISIN_ISIN_cusips)
    if ~isempty(string(ISIN_ISIN_cusips{i,1}))
        ISIN_ISIN_clean{j,1} = ISIN_ISIN_cusips{i,1}
        ISIN_ISIN_clean{j,2} = ISIN_ISIN_cusips{i,2}
        j=j+1
    end 
    i=i+1
end 

i=1
j=1
while i <= length(ISIN_ISIN_clean)
    j = 1
    while j <= 2
        matches(i,j) = ISIN_ISIN_clean{i,j}
        j = j + 1
    end
    i = i + 1
end







