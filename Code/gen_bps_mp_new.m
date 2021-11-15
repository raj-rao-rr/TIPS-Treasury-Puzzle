% This code is generates the aggregate average mispricing across all
% maturities and on the three maturity buckets

clearvars -except root_dir;

% import the price data and overview for all bond instruments
load DATA TREASURYS TIPS

% loads the TIPS Treasury link table
load MATCH tips_treasury_match 


%% construct the aggregate bps mispricing time series

fprintf('\n8) Constructing aggregate mispricing time series\n');

% [T1, ~] = size(tips_treasury_match); 
T1 = 10; 

% initialize bps mispricing table
resultTable = zeros(0, 0);
dates = zeros(0, 0);
graphData = zeros(0, 0);

% maturity buckets cutoff points (in years)
short_bucket = 2;
long_bucket = 5;

for i = 1:T1
    
    % retrieve the correct Treasury CUSIP corresponding to match
    treasury_cusip = tips_treasury_match{i, 'Treasury_CUSIP'};
    tips_cusip = tips_treasury_match{i, 'TIPS_CUSIP'};
    
    % loads the mispricing time-series for each pair
    filename = strcat(root_dir, ...
        '/Output/mispricing_results/student_adjusted_', treasury_cusip{:}, '.csv');
    tb = readtable(filename);
    
    dates = union(dates, datenum(tb.Time));
    
    % recover important figures for corresponding securities issue
    tips_notional = TIPS{ismember(TIPS.CUSIP, tips_cusip), 'Amt Issued'};
    maturity = min(TIPS{ismember(TIPS.CUSIP, tips_cusip), 'Maturity'}, ...
        TREASURYS{ismember(TREASURYS.CUSIP, treasury_cusip), 'Maturity'}); 
    
    % store results for each variable
    resultTable(1,(i*2)) = datenum(maturity);
    resultTable(1,(i*2)-1) = tips_notional;
    resultTable(2:length(tb.Time)+1,(i*2)-1) = datenum(tb.Time);
    resultTable(2:length(tb{:,9})+1,(i*2)) = tb{:, 9};
    
end

% itterate through the full date series 
T2 = length(dates);
graphData = zeros(T2, 15);

for g = 1:T2
    
    current_date = dates(g, 1);
    
    % search in each arbitrage timeseries for the date
    p = 1;
    constituents = zeros(0,0);
    for l = 1:T1 
        
        % treasury cusip corresponding to TIPS mapping
        trea_cusip = tips_treasury_match{l, 2}; 
        
        % loads the mispricing time-series for each pair
        filename = strcat(root_dir, ...
            '/Output/mispricing_results/student_adjusted_', treasury_cusip{:}, ...
            '.csv');
        tb = readtable(filename);
        
        index = ismember(tb{:, 'Time'}, ...
            datetime(dates(g, 1), 'ConvertFrom', 'datenum')); 
        
        if ~isempty(index)
            
            % mispricing on the day (NOTE: Column 2 isn't the mispricing)
            constituents(p, 1) = tb{index, 9};
            
            % gets the outstanding amount
            constituents(p, 2) = resultTable(1,(l*2)-1);
            constituents(p, 3) = (resultTable(1,(l*2))-current_date)/365;
            constituents(p, 4) = l;
            p = p + 1;
            
        end
        
    end
     
    % defining term intervals aggregate, medium, short, and long (from paper)
    allTerm = find(constituents(:,3)); 
    mediumTerm = find(constituents(:,3)>short_bucket & constituents(:,3)<=long_bucket);
    shortTerm = find(constituents(:,3)<=short_bucket);
    longTerm = find(constituents(:,3)>long_bucket);
    
    % different intervals around 10 year date-to-maturity- 2y, 1y, 6m, 1m
    tenyearTerm_twoyear = find(constituents(:,3)> 8 & constituents(:,3)<=12);
    tenyearTerm_year = find(constituents(:,3)> 9 & constituents(:,3)<=11);
    tenyearTerm_half = find(constituents(:,3)> 9.5 & constituents(:,3)<=10.5);
    
    % additional intervals that partition the long term bucket
    two_m_plus = find(constituents(:,3) >= 2/12);
    two_plus = find(constituents(:,3) >= 2);
    eight_plus = find(constituents(:,3)>= 8);
    ten_plus = find(constituents(:,3)>= 10);
    
    % calculating term weights
    weightsAll = constituents(allTerm,2)/sum(constituents(allTerm,2)); 
    weightsShort = constituents(shortTerm,2)/sum(constituents(shortTerm,2));
    weightsMedium = constituents(mediumTerm,2)/sum(constituents(mediumTerm,2));
    weightsLong = constituents(longTerm,2)/sum(constituents(longTerm,2));
        
    weightsyear_twoyear = constituents(tenyearTerm_twoyear,2)/sum(constituents(tenyearTerm_twoyear,2));       
    weightsyear_year = constituents(tenyearTerm_year,2)/sum(constituents(tenyearTerm_year,2));
    weightsyear_half = constituents(tenyearTerm_half,2)/sum(constituents(tenyearTerm_half,2));
    weightsTwo_plus = constituents(two_plus,2)/sum(constituents(two_plus,2));
    weightsTwo_m_plus = constituents(two_m_plus,2)/sum(constituents(two_m_plus,2));

    weights_eight_plus = constituents(eight_plus,2)/sum(constituents(eight_plus,2));
    weights_ten_plus = constituents(ten_plus,2)/sum(constituents(ten_plus,2));

    % total weights
    totalNotional = sum(constituents(shortTerm,2))+sum(constituents(mediumTerm,2))+sum(constituents(longTerm,2));
    
    totWeightShort = sum(constituents(shortTerm,2))/totalNotional;
    totWeightMedium = sum(constituents(mediumTerm,2))/totalNotional;
    totWeightLong = sum(constituents(longTerm,2))/totalNotional;
    
    totweightsyear_twoyear = sum(constituents(tenyearTerm_twoyear,2))/totalNotional;
    totweightsyear_year = sum(constituents(tenyearTerm_year,2))/totalNotional;
    totweightsyear_half = sum(constituents(tenyearTerm_half,2))/totalNotional;
    
    totweights_two_m_plus = sum(constituents(two_m_plus,2))/totalNotional;
    totweights_two_plus = sum(constituents(two_plus,2))/totalNotional;
    totweights_five_to_eight = sum(constituents(eight_plus,2))/totalNotional;
    totweights_ten_plus = sum(constituents(ten_plus,2))/totalNotional;

    % graph data
    graphData(g,1) = current_date;
    graphData(g,2) = mean(weightsShort.'*constituents(shortTerm,1))*10000;
    graphData(g,3) = mean(weightsMedium.'*constituents(mediumTerm,1))*10000;
    graphData(g,4) = mean(weightsLong.'*constituents(longTerm,1))*10000;
    graphData(g,5) = totWeightShort;
    graphData(g,6) = totWeightMedium;
    graphData(g,7) = totWeightLong;
    graphData(g,8) = mean(weightsAll.'*constituents(allTerm,1))*10000; %aggregate
    graphData(g,9) = mean(weightsyear_twoyear.'*constituents(tenyearTerm_twoyear,1))*10000;
    graphData(g,10) = mean(weightsyear_year.'*constituents(tenyearTerm_year,1))*10000;
    graphData(g,11) = mean(weightsyear_half.'*constituents(tenyearTerm_half,1))*10000;
    graphData(g,12) = mean(weightsTwo_plus.'*constituents(two_plus,1))*10000;
    graphData(g,13) = mean(weights_eight_plus.'*constituents(eight_plus,1))*10000;
    graphData(g,14) = mean(weights_ten_plus.'*constituents(ten_plus,1))*10000;
    graphData(g,15) = mean(weightsTwo_m_plus.'*constituents(two_m_plus,1))*10000;

end    

%%  collate the graph data for exportation of outputs

bps_mp = array2table(graphData);
bps_mp(:,5:7)=[];
bps_mp.Properties.VariableNames = {'date', 'short', 'med', 'long', 'aggregate', ...
    'bucket_8to12', 'bucket_9to11', 'bucket_10_pm_6mo', 'bucket_2plus', ...
    'bucket_8plus', 'bucket_10plus', 'bucket_2m_plus'};

bps_mp.date = datetime(bps_mp.date, 'ConvertFrom', 'excel');
bps_mp = table2timetable(bps_mp);
bps_mp_m = retime(bps_mp, 'monthly', 'lastvalue');

save('Output/bps_mp_by_maturity', 'bps_mp', 'bps_mp_m');
