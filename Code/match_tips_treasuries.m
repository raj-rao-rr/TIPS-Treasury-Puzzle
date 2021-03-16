%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code creates the bond pairs, by matching U.S. TIPS and Treasuries 
% to each other
% 
% Last Edit: 2/26/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Import the TIPS and Treasury Data Tables

if mode == "student_updated" || mode == "fleck_rep"
    [num,str] = xlsread([data_dir, bond_excel],1);
    [num2,str2] = xlsread([data_dir, bond_excel],2);
    [num3,str3] = xlsread([data_dir, 'BOND PRICES\TREASURY PRICES_numberversion'],3);
elseif strcmp(mode,'student_old')
    [num,str] = xlsread(data_dir, bond_excel,1);
    [num2,str2] = xlsread(data_dir, bond_excel,2);
    [num3,str3] = xlsread([data_dir, 'BOND PRICES\TREASURY PRICES_numberversion'],3);
elseif strcmp(mode,'feb2021_update')
    [num,str] = xlsread([data_dir, bond_excel],1);
    [num2,str2] = xlsread([data_dir, bond_excel],2);
    [num3,str3] = xlsread([data_dir, 'BOND PRICES\TREASURY_PRICES_MERGED'],1);
end  

tips = str;
tips_num = num;
treasury = str2;
treasury_num = num2;
treasuryp = str3;
treasuryp_num = num3;

%% loop through TIPS issues

j = 1;
range1 = zeros(0,0);

isavailable = zeros(0,0);
ISIN_ISIN = zeros(0,0);

while j <= length(tips_num(:,1))
    if tips_num(j,2) < 37987.00 %if tips matures before 2004 skip it. 
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







