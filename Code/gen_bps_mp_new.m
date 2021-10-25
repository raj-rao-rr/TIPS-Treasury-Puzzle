% This code is generates the aggregate average mispricing across all
% maturities and on the three maturity buckets

clearvars -except root_dir;

%%

if mode == "student_og" || mode == "student_old"
    %Loads the TIPS and Treasury link table 
    [~,CUSIP] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion_TIPSsortedbymaturity',4);
    %Loads the static TIPS bond table
    [tip_num,tip] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion_TIPSsortedbymaturity',1);
    [tre_num,tre] = xlsread('S:\SHARE\cmf\Desi\Ken\project\Data\BONDS\US_numberversion_TIPSsortedbymaturity',2);
elseif mode == "feb2021_update"
    [~,CUSIP] = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BONDS\US_bonds_feb2021.xlsx',4);
    [tip_num,tip] = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BONDS\US_bonds_feb2021.xlsx',1);
    [tre_num,tre] = xlsread('S:\SHARE\cmf\Desi\Ken\project\feb2021update\BONDS\US_bonds_feb2021.xlsx',2);
elseif mode == "jul2020_update"
    [~,CUSIP] = xlsread('S:\SHARE\cmf\Desi\Ken\project\jul2020update\BONDS\US_bonds_jul2020.xlsx',4);
    [tip_num,tip] = xlsread('S:\SHARE\cmf\Desi\Ken\project\jul2020update\BONDS\US_bonds_jul2020.xlsx',1);
    [tre_num,tre] = xlsread('S:\SHARE\cmf\Desi\Ken\project\jul2020update\BONDS\US_bonds_jul2020.xlsx',2);
elseif mode == "student_updated"
    [~,CUSIP] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',4);
    [tip_num,tip] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',1);
elseif mode == "fleck_rep"
    [~,CUSIP] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',8);
    [tip_num,tip] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',1);
    [tre_num,tre] = xlsread('S:\SHARE\cmf\Desi\Ken\project\new_data_pull\BONDS\US_numberversion_corrected_TIPSsortedbymaturity',2);
end  

%%%%%%%%%BPS MISPRICING%%%%%%%%%
resultTable = zeros(0,0);
dates = zeros(0,0);
graphData = zeros(0,0);

i = 1;
while i <= length(CUSIP)-1 %No Of Bonds
    %Loads the mispricing time-series for each pair
    
    if mode == "student_og"
        %student's results
        result = csvread(strcat('S:\SHARE\cmf\Desi\Ken\project\Data\Export\US - LONG\result', ...
            num2str(i),'.csv'));
        file_path = "student's_original_data";
    elseif mode == "feb2021_update"
        %student's results
        result = csvread(strcat('S:\SHARE\cmf\Desi\Ken\project\feb2021update\mispricing_results\pair', ...
            num2str(i),'result_updated_feb2021.csv'));
        file_path = "feb2021_update";
    elseif mode == "jul2020_update"
        %student's results
        result = csvread(strcat('S:\SHARE\cmf\Desi\Ken\project\feb2021update\mispricing_results\pair', ...
            num2str(i),'result_updated_checkJul2020.csv'));
        file_path = "jul2020_update";
    elseif mode == "student_old"
        result = xlsread(strcat('S:\SHARE\cmf\Desi\Ken\project\cleaned code\MISPRICING_RESULTS\pair', ...
            num2str(i),'result_replicate_nooutliers.csv'));
        file_path = "replication";
    elseif mode == "student_updated"
        %replication with updated data through 2019
        result = csvread(strcat('S:\SHARE\cmf\Desi\Ken\project\replication code\MISPRICING_RESULTS\pair', ...
            num2str(i),'result_replicate_nooutliers.csv'));
        file_path = "replication_updated";
    elseif mode == "fleck_rep"
        % replication of Felckenstein et al 2014
        result = csvread(strcat('S:\SHARE\cmf\Desi\Ken\project\replication code\MISPRICING_RESULTS\pair', ...
            num2str(i),'result_replicate_nooutliers_FL_rep.csv'));
        file_path = "fleck_replication";
    end 
    
%     result(:,9) = winsor(result(:,9), [2,100]);

    tipsCUSIP = CUSIP(i+1,1);
    tresCUSIP = CUSIP(i+1,2);
    
    IndexC = strfind(tip(:,18),tipsCUSIP);
    IndexT = strfind(tre(:,18),tresCUSIP);
    Index  = find(not(cellfun('isempty', IndexC)));
    Indexa = find(not(cellfun('isempty', IndexT)));
    tipsNotional = tip_num(Index-1,10); % why always tip maturity, might be problematic for maturity weighting
    maturity = min( tip_num(Index-1,2), tre_num(Indexa-1,2)); 
    
    dates = union(dates,result(:,1));
    evalc(['pair' num2str(i) ' = [result(:,1), result(:,9)]']); % change to 8 for $ mp
    
    resultTable(1,(i*2)) = maturity;
    resultTable(1,(i*2)-1) = tipsNotional;
    resultTable(2:length(result(:,1))+1,(i*2)-1) = result(:,1);
    resultTable(2:length(result(:,9))+1,(i*2)) = result(:,9);
    i = i + 1;
end

%Makes the maturity buckets cutoff points (in years)
cutOffPointShort = 2;
cutOffPointLong = 5;
g = 1;

if strcmp(mode, 'fleck_rep')
    dates = dates(dates<40133);
end

while g <= length(dates)
    currentDate = dates(g);
    %Search in each arbitrage timeseries for the date
    l = 1;
    p = 1;
    constituents = zeros(0,0);
    while l <= length(CUSIP)-1 %NoOfBonds 
        evalc(['index = find(pair' num2str(l) '(:,1) == currentDate)']);
        if ~isempty(index)
            %mispricing on the day
            evalc(['constituents(p,1) = pair' num2str(l) '(index,2)']);
            %gets the outstanding amount
            constituents(p,2) = resultTable(1,(l*2)-1);
            constituents(p,3) = (resultTable(1,(l*2))-currentDate)/365;
            constituents(p,4) = l;
            p = p + 1;
        end    
        l = l + 1;
    end
     
    %defining term intervals 
        %aggregate, medium, short, and long (from paper)
    allTerm = find(constituents(:,3)); 
    mediumTerm = find(constituents(:,3)>cutOffPointShort & constituents(:,3)<=cutOffPointLong);
    shortTerm = find(constituents(:,3)<=cutOffPointShort);
    longTerm = find(constituents(:,3)>cutOffPointLong);
        %different intervals around 10 year date-to-maturity- two year, one
        %year, half year, one month
    tenyearTerm_twoyear = find(constituents(:,3)> 8 & constituents(:,3)<=12);
    tenyearTerm_year = find(constituents(:,3)> 9 & constituents(:,3)<=11);
    tenyearTerm_half = find(constituents(:,3)> 9.5 & constituents(:,3)<=10.5);
    
        %additional intervals that partition the long term bucket
    two_m_plus = find(constituents(:,3) >= 2/12);
    two_plus = find(constituents(:,3) >= 2);
    eight_plus = find(constituents(:,3)>= 8);
    ten_plus = find(constituents(:,3)>= 10);
    
    %calculating term weights
    weightsAll = constituents(allTerm,2)/sum(constituents(allTerm,2)); %all
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

    %total weights
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

    %graph data
    graphData(g,1) = currentDate;
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

    g = g + 1;
end    

% csvwrite(strcat("S:\SHARE\cmf\Desi\Ken\project\replication code\MISPRICING_GRAPHS\" ,file_path, "\graphData_bpsMP_noCPIadj_FL.csv"),graphData)

bps_mp = array2table(graphData);
bps_mp(:,5:7)=[];
bps_mp.Properties.VariableNames = {'date', 'short', 'med', 'long', 'aggregate', ...
    'bucket_8to12', 'bucket_9to11', 'bucket_10_pm_6mo', 'bucket_2plus', ...
    'bucket_8plus', 'bucket_10plus', 'bucket_2m_plus'};

bps_mp.date = datetime(bps_mp.date, 'ConvertFrom', 'excel');
bps_mp = table2timetable(bps_mp);
bps_mp_m = retime(bps_mp, 'monthly', 'lastvalue');
plot(bps_mp.date,[bps_mp.bucket_2plus])
feb = bps_mp;
load '\\rb.win.frb.org\B1\Shared\REData\SHARE\cmf\Desi\Zach\TipsMispricing\fleck_replication\data\bps_mp_by_maturity_jul2020update'
plot(feb.date(1:4161),[feb.bucket_2plus(1:4161), bps_mp.bucket_2plus])
legend('new','old')
% 

% save('S:\SHARE\cmf\Desi\Zach\TipsMispricing\fleck_replication\data\bps_mp_by_maturity_feb2021update', 'bps_mp', 'bps_mp_m');

