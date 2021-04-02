%student_old for original tips-trea pairs from paper, student_updated to include 
% updated data through 2019
%Note that some files such as graphmispricingMaturity.m accept 
% mode == "student_og" (see README.m for details). The difference between 
% og and old is that og uses the student's original data while old uses
% data derived by ourselves. Both still operates under the original 57
% tips-trea pairs used in the paper. 


%% select mode to run

% mode = "fleck_rep";
% mode = "student_old";
% mode = "student_updated";
% mode = 'jul2020_update';
mode = 'feb2021_update';

%% set paths and settings to run each step

if strcmp(mode,'student_updated') 
    data_dir    = 'S:\SHARE\cmf\Desi\Ken\project\new_data_pull\';
    bond_excel  = 'BONDS\US_numberversion_corrected_TIPSsortedbymaturity.xlsx';
    cf_sheet    = 5;
    acf_sheet   = 7;
    strip_sheet = 6;
elseif strcmp(mode,'fleck_rep')
    data_dir    = 'S:\SHARE\cmf\Desi\Ken\project\new_data_pull\';
    bond_excel  = 'BONDS\US_numberversion_corrected_TIPSsortedbymaturity.xlsx';
    cf_sheet    = 9;
    acf_sheet   = 11;
    strip_sheet = 10;
elseif strcmp(mode,'student_old')
    data_dir    = 'S:\SHARE\cmf\Desi\Ken\project\Data\';
    bond_excel  = 'BONDS\US_numberversion_corrected_TIPSsortedbymaturity.xlsx';
    cf_sheet    = 9;
    acf_sheet   = 13;
    strip_sheet = 12;
elseif strcmp(mode,'feb2021_update')
    data_dir    = 'S:\SHARE\cmf\Desi\Ken\project\feb2021update\';
    bond_excel  = 'BONDS\US_bonds_feb2021.xlsx';
    cf_sheet    = 5;
    acf_sheet   = 7;
    strip_sheet = 6;
end

%% Match TIPS and Treasury Issues

matchtipstreasuries

% write results to US excel file sheet 4
names = {'TIPS','TREASURY'};
xlswrite([data_dir, bond_excel], matches, 4,'A2');
xlswrite([data_dir, bond_excel], names  , 4,'A1');

clearvars -except mode data_dir bond_excel cf_sheet acf_sheet strip_sheet
clc

%% Calculate coupon payment dates for Treasury Issues

cashflowdates

% write results to US excel file
xlswrite([data_dir, bond_excel], placeholder_real, cf_sheet,'A1');
xlswrite([data_dir, bond_excel], trea            , cf_sheet,'A1');

clearvars -except mode data_dir bond_excel cf_sheet acf_sheet strip_sheet
clc

%% Match STRIPS issues to Treasury coupon payments

matchstripstreasury
%write results to US excel file sheet 6

xlswrite([data_dir, bond_excel],results,strip_sheet,'A1')

clearvars -except mode data_dir bond_excel cf_sheet acf_sheet strip_sheet
clc

%% Calculate coupon payment dates of Synthetic Treasury bond

actualcashflowdates

%write results to US excel file
xlswrite([data_dir bond_excel],TreasurySTRIPs(1,:),acf_sheet,'A1');
xlswrite([data_dir bond_excel],actualCashflowDates,acf_sheet,'A2');

clearvars -except mode data_dir bond_excel cf_sheet acf_sheet strip_sheet
clc 

%% Fit ZCIS Curve from Market Data

inflationseasonaladjust

% write results to a new file AdjustedSwapcurve located in Export
if strcmp(mode, "student_old") 
    csvwrite([data_dir 'Export\AdjustedSwapcurve_ACTUAL_REVERSED.csv'], ...
              AdjustedSwapcurve_withmonths)
else
    csvwrite([data_dir 'Export\AdjustedSwapcurve.csv'], ...
              AdjustedSwapcurve_withmonths);
end 

clearvars -except mode data_dir bond_excel cf_sheet acf_sheet strip_sheet
clc

%% Calculate the mispricing between Actual and Synthetic Treasuries

BACKTESTREVISED2 % new name compute mispricing 

%% Aggregate Mispricing (in basis points) by various maturity buckets

gen_bps_mp_new


