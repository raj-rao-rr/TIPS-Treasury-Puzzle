% This code is responsible for performing the actual TIPS-Treasury strategy

clearvars -except root_dir inflation_adj_flag winsor_flag;

% import the price data and overview for all bond instruments
load DATA PRICE_S PRICE_T PRICE_TILL STRIPS TREASURYS TIPS CPI

% loads the TIPS Treasury link table
load MATCH tips_treasury_match strips_treasury_match cashflow_dates ...
    actual_cashflow_dates

% loads the adjusted swap curves
load INFADJ adj_swap_curve 
 

%% construct series for backtesting TIP-Treasury strategy

for row = 1:1%size(tips_treasury_match, 1)
    
    % collect the current matched CUSIP for TIPS and Treasury
    current_tips = tips_treasury_match{row, 'TIPS_CUSIP'};
    current_trea = tips_treasury_match{row, 'Treasury_CUSIP'};
    
    % collect the corresponding price series
    tips_price_series = PRICE_TILL(:, current_tips + " Govt");
    trea_price_series = PRICE_T(:, current_trea + " Govt");
    
    % collect the maturity from the matching series
    tips_maturity = TIPS{ismember(TIPS{:, 'CUSIP'}, current_tips), 'Maturity'};
    trea_maturity = TREASURYS{ismember(TREASURYS{:, 'CUSIP'}, current_trea), ...
        'Maturity'};
    
    % remove NaN from TIPS and Treasury price series
    tips_price_series = rmmissing(tips_price_series);
    trea_price_series = rmmissing(trea_price_series);
    
    % constrict the time series to before maturity
    tips_price_series = tips_price_series(tips_price_series.Dates<tips_maturity, :);
    trea_price_series = trea_price_series(trea_price_series.Dates<trea_maturity, :);
    
    % determine intersection of dates for TIPS and Treasury
    [dates, iTIPS, iTREA] = intersect(tips_price_series.Dates, ...
        trea_price_series.Dates);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % THIS CODE BLOCK TRUNCATES CURRENT TIPS AND TREASURY DATA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    tips_price_series = tips_price_series(iTIPS, :);
    trea_price_series = trea_price_series(iTREA, :);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % THIS CODE BLOCK TRUNCATES TIPS AND TREASURY DATA TO MATCH SWAPS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Gets ZCIS curves to find the intersection of dates 
    date_intersect = mintersect(tips_price_series.Dates, trea_price_series.Dates, ...
        adj_swap_curve.Date);
    
    % filter the corresponding series for the data 
    tips_price_series = tips_price_series(ismember(tips_price_series.Dates, ...
        date_intersect), :);
    trea_price_series = trea_price_series(ismember(trea_price_series.Dates, ...
        date_intersect), :);
    adj_swap_curve = adj_swap_curve(ismember(adj_swap_curve.Date, ...
        date_intersect), :);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % THIS CODE BLOCK PROVIDES MATCH FOR STRIPS TO TREASURY BONDS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % finds the coupon schedule for the Treasury bond
    current_coupons = cashflow_dates{:, current_trea};
    current_coupons = current_coupons(~cellfun('isempty', current_coupons));          % remove empty rows
    
    % finds corresponding CUSIPS for STRIPS for each coupon date
    matched_strips = STRIPS(ismember(STRIPS.Maturity, current_coupons), :);
    
    % determine the CUSIP for matched STRIPS
    strip_cusips = matched_strips.CUSIP;
    strip_cusips = cellfun(@(x) x + " Govt", strip_cusips);
    
    % retrieve the corresponding STRIP prices
    strips_price_series = PRICE_S(:, strip_cusips);
    
%     strips_price_series = strips_price_series(:, ...        % remove NaN columns
%         ~all(isnan(strips_price_series{:, :}),1));
%     strips_price_series = rmmissing(strips_price_series);   % remove NaN rows
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Aligns the available dates for each coupon for TIPS, TREA and SWAP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    date_intersect = mintersect(tips_price_series.Dates, trea_price_series.Dates, ...
        strips_price_series.Dates, adj_swap_curve.Date);
    
    % filter the corresponding series for the data 
    tips_price_series = tips_price_series(ismember(tips_price_series.Dates, ...
        date_intersect), :);
    trea_price_series = trea_price_series(ismember(trea_price_series.Dates, ...
        date_intersect), :);
    strips_price_series = strips_price_series(ismember(strips_price_series.Dates, ...
        date_intersect), :);
    adj_swap_curve = adj_swap_curve(ismember(adj_swap_curve.Date, ...
        date_intersect), :);
    
    % determine effecive Treasury coupon based on S/A or Annual compounding
    coupon_trea_freq = TREASURYS{ismember(TREASURYS{:, 'CUSIP'}, current_trea), ...
        'Cpn Freq Des'}; 
    coupon_trea = TREASURYS{ismember(TREASURYS{:, 'CUSIP'}, current_trea), ...
        'Cpn'}; 
    coupon_tips_freq = TIPS{ismember(TIPS{:, 'CUSIP'}, current_tips), ...
        'Cpn Freq Des'}; 
    coupon_tips = TIPS{ismember(TIPS{:, 'CUSIP'}, current_tips), ...
        'Cpn'}; 
    
    % coupon determination for Treasury and TIPS
    if strcmp(coupon_trea_freq, 'S/A')
        couponFactorTREA = 2;
    else
        couponFactorTREA = 1;
    end
    
    if strcmp(coupon_tips_freq, 'S/A')
        couponFactorTIPS = 2;
    else
        couponFactorTIPS = 1;
    end
    
    cnpTREA = coupon_trea / couponFactorTREA;
    cnpTIPS = coupon_tips / couponFactorTIPS;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTE ARBITRAGE BACKTEST
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    numberOfCoupons = length(current_coupons);
    result = zeros(numel(tips_price_series.Dates), 7+numel(current_coupons)*3);
    
    for h = 1:1%numel(tips_price_series.Dates)
        
        settle_date = tips_price_series.Dates(h);   % sets the settlement date
        
        % retrieve data from Treasury and TIPS to calculate accrued interest 
        trea_issue_date = TREASURYS{ismember(TREASURYS.CUSIP, current_trea), ...
            'Issue_Date'};
        trea_first_coupon_date = TREASURYS{ismember(TREASURYS.CUSIP, current_trea), ...
            'First_Coupon_Date'};
        trea_coupon = TREASURYS{ismember(TREASURYS.CUSIP, current_trea), 'Cpn'}/100;
        
        tips_issue_date = TIPS{ismember(TIPS.CUSIP, current_tips), 'Issue_Date'};
        tips_first_coupon_date = TIPS{ismember(TIPS.CUSIP, current_tips), ...
            'First_Coupon_Date'};
        tips_coupon = TIPS{ismember(TIPS.CUSIP, current_tips), 'Cpn'} / 100;
        
        face_value = 100; 
        
        % compute the accrued interest of Treasury and TIPS 
        act_trea_on_tips = accrued_interest(tips_issue_date, settle_date, ...
            tips_first_coupon_date, face_value, trea_coupon, tips_maturity);
        act_trea = accrued_interest(trea_issue_date, settle_date, ...
            trea_first_coupon_date, face_value, trea_coupon, trea_maturity);
        act_tips = accrued_interest(tips_issue_date, settle_date, ...
            tips_first_coupon_date, face_value, tips_coupon, tips_maturity);
        
        % gets reference price index for the ZCIS (T+2 convention)
        start_date = busdate(busdate(settle_date,1), 1);              
        currentZCISRefIndex = cpireferenceindex(CPI, start_date);
        
        % gets reference price index for the TIPS (T+1 convention)
        start_date = busdate(tips_issue_date, 1);                   
        currentTIPSRefIndex = cpireferenceindex(CPI, start_date);
        
        % if inflation adjusted we perform scaling 
        if inflation_adj_flag
            referenceIndexBaseAdjustment = currentZCISRefIndex/currentTIPSRefIndex;
        else
            referenceIndexBaseAdjustment = 1;
        end
        
        % accrued interest and inflation, as described in Advanced Fixed
        % Income Analysis, page 137, equation 6.23
        dirtyTIPS = act_tips * referenceIndexBaseAdjustment + ...
            tips_price_series{ismember(tips_price_series.Dates, settle_date), 1}; 
        dirtyTREA = act_trea + ...
            trea_price_series{ismember(trea_price_series.Dates, settle_date), 1};
        
        result(h, 1) = dirtyTIPS;
        result(h, 2) = dirtyTREA;
        
        % gets the swap curve of the settlement date
        swapCurve = adj_swap_curve(ismember(adj_swap_curve.Date, settle_date), :);
        
        % finds the fixed leg for each swap point for each coupon
        fixedSwapLeg = zeros(length(current_coupons), 1);
        p = 1; 
        for i = length(current_coupons):-1:1
            
            last_date = datetime(current_coupons(length(current_coupons)-(p-1)));  
            
            % if the coupon is closer than one year we use the one year swap rate
            if (last_date-settle_date)/365 <= 1
                 days_to_settlement = days((last_date-settle_date) / 365);
                 
                 if days_to_settlement == 0
                    days_to_settlement = 1;
                 end
                 
                 swap_pts = (((1+adj_swap_curve{settle_date,'1y'})^...
                     (days_to_settlement)-1)*referenceIndexBaseAdjustment)+1;
                 fixedSwapLeg(p,1) = swap_pts;
             
            % else we take the linear interpolation between the closet two dates
            else 
                 if (last_date-settle_date) / 365 > 30
                     last_date = last_date-(((last_date-settle_date)/365)-30)*365; % note sure why this is rounded, can't round datetime but maybe was numerical date
                 end 
                 
                 swapTenor = 1:1/12:30;
                 negativeIndices = find(swapTenor-((last_date-settle_date)/365)<0);
                 curveSlope = (adj_swap_curve{settle_date, max(negativeIndices)+1}-adj_swap_curve{settle_date,max(negativeIndices)})/(swapTenor(max(negativeIndices)+1)-swapTenor(max(negativeIndices)));
                 
                 % linear interpolation: y = ax + b 
                 fixedLegInterpolation = (days((last_date-settle_date)/365)-max(negativeIndices)*1/12)*curveSlope+adj_swap_curve{settle_date,max(negativeIndices)};
                 fixedSwapLeg(p,1) = (((1+fixedLegInterpolation)^days((last_date-settle_date)/365)-1)*referenceIndexBaseAdjustment)+1;
            end    
            
            p = p + 1;
            
        end
        
        % gets the STRIP prices for the settlement date
        tempPricesSTRIP = strips_price_series{h, :};
        tempPricesSTRIP(isnan(tempPricesSTRIP)) = 0;
        STRIPSTrade = zeros(0,0);
        missingCashflow = zeros(0,0);
        
        % calculates the strip to be traded
        if length(tempPricesSTRIP) > 1
            missingCashflow(1,1) = ((cnpTREA+100)-(fixedSwapLeg(1,1)*(cnpTIPS+100)))/100;
            missingCashflow(2:length(fixedSwapLeg),1) = ((cnpTREA-(fixedSwapLeg(2:length(fixedSwapLeg))*cnpTIPS))/100);
            STRIPSTrade = missingCashflow.*tempPricesSTRIP';
        else
            missingCashflow = ((cnpTREA+100)-(fixedSwapLeg(1,1)*(cnpTIPS+100)))/100;
            STRIPSTrade(1,1) = missingCashflow*tempPricesSTRIP(1,1);
        end
        
        currentSTIPSCashDates = actual_cashflow_dates{:, row};
        currentSTIPSCashDates = datetime(currentSTIPSCashDates(~cellfun('isempty', ...
            currentSTIPSCashDates)));
                
        TresAccrualOnTIPS = ((cnpTREA-missingCashflow(end)*100)/cnpTREA)*act_trea_on_tips;
        TresAccrualOnSTRIP = (missingCashflow(end)*100)*days(settle_date-(currentSTIPSCashDates(end-length(current_coupons)+1)-182))/182;
        
        % calculates the YTM of the synthetic and regular Treasury bond
        if settle_date >= trea_maturity
            yieldToMaturityTREA = 0; 
            yieldToMaturityTREASynth = 0;
            
        else
            if settle_date < trea_issue_date
                yieldToMaturityTREA = bndyield(trea_price_series{h, :}, ...
                    coupon_trea/100, trea_issue_date, trea_maturity, 2, 0, 0, ...
                    trea_issue_date, trea_first_coupon_date);
                
                % compute the synthethic price for replication
                synthetic_price = tips_price_series{h, :} + sum(STRIPSTrade);
                yieldToMaturityTREASynth = bndyield(synthetic_price, ...
                    coupon_trea/100, tips_issue_date, tips_maturity, 2, 0, 0, ...
                    tips_issue_date, tips_first_coupon_date);
                
            elseif settle_date ~= trea_maturity
                
                yieldToMaturityTREA = bndyield(trea_price_series{h, :}, ...
                    coupon_trea/100, trea_issue_date, trea_maturity, 2, 0, 0, ...
                    trea_issue_date, trea_first_coupon_date);
                
                % compute the synthethic price for replication
                synthetic_price = tips_price_series{h, :} + sum(STRIPSTrade) + ...
                    act_tips * referenceIndexBaseAdjustment - ...
                    TresAccrualOnTIPS - TresAccrualOnSTRIP;
                yieldToMaturityTREASynth = bndyield(synthetic_price, ...
                    coupon_trea/100, settle_date, tips_maturity, 2, 0, 0, ...
                    trea_issue_date, trea_first_coupon_date);
            
            else
                yieldToMaturityTREA = bndyield(trea_price_series{h, :}, ...
                    coupon_trea/100, settle_date, trea_maturity, 2, 0, 0, ...
                    trea_issue_date, trea_first_coupon_date);
                yieldToMaturityTREASynth = 0; 
                
            end    
        end
        
        result(h, 3) = yieldToMaturityTREA; 
        result(h, 4) = yieldToMaturityTREASynth; 
        
        
        % if settle is equal maturity we subtract one day to get a estimate of the YTM
        if settle_date >= trea_maturity 
            diff = settle_date-trea_maturity;
            [TREAPriceSameYield, TREAAccruedSameYield] = bndprice(yieldToMaturityTREASynth, coupon_trea/100, settle_date-(1+diff), trea_maturity, 2, 0, 0);
        else    
            [TREAPriceSameYield, TREAAccruedSameYield] = bndprice(yieldToMaturityTREASynth, coupon_trea/100, settle_date, trea_maturity, 2, 0, 0);
        end
        
        % same yield as TIPS, what is the price of the TREA?
        result(h, 5) = TREAPriceSameYield + TREAAccruedSameYield;
        
        % dirty price of the synthetic Treasury bond
        result(h, 6) = tips_price_series{h, :} + sum(STRIPSTrade) + ...
            act_tips * referenceIndexBaseAdjustment;
        
        % clean price of the synthetic Treasury bond
        result(h, 7) = tips_price_series{h, :} + sum(STRIPSTrade) + ...
            act_tips * referenceIndexBaseAdjustment - TresAccrualOnTIPS - ...
            TresAccrualOnSTRIP;

        % arbitrage profit/loss
        result(h, 8) = dirtyTREA - (TREAPriceSameYield + TREAAccruedSameYield);
        
        % arbitrage YTM difference
        result(h,9) = yieldToMaturityTREASynth - yieldToMaturityTREA;
        
        % saves the results in a matrix
        fixedSwapPayment = (fixedSwapLeg * cnpTIPS)';
        fixedSwapPayment(1,1) = (fixedSwapLeg(1,1) * (cnpTIPS+100))';
        
        result(h, 10:length(current_coupons)+9) = fixedSwapPayment;
        result(h, numberOfCoupons+10:numberOfCoupons+9+length(current_coupons)) = STRIPSTrade';
        result(h, numberOfCoupons*2+10:numberOfCoupons*2+9+length(current_coupons)) = missingCashflow';
        
    end
    
    % clean for exportation to results_students_adjusted folder 
    result_tb = array2table(result);
    result_tb = table2timetable(result_tb, 'RowTimes', tips_price_series.Dates);
    
    % ADD ADDITIONAL VARIABLE NAMES FOR EXPORT
    col_names = {'dirty_tips', 'dirty_trea', 'ytm_treasury', 'ytm_synthetic_treasury', ...
        'price_trea', 'dirty_price_synthetic_treasury', 'clean_price_synthetic_treasury', ...
        'arbitrage_profit_loss', 'arbitrage_ytm'};
    
    writetable(result_tb, strcat(root_dir, ...
        '/Output/results_student_adjusted/student_adjusted_', current_trea{:}, '.csv'))
    
end

%% computes mispricing averages for all pairs

% calculates mean mispricing on all pairs

mispricingaverages = zeros(size(tips_treasury_match, 1), 1);
for i = 1:1%size(tips_treasury_match, 1)
    
    % collect the current matched CUSIP for Treasury
    current_trea = tips_treasury_match{row, 'Treasury_CUSIP'};
    
    % read file table to construct mispricing average
    filename = strcat(root_dir, '/Output/results_student_adjusted/student_adjusted_', ...
        current_trea{:}, '.csv');
    data = readtable(filename);
 
    mispricingaverages(i,1) = length(data(:,8)); 

end 

mispricingaverages = transpose(mispricingaverages);
