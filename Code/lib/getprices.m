%This function is responsible for providing and sorting the needed bond
%prices for running the backtest on the TIPS Treasury bond arbitrage

function [tipsTimeseries,treasuryTimeseries,stripTimeseries,stripCUSIPs,...
    treasuryCouponNum,treasuryCoupon,TreasurySTRIPs,stripsCashdatesNum]=getprices(CUSIP,dataset)

%Loads the static bond overview tables
[trea_num,trea]   = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',2);
[tip_num,tip]     = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',1);
[strip_num,strip] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',3);

if dataset == "replicate" %REPLICATION PAIRS
    %Loads the static bond overview tables
    [trea_num,trea]   = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',2);
    [tip_num,tip]     = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',1);
    [strip_num,strip] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',3);
    
    %Loads the Treasury to STRIPS link table
    [~,TreasurySTRIPs] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',6);

    %Loads the coupon tables for all the Treasuries used
    [treasuryCouponNum,treasuryCoupon] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',5);

    %Loads the actual cashflow dates for the Synthetic portfolio
    [stripsCashdatesNum] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',7);
    
    %STRIPS Prices File
    [strip_price_num,strip_price] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BOND PRICES\STRIPS_PRICES_MERGED',1);

elseif dataset == "feb2021"
    %Loads the static bond overview tables
    [trea_num,trea]   = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BONDS\US_bonds_feb2021.xlsx',2);
    [tip_num,tip]     = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BONDS\US_bonds_feb2021.xlsx',1);
    [strip_num,strip] = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BONDS\US_bonds_feb2021.xlsx',3);
    
    %Loads the Treasury to STRIPS link table
    [~,TreasurySTRIPs] = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BONDS\US_bonds_feb2021.xlsx',6);

    %Loads the coupon tables for all the Treasuries used
    [treasuryCouponNum,treasuryCoupon] = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BONDS\US_bonds_feb2021.xlsx',5);

    %Loads the actual cashflow dates for the Synthetic portfolio
    [stripsCashdatesNum] = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BONDS\US_bonds_feb2021.xlsx',7);
    
    %STRIPS Prices File
    [strip_price_num,strip_price] = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BOND PRICES\STRIPS_PRICES_MERGED_clean.xlsx',1);
    
elseif dataset == "fleck_rep"
    %Loads the static bond overview tables
    [trea_num,trea]   = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',2);
    [tip_num,tip]     = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',1);
    [strip_num,strip] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',3);
    %Loads the Treasury to STRIPS link table 10 for ours, 12 for students
    [~,TreasurySTRIPs] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',12);
%     [~,TreasurySTRIPs] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion_TIPSsortedbymaturity',11);
    %Loads the coupon tables for all the Treasuries used (9 for ours, 14
    %for students)
    [treasuryCouponNum,treasuryCoupon] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',14);
%     [treasuryCouponNum,treasuryCoupon] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion_TIPSsortedbymaturity',8);
    %Loads the actual cashflow dates for the Synthetic portfolio
    [stripsCashdatesNum] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',13);
%     [stripsCashdatesNum] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion_TIPSsortedbymaturity',14);
    % STRIPS Prices file
    [strip_price_num,strip_price] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BOND PRICES\US STRIPS PRICES_numberversion',3); % old dataset for FL rep
    
elseif dataset == "student" %USING STUDENT'S PAIRS
    %Loads the static bond overview tables
    [trea_num,trea]   = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',2);
    [tip_num,tip]     = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',1);
    [strip_num,strip] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',3);
    [~,TreasurySTRIPs] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion',12);
    [treasuryCouponNum,treasuryCoupon] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion',9);
    [stripsCashdatesNum] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US',13);
    [strip_price_num,strip_price] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BOND PRICES\STRIPS_PRICES_MERGED',1);

end

if dataset == "replicate" %REPLICATION PAIRS
    %Loads all the TIPS prices
    [tip_prices_num,tip_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BOND PRICES\TIPS_PRICES_MERGED');
%     [tip_prices_num,tip_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BOND PRICES\TIPS PRICES_numberversion_uncorrupted',1); 
    %Loads all the Treasury prices
   [trea_prices_num,trea_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BOND PRICES\TREASURY_PRICES_MERGED_Long_NODUPES',1);
%    [trea_prices_num,trea_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BOND PRICES\TREASURY PRICES_numberversion',3);
elseif dataset == "feb2021" 
   [tip_prices_num,tip_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BOND PRICES\TIPS_PRICES_MERGED');
   [trea_prices_num,trea_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BOND PRICES\TREASURY_PRICES_MERGED.xlsx',1);
elseif dataset == "student" %USING STUDENT'S PAIRS
    % the original tips prices data file date strange dates. uncorrupted
    % version removes those dates. 
    [tip_prices_num,tip_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BOND PRICES\TIPS PRICES_numberversion_uncorrupted',1); 
    [trea_prices_num,trea_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BOND PRICES\TREASURY PRICES_numberversion',3);
    
elseif dataset == "fleck_rep"    
%     [tip_prices_num,tip_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BOND PRICES\TIPS_PRICES_MERGED');
    [tip_prices_num,tip_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BOND PRICES\TIPS PRICES_numberversion_uncorrupted_FL',1); 
%    [trea_prices_num,trea_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BOND PRICES\TREASURY_PRICES_MERGED_Long_NODUPES',1);
   [trea_prices_num,trea_prices] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BOND PRICES\TREASURY PRICES_numberversion',2);
end



l = 2; 
%creates placeholder for final dataset
treasuryTimeseries = zeros(length(trea_prices_num(5:end,1)),0); 
tipsTimeseries = zeros(length(tip_prices_num(:,1)),0);
stripCUSIPs = cell(0,0);
stripTimeseries = zeros(length(strip_price_num(:,1)),0);

while l <= length(CUSIP(:,1))
    IndexC = strfind(TreasurySTRIPs(1,:),CUSIP(l,2));
    Index = find(not(cellfun('isempty', IndexC)));
    currenttretostrip = TreasurySTRIPs(1:end,Index);

    IndexS = strfind(currenttretostrip(:,1),']');
    Indexs = find(not(cellfun('isempty', IndexS)));

    filledindexes = setdiff(1:length(currenttretostrip),Indexs); 
    currenttretostrip = currenttretostrip(filledindexes,1); %%%STRIPS ASSIGNED TO CURRENT TREASURY BOND, FIRST ENTRY IS THE T.B
   
    emptyCells = cellfun(@isempty,currenttretostrip);
    %# remove empty cells
    currenttretostrip(emptyCells) = []; 
 

    %gets timeseries for all STRIPS
    k = 1;
    i = 1;
    Stripindices = zeros(length(currenttretostrip(2:end,1)), 1);
    timeseries = zeros(length(strip_price_num),length(currenttretostrip(2:end,1))*2);
    stripcusip = currenttretostrip(2:end,1);
        while k <= length(currenttretostrip(2:end,1))
            %finds prices
            matchCus = strfind(strip_price(1,:),currenttretostrip(k+1,1));
            matchCu = find(not(cellfun('isempty', matchCus)));
            if isempty(matchCu) %if there is NO DATA in Treasury to STRIP we skip it
                timeseries(1:length(strip_price_num(:,1)),i) = zeros(length(strip_price_num(:,1)),1);
                timeseries(1:length(strip_price_num(:,1)),i+1) = zeros(length(strip_price_num(:,1)),1);
            else
                Stripindices(k,1) =  matchCu(length(matchCu));
            %we use the index with a larger column number; that is the one with
               %  updated prices
                currentprices = strip_price_num(1:end,matchCu(length(matchCu)):matchCu(length(matchCu))+1);
                currentprices(any(isnan(currentprices), 2), :) = [];
                
                timeseries(1:length(currentprices(:,1)),i) = currentprices(:,1);
                timeseries(1:length(currentprices(:,2)),i+1) = currentprices(:,2);
            end    
            
            k = k + 1;
            i = i + 2;
        end
        
    %stores the CUSIP for STRIPs in an array
    stripCUSIPs = [stripCUSIPs; stripcusip];
    %stores the timeseries of prices for strips
    stripTimeseries = [stripTimeseries,timeseries];

    %gets timeseries for Treasury
    IndexC = strfind(trea_prices(1,:),CUSIP(l,2));
    Index = find(not(cellfun('isempty', IndexC)));
    % we use the index with a larger column number; that is the one with
    %  updated prices
    currenttreaprice = trea_prices_num(5:end,Index(length(Index)):Index(length(Index))+1); 
    treasuryTimeseries = [treasuryTimeseries,currenttreaprice];
  
    %gets timeseries for TIPS
    IndexC = strfind(tip_prices(1,:),CUSIP(l,1));
    Index = find(not(cellfun('isempty', IndexC)));
    %we use the index with a larger column number; that is the one with
    %  updated prices
    currenttipprice = tip_prices_num(1:end,Index(length(Index)):Index(length(Index))+1);
    tipsTimeseries = [tipsTimeseries,currenttipprice];
    l = l + 1;
end

end




