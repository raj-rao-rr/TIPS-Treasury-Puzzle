% Reads in data files and stores these variables to a .mat file 

clearvars -except root_dir;

% creating certificate for web access, extending timeout to 10 seconds 
o = weboptions('CertificateFilename',"", 'Timeout', 15);

% sets current date time to retrieve current information
currentDate = string(datetime('today', 'Format','yyyy-MM-dd'));

%% Consumer Price Index for All Urban Consumers, taken from FRED

url = 'https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=CPIAUCNS&scale=left&cosd=1913-01-01&coed=' + currentDate + '&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Monthly&fam=avg&fgst=lin&fgsnd=' + currentDate + '&line_index=1&transformation=lin&vintage_date=' + currentDate + '&revision_date=' + currentDate + '&nd=1913-01-01';

% read web data from FRED and stores it in appropriate file 
CPI = webread(url, o);
CPI = rmmissing(CPI);

%% History of Fixed Income Prices (TIPS, Treasury, STRIPS)

PRICE_T = readtable('PRICE_TREASURY.xlsx', 'PreserveVariableNames', true);

PRICE_TILL = readtable('PRICE_TIPS.xlsx', 'PreserveVariableNames', true);

PRICE_S = readtable('PRICE_STRIPS.xlsx', 'PreserveVariableNames', true);

%% History of Fixed Income Issuance (TIPS, Treasury, STRIPS)

TREASURYS = readtable('TREASURY.xlsx', 'PreserveVariableNames', true);

% fix the datetime arrays with Treasury issuances
TREASURYS.Maturity = cellfun(@datetime, TREASURYS{:,'Maturity'});
TREASURYS.First_Coupon_Date = datetime(TREASURYS{:, 'First Coupon Date'});
TREASURYS.Issue_Date = datetime(TREASURYS{:, 'Issue Date'});

TIPS = readtable('TIPS.xlsx', 'PreserveVariableNames', true);

% fix the datetime arrays with TIPS issuances
TIPS.Maturity = datetime(TIPS{:,'Maturity'});
TIPS.First_Coupon_Date = datetime(TIPS{:, 'First Coupon Date'});
TIPS.Issue_Date = datetime(TIPS{:, 'Issue Date'});

STRIPS = readtable('STRIPS.xlsx', 'PreserveVariableNames', true);

% fix the datetime arrays with TIPS issuances
STRIPS.Maturity = datetime(STRIPS{:,'Maturity'});
STRIPS.Issue_Date = datetime(STRIPS{:, 'Issue Date'});

% filter out columns that aren't reported for STRIPS
STRIPS = STRIPS(:, ~ismember(STRIPS.Properties.VariableNames, ...
    {'First Coupon Date', 'Cpn Freq Des', 'Amt Issued'}));

%% Inflation Swaps Data, taken from Bloomberg

InfSwap = readtable('INFLATION_SWAPS.xlsx', 'PreserveVariableNames', true);

% select each corresponding inflation swap term by column
swap1y = InfSwap(:, 1:2); 
swap1y.Properties.VariableNames = {'Date', 'Swap1y'};

swap2y = InfSwap(:, 3:4); 
swap2y.Properties.VariableNames = {'Date', 'Swap2y'};

swap3y = InfSwap(:, 5:6); 
swap3y.Properties.VariableNames = {'Date', 'Swap3y'};

swap4y = InfSwap(:, 7:8); 
swap4y.Properties.VariableNames = {'Date', 'Swap4y'};

swap5y = InfSwap(:, 9:10); 
swap5y.Properties.VariableNames = {'Date', 'Swap5y'};

swap6y = InfSwap(:, 11:12); 
swap6y.Properties.VariableNames = {'Date', 'Swap6y'};

swap7y = InfSwap(:, 13:14); 
swap7y.Properties.VariableNames = {'Date', 'Swap7y'};

swap8y = InfSwap(:, 15:16); 
swap8y.Properties.VariableNames = {'Date', 'Swap8y'};

swap9y = InfSwap(:, 17:18); 
swap9y.Properties.VariableNames = {'Date', 'Swap9y'};

swap10y = InfSwap(:, 19:20); 
swap10y.Properties.VariableNames = {'Date', 'Swap10y'};

swap12y = InfSwap(:, 21:22); 
swap12y.Properties.VariableNames = {'Date', 'Swap12y'};

swap15y = InfSwap(:, 23:24); 
swap15y.Properties.VariableNames = {'Date', 'Swap15y'};

swap20y = InfSwap(:, 25:26); 
swap20y.Properties.VariableNames = {'Date', 'Swap20y'};

swap30y = InfSwap(:, 27:28); 
swap30y.Properties.VariableNames = {'Date', 'Swap30y'};

% perform inner join on all seperate inflation swap data
% NOTE MATLAB 2020b has no easy join beyond 2, requiring itterative join
col_order = {swap30y,swap20y, swap15y, swap12y, swap10y, swap9y, ...
    swap8y, swap7y, swap6y, swap5y, swap4y, swap3y, swap2y, swap1y};
SWAPS = col_order{1};

for k = 2:length(col_order)
   SWAPS = innerjoin(col_order{k}, SWAPS); 
end

%% Save all variables in *.mat file to be referenced

save('Temp/DATA', 'CPI', 'SWAPS', 'TREASURYS', 'STRIPS', 'TIPS', 'PRICE_T', ...
    'PRICE_TILL', 'PRICE_S')

fprintf('Data has been downloaded and processed.\n'); 
