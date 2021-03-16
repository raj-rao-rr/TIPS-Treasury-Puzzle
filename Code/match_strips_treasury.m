%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code matches STRIPS to each cash-flow date for all the U.S. Treasury
% bonds that are to be replicated
%
% Last Edit: 2/26/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loads STRIP overview bond table
[strip_num,strip] = xlsread([data_dir bond_excel],3);

% Loads the overview table for the Treasury bonds
[staticTreaNum,staticTrea] = xlsread([data_dir bond_excel],2);

if strcmp(mode,'fleck_rep')
    % Loads the pairs table
    [~,CUSIP] = xlsread([data_dir bond_excel],8);
else
    % Loads the pairs table
    [~,CUSIP] = xlsread([data_dir bond_excel],4);
end

% Loads the Treasury coupon dates
[treasury_coup_num,treasury_coup] = xlsread([data_dir bond_excel],cf_sheet);

% Loads the prices of STRIPS
if strcmp(mode,'student_old')
    [strip_price_num,strip_price] = xlsread([data_dir 'BOND PRICES\US STRIPS PRICES'],3);
else
    [strip_price_num,strip_price] = xlsread([data_dir 'BOND PRICES\STRIPS_PRICES_MERGED'],1);
end

j = 1;
k = 1;

while j <= length(CUSIP(2:end,2))
    
    %find index of current treasury bond in coupon list
    current_CUSIP = CUSIP(j+1,2);
    IndexC = strfind(treasury_coup(1,:),current_CUSIP); 
    Index = find(not(cellfun('isempty', IndexC)));
        
    %Finds static bond data for current bond
    IndexB = strfind(staticTrea(:,18),current_CUSIP); 
    Indexb = find(not(cellfun('isempty', IndexB)));
    currentBond = staticTreaNum(Indexb-1,:);
    
    %Finds the coupon dates for the current bond
    current_selection = treasury_coup_num(:,Index(1,k));
    current_selection(current_selection==0)=[]; 
    results(1,j) = strcat('''',CUSIP(j+1,2));
        i = 1;
        while i <= length(current_selection) % loops through each coupon to find a STRIP
            %finds maturity matched strips (less than or equal 31 days for coupon date)
            %strip_num(:,2)- MATURITY, strip(:,9)- CUSIP
            range=find(abs(current_selection(i,1)-strip_num(:,2))<=31 & abs(strip_num(:,2)-current_selection(i,1))<=31);
            cusipSTRIPs = strip(range+1,9);
            
            %see if there is data for possible STRIPs on that coupon
            l = 1;
            isTherePrice = zeros(0,0);
            allPrices = zeros(length(strip_price_num(:,1)),length(current_selection)*2);
            allIndices = zeros(0,0);
            while l <= length(cusipSTRIPs)
                IndexL = strfind(strip_price(1,:),cusipSTRIPs(l));
                Indexl = find(not(cellfun('isempty', IndexL)));
                allIndices(l,1) = Indexl(1);
                %start from row 2 b/c first row is weird and affects price(1,1) == 0 
                price = strip_price_num(2:end,Indexl(1):Indexl(1)+1); 
                %Remove zeros
                price(find(price(:,2)==0),:) = [];
                %Remove NaNs
                price(any(isnan(price), 2), :) = [];
                
                if isempty(price)
                    price = [0,0];
                end    
                    
                allPrices(1:length(price(:,1)),((l*2)-1):l*2) = price;

                if price(1,1) == 0
                    isTherePrice(l,1) = 0;
                %see if the strip has prices before or at (five days after) 
                % the issue date of the treasury (currentBond(:,12))  
                elseif sum(price(:,1)<=currentBond(1,12)+5) > 0 
                    isTherePrice(l,1) = 1;
                else
                    isTherePrice(l,1) = 0;
                end
                l = l + 1
            end
           
            %If there is more with prices we test on first available price
            if sum(isTherePrice) > 1
                n = 1;
                allIndices = allIndices(find(isTherePrice));
                numberOfPoints = zeros(0,0);
                while n <= length(find(isTherePrice))
                    %see which strip has the longest timeseries
                    numberOfPoints(n,1) = sum(strip_price_num(:,allIndices(n))>=currentBond(1,12)); 
                    n = n + 1;
                end
                %takes the one with most price points
               [~,I] = max(numberOfPoints); 
               allIndices = allIndices(I);

            elseif sum(isTherePrice) == 1 
                allIndices = allIndices(find(isTherePrice));
            %if there is no STRIPs with data at or before issue then we take the STRIP with most price points     
            else 
                m = 1;
                anyPrice = zeros(0,0);
                while m <= length(allIndices)
                    %finds the one with the longest timeseries
                    lastPrice = allPrices(:,((m*2)-1):m*2);
                    lastPrice(any(isnan(lastPrice), 2), :) = [];
                    lastPrice(find(lastPrice(:,2)==0),:) = [];
                    anyPrice(m,1) = length(lastPrice(:,1));
                    m = m + 1;
                end
                
                if  sum(anyPrice)~=0
                    [~,I] = max(anyPrice);
                    allIndices = allIndices(I,1);
                else
                %if there is no prices at all we mark it with 99999 and
                %flag it as no data later
                allIndices = 99999;
                end    

            end
        
            if allIndices ~= 99999    
                results(i+1,j) = strcat('''',strip_price(1,allIndices)); 
            else
                results{i+1,j} = '''NO DATA' ;
            end    
        i = i + 1
        end
j = j + 1       
end



