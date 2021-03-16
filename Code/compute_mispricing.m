%This code is responsible for performing the actual backtesting of the
%TIPS-Treasury mispricing. It draws on other programmes, but is the main
%motor for quantifying the level of the mispricing. 

% set options/mode of running
inflationAdjFlag = false; % toggle for base inflation adjustment
winsorFlag       = false; % toggle for winsorizing individual pair results  

if mode == "student_updated"
    %Loads the TIPS Treasury link table
    %sheet 4 for student's pairs, 8 for FL's
    [~,CUSIP] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',4);
    %Loads the prices of all the needed traded instruments
    [tipsTimeseries,treasuryTimeseries,stripTimeseries,stripCUSIPs,...
        treasuryCouponNum,treasuryCoupon,TreasurySTRIPs,...
        stripsCashdatesNum]=getprices(CUSIP,"replicate");
    %Loads the adjusted swap curves
    swapcurves = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\Export\AdjustedSwapcurve.csv',1);  
    %can't find this file but swapbaddates aren't used anyway
    %swapbaddates = importdata('/Users/Paul/Dropbox/Thesis/Code/matlab datafiles/swapbaddates.mat');    
    swapTenor = swapcurves(1,2:end);
    %Loads the monthly unadjusted CPI index values
    [cpival] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\CPI INDEX\CPIAUCNS.xls',1);
    %Gets the overview table for the Treasury and TIPS
    [staticTreaNum,staticTrea] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',2);
    [staticTIPSNum,staticTIPS] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',1);
    
elseif mode == "feb2021_update"
    %Loads the TIPS Treasury link table
    [~,CUSIP] = xlsread('S:\SHARE\cmf\Desi\Ken\project\jul2020update\BONDS\US_bonds_jul2020.xlsx',4);
    %Loads the prices of all the needed traded instruments
    [tipsTimeseries,treasuryTimeseries,stripTimeseries,stripCUSIPs,...
        treasuryCouponNum,treasuryCoupon,TreasurySTRIPs,...
        stripsCashdatesNum]=getprices(CUSIP,"feb2021");
    %Loads the adjusted swap curves
    %note: student may have deleted some "bad dates" evidenced in the folder;
    %   haven't taken that into account yet
    swapcurves = xlsread('S:\SHARE\cmf\Desi\Ken\project\jul2020update\Export\AdjustedSwapcurve.csv',1);   
    swapTenor = swapcurves(1,2:end);
    %Loads the monthly unadjusted CPI index values
    [cpival] = xlsread('S:\SHARE\cmf\Desi\Ken\project\jul2020update\CPI INDEX\CPIAUCNS.xls',1);
    %Gets the overview table for the Treasury and TIPS
    [staticTreaNum,staticTrea] = xlsread('S:\SHARE\cmf\Desi\Ken\project\jul2020update\BONDS\US_bonds_jul2020.xlsx',2);
    [staticTIPSNum,staticTIPS] = xlsread('S:\SHARE\cmf\Desi\Ken\project\jul2020update\BONDS\US_bonds_jul2020.xlsx',1);
    
elseif mode == "fleck_rep"
    %Loads the TIPS Treasury link table
    %sheet 4 for student's pairs, 8 for FL's
    [~,CUSIP] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',8);
    %Loads the prices of all the needed traded instruments
    [tipsTimeseries,treasuryTimeseries,stripTimeseries,stripCUSIPs,...
        treasuryCouponNum,treasuryCoupon,TreasurySTRIPs,...
        stripsCashdatesNum]=getprices(CUSIP,"fleck_rep");
    %Loads the adjusted swap curves
    %note: student may have deleted some "bad dates" evidenced in the folder;
    %   haven't taken that into account yet
    swapcurves = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\Export\AdjustedSwapcurve.csv',1);  
    %can't find this file but swapbaddates aren't used anyway
    %swapbaddates = importdata('/Users/Paul/Dropbox/Thesis/Code/matlab datafiles/swapbaddates.mat');    
    swapTenor = swapcurves(1,2:end);
    %Loads the monthly unadjusted CPI index values
    [cpival] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\CPI INDEX\CPIAUCNS.xls',1);
    %Gets the overview table for the Treasury and TIPS
    [staticTreaNum,staticTrea] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',2);
    [staticTIPSNum,staticTIPS] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',1);
    
elseif mode == "student_old"
    [~,CUSIP] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion',4); 
    %Loads the prices of all the needed traded instruments
    [tipsTimeseries,treasuryTimeseries,stripTimeseries,stripCUSIPs,...
        treasuryCouponNum,treasuryCoupon,TreasurySTRIPs,...
        stripsCashdatesNum]=getprices(CUSIP,"student");
    %Loads the adjusted swap curves
    %note: I reversed the order of rows of original data file
    %also: I got baited by the wrong adjusted swap curves file...for some
    %reason one had more data points than the other
    swapcurves = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\Export\AdjustedSwapcurve_ACTUAL_REVERSED.csv',1);  
    %can't find this file but swapbaddates aren't used anyway
    %swapbaddates = importdata('/Users/Paul/Dropbox/Thesis/Code/matlab datafiles/swapbaddates.mat');    
    swapTenor = swapcurves(1,2:end);
    %Loads the monthly unadjusted CPI index values
    [cpival] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\CPI INDEX\CPIAUCNS.xls',1);
    %Gets the overview table for the Treasury and TIPS
    [staticTreaNum,staticTrea] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion',2);
    [staticTIPSNum,staticTIPS] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion',1);
end 

countryFlag = 'US';   
   
i = 1;   
l = 1;   
while i <= length(CUSIP(2:end,:))
    %Clear variables
    tempTREA = zeros(0,0);
    tempTIPS = zeros(0,0);
    
    %Gets the price history of the TIPS and Treasury
    currentTIPS = tipsTimeseries(:,l:l+1);
    currentTREA = treasuryTimeseries(:,l:l+1);
    
    %%% new fix for excessive entries after maturity (,.new as of 1/23/20)
    TresMatDateIndex = find(contains(staticTrea(:,18), CUSIP{i+1,2} ))-1; 
    TIPSMatDateIndex = find(contains(staticTIPS(:,18), CUSIP{i+1,1} ))-1;
    
    TresMatDate = staticTreaNum(TresMatDateIndex, 2);
    TIPSMatDate = staticTIPSNum(TIPSMatDateIndex, 2);
    
    %Removes NaN from TIPS and Trea timeseries
    currentTIPS(any(isnan(currentTIPS), 2), :) = [];
    currentTREA(any(isnan(currentTREA), 2), :) = [];
    
    %Remove dates past maturity (also new as of 1/23/20)
    currentTIPS(any(currentTIPS(:,1) > TIPSMatDate), :) = [];
    currentTREA(any(currentTREA(:,1) > TresMatDate), :) = [];
    
    %Finds the intersection of dates 
    [dates,iTIPS,iTREA] = intersect(currentTIPS(:,1),currentTREA(:,1));
    
    %setdiff(currentTIPS(:,1),currentTREA(:,1))
    %setdiff(currentTREA(:,1),currentTIPS(:,1))
    %setdiff(tempTIPS(:,1),tempTREA(:,1))
    %setdiff(tempTREA(:,1),tempTIPS(:,1)) 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %THIS CODE BLOCK TRUNCATES/IMPUTES CURRENT TIPS AND TREASURY DATA SO THAT THEY HAVE SAME DATES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Check if datapoints on TIPS and Treasury matches 
    if ~isequal(currentTIPS(min(iTIPS):max(iTIPS),1),currentTREA(min(iTREA):max(iTREA),1))
        while ~isequal(currentTIPS(min(iTIPS):max(iTIPS),1),currentTREA(min(iTREA):max(iTREA),1))
            %Check which timeseries is missing data %%% BUT WHAT IF BOTH ARE MISSING DATA?
            tempTREA = currentTREA(min(iTREA):max(iTREA),1:2);
            tempTIPS = currentTIPS(min(iTIPS):max(iTIPS),1:2);
            [dates,iTIPS,iTREA] = intersect(tempTIPS(:,1),tempTREA(:,1));

            if length(tempTIPS) > length(tempTREA)
                    %if Treasury is shorter
                    %this line below finds indices of TIPS where 1) TREA and TIPS share
                    %a date and 2) the next shared date skips date(s) in TIPS
                    temp = (iTIPS(2:end)-iTIPS(1:end-1))-1;  
                    [row,~,v] = find(temp);
                    m = 1;
                    while m <= length(v)
                        %rows of tips and trea where date skipping occurs
                        row_tips= find(tempTIPS(:,1)==tempTIPS(iTIPS(row(m)))) 
                        row_trea= find(tempTREA(:,1)==tempTIPS(iTIPS(row(m))))

                        if v(m) <= 3 %maximum three days of copying ZCIS curves
                            tempTREA = [tempTREA(1:row(m),:);...
                                tempTIPS(row_tips+1:row_tips+v(m),1),...
                                repmat(tempTREA(row_trea,2),v(m),1);tempTREA(row_trea+1:end,:)];
                        else %we delete the price points in the bond timeseries if more than 3 points is missing   
                            tempTIPS(row_tips+1:row_tips+v(m),:) = [];
                        end
                        [dates,iTIPS,iTREA] = intersect(tempTIPS(:,1),tempTREA(:,1));
                        temp = (iTIPS(2:end)-iTIPS(1:end-1))-1;
                        [row,~,v] = find(temp);
                    end
             elseif    length(tempTIPS) < length(tempTREA)
                    %if TIPS is shorter
                    %this line below finds indices of TREA where 1) TREA and TIPS share
                    %a date and 2) the next shared date skips date(s) in TREA
                    temp = (iTREA(2:end)-iTREA(1:end-1))-1; 
                    [row,~,v] = find(temp);
                    m = 1;
                    while m <= length(v)
                        row_tips= find(tempTIPS(:,1)==tempTREA(iTREA(row(m))))
                        row_trea= find(tempTREA(:,1)==tempTREA(iTREA(row(m))))

                        if v(m) <= 3 %if skipped 3 or less days, just impute by copying price at the previous date
                            tempTIPS = [tempTIPS(1:row_tips,:);...
                                tempTREA(row_trea+1:row_trea+v(m),1), ...
                                repmat(tempTIPS(row_tips,2),v(m),1);tempTIPS(row_tips+1:end,:)];
                        else %we delete the ZCIS curve points if more than 3 points is missing   
                            tempTREA(row_trea+1:row_trea+v(m),:) = [];
                        end
                        [dates,iTIPS,iTREA] = intersect(tempTIPS(:,1),tempTREA(:,1));
                        temp = (iTREA(2:end)-iTREA(1:end-1))-1;
                        [row,~,v] = find(temp);
                    end
            end


            %Fills the current vectors with the correct output from above
            %Output should be to vectors with prices of same length and dates
            if isempty(tempTREA) || isempty(tempTIPS)
                %if temps placeholders are empty then we haven't corrected any datapoints
                currentTREA = currentTREA(iTREA,1:2);
                currentTIPS = currentTIPS(iTIPS,1:2);
            else
                %if temp aren't empty then we need to take the temps as they have
                %updated datapoints
                currentTREA = tempTREA;
                currentTIPS = tempTIPS;
            end

        end 
    elseif isequal(currentTIPS(min(iTIPS):max(iTIPS),1),currentTREA(min(iTREA):max(iTREA),1))
            currentTREA = currentTREA(min(iTREA):max(iTREA),1:2);
            currentTIPS = currentTIPS(min(iTIPS):max(iTIPS),1:2);
    end  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % THIS CODE BLOCK TRUNCATES/IMPUTES CURRENT TIPS AND TREASURY DATA SO THAT THEY HAVE SAME DATES AS SWAP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Gets ZCIS curves for the dates
        %Finds the intersection of dates 
    [dates,iTIPS,iSWAP] = intersect(currentTIPS(:,1),swapcurves(2:end,1));
    currentSWAP = swapcurves((min(iSWAP)+1):(max(iSWAP)+1),1:end);
    tempTIPS = currentTIPS(iTIPS,:);
    tempTREA = currentTREA(iTIPS,:);  
    
    %setdiff(currentSWAP(:,1),tempTIPS(:,1))
    %setdiff(tempTIPS(:,1),currentSWAP(:,1))
    
    %If the length doesn't match we are missing some data points
    while length(currentSWAP(:,1))~=length(tempTIPS(:,1))
    
            if length(tempTIPS) > length(currentSWAP)
                %if currentSWAP is shorter
                temp = (iTIPS(2:end)-iTIPS(1:end-1))-1;
            
                [row,~,v] = find(temp);
                m = 1;
                while m <= length(v)
                    if v(m) <= 3 %maximum three days of copying ZCIS curves
                        currentSWAP = [currentSWAP(1:row(m),:);tempTIPS(row(m)+1:row(m)+v(m),1), repmat(currentSWAP(row(m),2:361),v(m),1);currentSWAP(row(m)+1:end,:)];
                    else %we delete the price points in the bond timeseries if more than 3 points is missing   
                        tempTIPS(row(m)+1:row(m)+v(m),:) = [];
                        tempTREA(row(m)+1:row(m)+v(m),:) = [];
                    end
                    [dates,iTIPS,iSWAP] = intersect(tempTIPS(:,1),currentSWAP(:,1));
                    temp = (iTIPS(2:end)-iTIPS(1:end-1))-1;
                    [row,~,v] = find(temp);
                end
            elseif    length(tempTIPS) < length(currentSWAP)
                %if currentTIPS is shorter
                temp = (iSWAP(2:end)-iSWAP(1:end-1))-1;
                [row,~,v] = find(temp);
                m = 1;
                while m <= length(v)
                    if v(m) <= 3 %maximum three days of copying bond price points
                        tempTIPS = [tempTIPS(1:row(m),:);currentSWAP(row(m)+1:row(m)+v(m),1), repmat(tempTIPS(row(m),2),v(m),1);tempTIPS(row(m)+1:end,:)];
                        tempTREA = [tempTREA(1:row(m),:);currentSWAP(row(m)+1:row(m)+v(m),1), repmat(tempTREA(row(m),2),v(m),1);tempTREA(row(m)+1:end,:)];
                    else %we delete the ZCIS curve points if more than 3 points is missing   
                        currentSWAP(row(m)+1:row(m)+v(m),:) = [];
                    end
                
                    [dates,iTIPS,iSWAP] = intersect(tempTREA(:,1),currentSWAP(:,1));
                    temp = (iSWAP(2:end)-iSWAP(1:end-1))-1;
                    [row,~,v] = find(temp);
                end
            end
    end
    
    currentTREA = tempTREA;
    currentTIPS = tempTIPS;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%THIS CODE BLOCK GIVES DATES AND PRICES FOR STRIPS MATCHED TO CURRENT TREASURY BOND (currentSTRIPS)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Gets STRIPS for the available dates
        %Finds the coupon schedule for the Treasury bond
        currentCoupons = treasuryCouponNum(:,i);
        currentCoupons(find(currentCoupons==0),:)=[];
    
        %Finds the CUSIPS for STRIPs for each coupon date
        currentSTRIPSstr = TreasurySTRIPs(:,i);
        IndexS = strfind(currentSTRIPSstr(:,1),']');
        Indexs = find(not(cellfun('isempty', IndexS)));
            %removes cells with "]"
        filledindexes = setdiff(1:length(currentSTRIPSstr),Indexs);
        currentSTRIPSstr = currentSTRIPSstr(filledindexes,1);
        emptyCells = cellfun(@isempty,currentSTRIPSstr);
        %# remove empty cells
        currentSTRIPSstr(emptyCells) = [];
        
        %Finds the STRIPS price timeseries
        currentSTRIPS = zeros(length(stripTimeseries(:,1)),0);
        k = 1;
        
        while k <= length(currentSTRIPSstr)-1
            IndexZ = strfind(stripCUSIPs(:,1),currentSTRIPSstr(k+1,1));
            Indexz = find(not(cellfun('isempty', IndexZ)));
            currentSTRIPS = [currentSTRIPS,stripTimeseries(:,(Indexz(1)*2)-1:(Indexz(1)*2))];
            k = k + 1;
        end
    
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Aligns the available dates for each coupon and the TIPS, TREA and SWAP
    % Starts from behind
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clean up to here
    g = length(currentCoupons);  
    while g >= 1
        tempSTRIPS = currentSTRIPS(:,(g*2)-1:g*2);
        tempSTRIPS( ~any(tempSTRIPS,2), : ) = [];    % removes nans
        tempSTRIPS(find(tempSTRIPS(:,2)==0),:) = []; % removes zeros
        
            %       setdiff(tempTIPS(:,1), currentSTRIP(:,1))
            %       setdiff( currentSTRIP(:,1),tempTIPS(:,1))
            %       setdiff(currentTIPS(:,1), currentSWAP(:,1))
            %       setdiff(currentSWAP(:,1), currentTIPS(:,1))

        [dates,iTIPS,iSTRIP] = intersect(currentTIPS(:,1),tempSTRIPS(:,1));
        currentSTRIP = tempSTRIPS(min(iSTRIP):max(iSTRIP),1:end);
        tempTIPS = currentTIPS(iTIPS,:); %here the student chooses to not impute TIPS/TREA/SWAP dates
        tempTREA = currentTREA(iTIPS,:);
        tempSWAP = currentSWAP(iTIPS,:);
%         tempTIPS = currentTIPS(min(iTIPS):max(iTIPS),:); 
%         tempTREA = currentTREA(min(iTIPS):max(iTIPS),:);
%         tempSWAP = currentSWAP(min(iTIPS):max(iTIPS),:);
      
        if length(tempTIPS(:,1)) < length(currentSTRIP(:,1))
            %if currentTIPS is shorter
                temp = (iSTRIP(2:end)-iSTRIP(1:end-1))-1;
                [row,~,v] = find(temp);
                m = 1;
                while m <= length(v)
                    if v(m) <= 3 %maximum three days of copying bond price points
                        tempTIPS = [tempTIPS(1:row(m),:);currentSTRIP(row(m)+1:row(m)+v(m),1), repmat(tempTIPS(row(m),2),v(m),1);tempTIPS(row(m)+1:end,:)];
                        tempTREA = [tempTREA(1:row(m),:);currentSTRIP(row(m)+1:row(m)+v(m),1), repmat(tempTREA(row(m),2),v(m),1);tempTREA(row(m)+1:end,:)];
                        tempSWAP = [tempSWAP(1:row(m),:);currentSTRIP(row(m)+1:row(m)+v(m),1), repmat(tempSWAP(row(m),2:361),v(m),1);tempSWAP(row(m)+1:end,:)];
                    else %we delete the strips points if more than 3 points is missing   
                        currentSTRIP(row(m)+1:row(m)+v(m),:) = [];
                    end
                
                    [dates,iTIPS,iSTRIP] = intersect(tempTIPS(:,1),currentSTRIP(:,1));
                    temp = (iSTRIP(2:end)-iSTRIP(1:end-1))-1;
                    [row,~,v] = find(temp);
                end
                %creates a variable for each coupon there exist
                evalc(['Coupon' num2str(g) ' = currentSTRIP']);
        
        elseif length(tempTIPS(:,1)) > length(currentSTRIP(:,1))
            %if currentSTRIP is shorter
                temp = (iTIPS(2:end)-iTIPS(1:end-1))-1;
                [row,~,v] = find(temp);
                m = 1;
                while m <= length(v)
                    if v(m) <= 3 %maximum three days of copying price points
                        currentSTRIP = [currentSTRIP(1:row(m),:);tempTIPS(row(m)+1:row(m)+v(m),1), repmat(currentSTRIP(row(m),2),v(m),1);currentSTRIP(row(m)+1:end,:)];
                    else %we delete the price points in the bond timeseries if more than 3 points is missing   
                        tempTIPS(row(m)+1:row(m)+v(m),:) = [];
                        tempTREA(row(m)+1:row(m)+v(m),:) = [];
                        tempSWAP(row(m)+1:row(m)+v(m),:) = [];
                    end
                    [dates,iTIPS,iSTRIP] = intersect(tempTIPS(:,1),currentSTRIP(:,1));
                    temp = (iTIPS(2:end)-iTIPS(1:end-1))-1;
                    [row,~,v] = find(temp);
                end 
             evalc(['Coupon' num2str(g) ' = currentSTRIP']);
        else %if the TIPS and currentSTRIP match we just save it 
             evalc(['Coupon' num2str(g) ' = currentSTRIP']);
        end
        
        if g == length(currentCoupons)
            currentTIPS = tempTIPS;
            currentTREA = tempTREA;
            currentSWAP = tempSWAP;
        end    
        g = g - 1;
    end
    
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Makes sure no date is not in all rows
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    g = length(currentCoupons);  
    while g >= 1
        evalc(['currentSTRIP = Coupon' num2str(g)]);
        [dates,iTIPS,iSTRIP] = intersect(currentTIPS(:,1),currentSTRIP(:,1));
        currentSTRIP = currentSTRIP(iSTRIP,:);
        evalc(['Coupon' num2str(g) '= currentSTRIP']);  
        g = g - 1;
    end    
    
    
    %finds the start date using the TIPS and the last coupon
    evalc(['firstDate = Coupon' num2str(length(currentCoupons)) '(1,1)']);
    startdate = max(currentTIPS(1,1),firstDate);

    %aligns the timeseries in one matrix
    allDates = zeros(0,0);
    allDates(1:length(find(currentTIPS(:,1)>=startdate)),1) = ...
        currentTIPS(find(currentTIPS(:,1)>=startdate),1);
    
    g = length(currentCoupons);
    m = 1;
    currentSTRIPS = zeros(0,0);
    
    %lists strips' dates and prices 
    while g >= 1 
        if g == length(currentCoupons)
            evalc(['currentSTRIP = Coupon' num2str(g)]);
            currentSTRIPS = currentSTRIP;
        else
            evalc(['currentSTRIP = Coupon' num2str(g)]);
            currentSTRIPS(1:length(find(currentSTRIP(:,1)>=startdate)),(m*2)-1:(m*2)) = ...
                currentSTRIP(find(currentSTRIP(:,1)>=startdate),1:2);
        end    
        m = m + 1;
        g = g - 1;
    end
    
    %Inserts missing prices in STRIPS
    m = length(find(currentSTRIPS(1,:)~=0))/2;
    while m >= 1
        %Finds day before maturity; latest day before each strip's maturity
        upUntilIndex = max(find(currentSTRIPS(:,1)-currentCoupons(length(currentCoupons)-m+1)<0));
        %Test difference
        missingPrices = upUntilIndex-max(find(currentSTRIPS(:,(m*2)-1)~=0));
        lastPrice = max(find(currentSTRIPS(:,(m*2)-1)~=0));
        j = 1;
        %missing prices imputed with latest available price
        while j <= missingPrices
            currentSTRIPS(lastPrice+j,(m*2)-1) = currentSTRIPS(lastPrice+j,1);
            currentSTRIPS(lastPrice+j,(m*2)) = currentSTRIPS(lastPrice,(m*2));
            j = j + 1;
        end    
        m = m - 1;
    end
  
        %aligns the timeseries in a matrix one more time
    allDates = zeros(0,0);
    allDates(1:length(find(currentTIPS(:,1)>=startdate)),1) = currentTIPS(find(currentTIPS(:,1)>=startdate),1);
    g = length(currentCoupons);
    m = 1;
    while g >= 1 
        if g == length(currentCoupons)
            currentSTRIP = currentSTRIPS(:,(m*2)-1:(m*2));
            currentSTRIP(find(currentSTRIP(:,1)==0),:)=[];
            evalc(['Coupon' num2str(g) '=currentSTRIP']);
            allDates(1:length(currentSTRIP(:,1)),m+1) = currentSTRIP(:,1);
        else
            currentSTRIP = currentSTRIPS(:,(m*2)-1:(m*2));
            currentSTRIP(find(currentSTRIP(:,1)==0),:)=[];
            evalc(['Coupon' num2str(g) '=currentSTRIP']);
            allDates(1:length(find(currentSTRIP(:,1)>=startdate)),m+1) = currentSTRIP(find(currentSTRIP(:,1)>=startdate),1);
        end    
        m = m + 1;
        g = g - 1;
    end
    
    %Checks if rows are aligned
    allDatesMatch = ismember(allDates,allDates(:,1),'legacy');
    
        %Gets static data for current bonds
    IndexSTIPS = strfind(staticTIPS(:,18),CUSIP(i+1,1));
    IndexsTIPS = find(not(cellfun('isempty', IndexSTIPS)));
    currentStaticTIPS = staticTIPS(IndexsTIPS,:);
    currentStaticTIPSNum = staticTIPSNum(IndexsTIPS-1,:);
    if strcmp(currentStaticTIPS(1,9),'S/A')
        couponFactorTIPS = 2;
    else
        couponFactorTIPS = 1;
    end
    cnpTIPS = currentStaticTIPSNum(1,1)/couponFactorTIPS;

    IndexSTREA = strfind(staticTrea(:,18),CUSIP(i+1,2));
    IndexsTREA = find(not(cellfun('isempty', IndexSTREA)));
    currentStaticTREA = staticTrea(IndexsTREA,:);
    currentStaticTREANum = staticTreaNum(IndexsTREA-1,:); 
    if strcmp(currentStaticTREA(1,9),'S/A')
        couponFactorTREA = 2;
    else
        couponFactorTREA = 1;
    end
    cnpTREA = currentStaticTREANum(1,1)/couponFactorTREA;
    numberOfCoupons = length(currentCoupons);  %%%%%%%%%%%%BUT SOME COUPONS ARE TRUNCATED...
    
    currentSTIPSCashDates = stripsCashdatesNum(:,i);
    currentSTIPSCashDates(find(currentSTIPSCashDates==0))=[];
   
    %Does the actual backtest
    h = 1;
     %%%NOTE_1: I changed this so loop stops when date reaches the minimum of 
    % synthetic trea/actual trea maturity date, grabbed from overview table
    enddate = max(find(allDates(:,1) <= min(currentStaticTIPSNum(1,2),currentStaticTIPSNum(1,2)))) % was originally TIPS and TIPS, makes no sense zmk
    result = zeros(enddate,6+(numberOfCoupons*3));
    
    if currentStaticTIPSNum(1,2) < currentStaticTREANum(1,2)
        disp("TIPS MAT AFTER TRES");
    end
    
    disp(allDates(enddate,1))
    disp(min(currentStaticTIPSNum(1,2),currentStaticTREANum(1,2)))
     
    while h <= enddate %the coupon might stop before the TIPS and vice versa!
        
        %Sets the settlementdate
        settleDate = allDates(h,1);
        
        %Makes sure that we do not include coupons that are matured
        while length(currentCoupons) ~= sum(allDatesMatch(h,2:end))
            currentCoupons(1)=[];
        end
        
        %Gets the accrued interest of Treasury and TIPS 
        %%% WHAT IS TRESonTIPS?
        [accruedTRESonTIPS] = accruedinterest(currentStaticTREA(1,17),...
            currentStaticTREA(1,9),currentStaticTREANum(1,1),...
            currentStaticTIPSNum(1,6),currentStaticTIPSNum(1,12),...
            currentStaticTIPSNum(1,2),settleDate);
        if isnan(accruedTRESonTIPS)
            accruedTRESonTIPS=0;
        end
        
        [accruedTIPS] = accruedinterest(currentStaticTIPS(1,17),...
            currentStaticTIPS(1,9),currentStaticTIPSNum(1,1),...
            currentStaticTIPSNum(1,6),currentStaticTIPSNum(1,12),...
            currentStaticTIPSNum(1,2),settleDate);
        if isnan(accruedTIPS)
            accruedTIPS=0;
        end

        [accruedTREA] = accruedinterest(currentStaticTREA(1,17),...
            currentStaticTREA(1,9),currentStaticTREANum(1,1),...
            currentStaticTREANum(1,6),currentStaticTREANum(1,12),...
            currentStaticTREANum(1,2),settleDate);
        if isnan(accruedTREA)
            accruedTREA=0;
        end

        %Gets reference price index for the ZCIS
        [currentZCISRefIndex] = zcisreferenceindex(cpival,settleDate,countryFlag);
    
        %Gets reference price index for the TIPS
        [currentTIPSRefIndex] = tipsreferenceindex(cpival,countryFlag,currentStaticTIPSNum);
        
        %Creates the factor for adjusting the difference in CPI reference index value
        
        if inflationAdjFlag
            referenceIndexBaseAdjustment = currentZCISRefIndex/currentTIPSRefIndex;
        else
            referenceIndexBaseAdjustment = 1;
        end

        result(h,1) = settleDate;
        %Accrued interest and inflation, as described in Advanced Fixed
        %Income Analysis, page 137, equation 6.23
        %dirtyTIPS = accruedTIPS + ...
         %   currentTIPS(find(currentTIPS(:,1)==settleDate),2); 
        dirtyTIPS = accruedTIPS*referenceIndexBaseAdjustment + ...
            currentTIPS(find(currentTIPS(:,1)==settleDate),2); 
        result(h,2) = dirtyTIPS;
        dirtyTREA = accruedTREA + currentTREA(find(currentTREA(:,1)==settleDate),2);
        result(h,4) = dirtyTREA;
       
        %Gets the swapcurve of the settlement date
        swapCurve = currentSWAP(find(currentSWAP(:,1)==settleDate),2:end);
        
        %Finds the fixed leg for each swap point for each coupon
        g = numberOfCoupons;
        fixedSwapLeg = zeros(0,0);
        p = 1;
        %start with last coupon and stop before we take matured coupons
        while g > (numberOfCoupons-length(currentCoupons)) 
             lastDate = currentCoupons(length(currentCoupons)-(p-1));  
             %if the coupon is closer than one year we use the one year swap rate
             if (lastDate-settleDate)/365 <= 1
                 daysToSettlement = ((lastDate-settleDate)/365);
                 if daysToSettlement == 0
                    daysToSettlement = 1;
                 end
                 %fixedSwapLeg(p,1) = ((((1+swapCurve(1,find(swapTenor==1)))^((daysToSettlement)))-1))+1;
                 fixedSwapLeg(p,1) = (((1+swapCurve(1,find(swapTenor==1)))^((daysToSettlement))-1)*referenceIndexBaseAdjustment)+1;
             else %else we take the actual rate using linear interpolation between the closet two dates
                 if (lastDate-settleDate)/365 > 30
                     lastDate = round(lastDate-(((lastDate-settleDate)/365)-30)*365);
                 end 
                 negativeIndices = find(swapTenor(1,:)-((lastDate-settleDate)/365)<0);
                 curveSlope = (swapCurve(1,max(negativeIndices)+1)-swapCurve(1,max(negativeIndices)))/(swapTenor(1,max(negativeIndices)+1)-swapTenor(1,max(negativeIndices)));
                 %linear interpolation: y = ax + b 
                 fixedLegInterpolation = ((lastDate-settleDate)/365-max(negativeIndices)*1/12)*curveSlope+swapCurve(1,max(negativeIndices));
                 %fixedSwapLeg(p,1) = (((1+fixedLegInterpolation)^((lastDate-settleDate)/365)-1))+1;
                 fixedSwapLeg(p,1) = (((1+fixedLegInterpolation)^((lastDate-settleDate)/365)-1)*referenceIndexBaseAdjustment)+1;
             end    
             g = g - 1;
             p = p + 1;
        end

        %gets the STRIP prices for the settlement date  %%%ISSUE_MARK_1
        tempPricesSTRIP = currentSTRIPS(h,2:2:numberOfCoupons*2);
        tempPricesSTRIP = tempPricesSTRIP(1,find(tempPricesSTRIP>0));
        STRIPSTrade = zeros(0,0);
        missingCashflow = zeros(0,0);
        %Calculates the strip to be traded
        if length(tempPricesSTRIP) > 1
            missingCashflow(1,1) = ((cnpTREA+100)-(fixedSwapLeg(1,1)*(cnpTIPS+100)))/100;
            missingCashflow(2:length(fixedSwapLeg),1) = ((cnpTREA-(fixedSwapLeg(2:length(fixedSwapLeg))*cnpTIPS))/100);
            STRIPSTrade = missingCashflow.*tempPricesSTRIP';
        else
            missingCashflow = ((cnpTREA+100)-(fixedSwapLeg(1,1)*(cnpTIPS+100)))/100;
            STRIPSTrade(1,1) = missingCashflow*tempPricesSTRIP(1,1);
        end
        
        TresAccrualOnTIPS = ((cnpTREA-missingCashflow(end)*100)/cnpTREA)*accruedTRESonTIPS;
        TresAccrualOnSTRIP = (missingCashflow(end)*100)*(settleDate-(currentSTIPSCashDates(end-length(currentCoupons)+1)-182))/182;

        %Calculates the YTM of the synthetic and regular Treasury bond
        if x2mdate(settleDate,0) >= x2mdate(currentStaticTREANum(1,2),0) % if past tres maturity date
            yieldToMaturityTREA = 0; 
        else
            if settleDate<currentStaticTREANum(1,12) % if before issue date
                yieldToMaturityTREA = bndyield(currentTREA(find(currentTREA(:,1)==settleDate),2), ...
                    currentStaticTREANum(1,1)/100, x2mdate(currentStaticTREANum(1,12),0), ...
                    x2mdate(currentStaticTREANum(1,2),0), 2, 0, 0, x2mdate(currentStaticTREANum(1,12),0), ...
                    x2mdate(currentStaticTREANum(1,6),0));
            else
                yieldToMaturityTREA = bndyield( ...
                    currentTREA(find(currentTREA(:,1)==settleDate),2), ... % Clean Price of Treasury
                    currentStaticTREANum(1,1)/100, ...                     % Coupon Rate
                    x2mdate(settleDate,0), ...                             % Settlement Date
                    x2mdate(currentStaticTREANum(1,2),0), ...              % Maturity Date 
                    2, 0, 0, ...                                           % Period, Basis, End Month Rule
                    x2mdate(currentStaticTREANum(1,12),0), ...             % Issue Date
                    x2mdate(currentStaticTREANum(1,6),0));                 % First Coupon Date
            end    
        end
        
        result(h,5) = yieldToMaturityTREA;
        strange_error = false;

        if x2mdate(settleDate,0) >= x2mdate(currentStaticTREANum(1,2),0)
            yieldToMaturityTREASynth = 0; 
        else
            
       
            %sometimes we see prices before the bond is issued! Pre-auction prices.
            if settleDate<currentStaticTREANum(1,12)
                yieldToMaturityTREASynth = bndyield( ...
                    currentTIPS(find(currentTIPS(:,1)==settleDate),2)+sum(STRIPSTrade), ... 
                    currentStaticTREANum(1,1)/100, ...
                    x2mdate(currentStaticTIPSNum(1,12),0), ...
                    x2mdate(currentStaticTIPSNum(1,2),0), ...
                    2, 0, 0, ...
                    x2mdate(currentStaticTIPSNum(1,12),0),...
                    x2mdate(currentStaticTIPSNum(1,6),0));
                
            elseif x2mdate(settleDate,0) < x2mdate(currentStaticTIPSNum(1,2),0)  %%%ISSUE_MARK_2
                yieldToMaturityTREASynth = bndyield( ...
                    currentTIPS(find(currentTIPS(:,1)==settleDate),2)+ ...
                    sum(STRIPSTrade)+accruedTIPS*referenceIndexBaseAdjustment-TresAccrualOnTIPS-TresAccrualOnSTRIP, ...
                    currentStaticTREANum(1,1)/100, ...
                    x2mdate(settleDate,0), ...
                    x2mdate(currentStaticTIPSNum(1,2),0), ...
                    2, 0, 0, ...
                    x2mdate(currentStaticTREANum(1,12),0), ... % changed TREANum to TIPS Num, ZMK, 3/25/20
                    x2mdate(currentStaticTREANum(1,6),0));     % changed TREANum to TIPS Num, ZMK, 3/25/20
                %%% FOR h=630 we have  x2mdate(settleDate,0) = x2mdate(currentStaticTIPSNum(1,2),0) SO THAT GIVES AN ERROR
                
                if ~isreal(yieldToMaturityTREASynth) %%%ISSUE_MARK_3 THIS CASE WASN'T IN ORIGINAL CODE. THIS IS A TEMPORARY FIX.
                    strange_error = true
                end 
            else yieldToMaturityTREASynth = 0; %added this case because some times settledate >= maturity.
            end 
        end
        
        result(h,3) = yieldToMaturityTREASynth;
        
        if settleDate >= currentStaticTREANum(1,2) %if Settle is equal maturity we subtract one day to get a estimate of the YTM
            diff = settleDate-currentStaticTREANum(1,2);
            [TREAPriceSameYield, TREAAccruedSameYield] = bndprice(yieldToMaturityTREASynth, ...
                currentStaticTREANum(1,1)/100, x2mdate(settleDate-(1+diff),0), x2mdate(currentStaticTREANum(1,2),0),2,0,0);
        else    
            [TREAPriceSameYield, TREAAccruedSameYield] = bndprice(yieldToMaturityTREASynth, ...
                currentStaticTREANum(1,1)/100, x2mdate(settleDate,0), x2mdate(currentStaticTREANum(1,2),0),2,0,0);
        end
        
        %Same yield as TIPS, what is the price of the TREA?
        result(h,6) = TREAPriceSameYield + TREAAccruedSameYield;
        
        %Dirty price of the synthetic Treasury bond
        result(h,7) = currentTIPS(find(currentTIPS(:,1)==settleDate),2)+sum(STRIPSTrade)+accruedTIPS*referenceIndexBaseAdjustment;
        
        %Clean price of the synthetic Treasury bond
        result(h,8) = currentTIPS(find(currentTIPS(:,1)==settleDate),2)+sum(STRIPSTrade)+accruedTIPS*referenceIndexBaseAdjustment-TresAccrualOnTIPS-TresAccrualOnSTRIP;

        %Arbitrage profit/loss
        result(h,8) = dirtyTREA - (TREAPriceSameYield + TREAAccruedSameYield);
        
        %%Arbitrage YTM difference
        result(h,9) = yieldToMaturityTREASynth-yieldToMaturityTREA;
        
        %Saves the results in a matrix
        fixedSwapPayment = (fixedSwapLeg*cnpTIPS)';
        fixedSwapPayment(1,1) = (fixedSwapLeg(1,1)*(cnpTIPS+100))';
        
        result(h,11:length(currentCoupons)+10) = fixedSwapPayment; %(fixedSwapLeg*cnpTIPS)';
        result(h,numberOfCoupons+11:numberOfCoupons+10+length(currentCoupons)) = STRIPSTrade';
        result(h,numberOfCoupons*2+11:numberOfCoupons*2+10+length(currentCoupons)) = missingCashflow';
        
        if strange_error == true  %%%ISSUE_MARK_4
            result(h,[3,6,7,8,9]) = result(h-1,[3,6,7,8,9]);
        end 
        
        h = h + 1;
    end   
    
    if winsorFlag
        result(:,8) = winsor(result(:,8),[0.5 99.5]); 
        result(:,9) = winsor(result(:,9),[0.5 99.5]);
    end
        
        
    %removes the variables CouponX before next round
    g = 1;
    while g <= numberOfCoupons
        vars = {strcat('Coupon',num2str(g))};
        clear(vars{:}) 
        g = g + 1;
    end      
    
    
    %export results to excel file
    if mode == "student_updated"
        csvwrite(['S:\SHARE\cmf\Desi\Ken\project\replication code\MISPRICING_RESULTS\pair' ...
            num2str(i) 'result_replicate_nooutliers_03102020.csv'], result);
    elseif mode == "feb2021_update"
        csvwrite(['S:\SHARE\cmf\Desi\Ken\project\feb2021update\mispricing_results\pair' ...
            num2str(i) 'result_updated_checkJul2020.csv'], result);
    elseif mode == "student_old"
        csvwrite(['S:\SHARE\cmf\Desi\Ken\project\cleaned code\MISPRICING_RESULTS\pair' ...
            num2str(i) 'result_replicate_nooutliers.csv'], result);
    elseif mode == "fleck_rep"
        csvwrite(['S:\SHARE\cmf\Desi\Ken\project\replication code\MISPRICING_RESULTS\pair' ...
            num2str(i) 'result_replicate_nooutliers_FL_rep.csv'], result);
    end
   
    %adds to the large while loop-counter
    l = l + 2;
    i = i + 1;
   
end
 



















            