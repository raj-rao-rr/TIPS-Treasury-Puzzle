% This code calculates and applies the seasonal adjustments to the zero-coupon 
% inflation swap qoutes and performs the cubic spline interpolation

clearvars -except root_dir inflation_adj_flag winsor_flag;

% Import the Zero Coupon Inflation Swaps and CPI Data Tables
load DATA SWAPS CPI 

fprintf('\n6) Fitting the seasonally adjusted zero-coupon inflation swap curve\n'); 


%% compute the inflation seasonality factors

% compute log changes for CPI retrieved from FRED website
log_changes = log(CPI{2:end, 'CPIAUCNS'}) - log(CPI{1:end-1, 'CPIAUCNS'});

m = month(CPI.DATE(2:end));              % extracts month for season inflation
d = dummyvar(m);                  % converts interval to dummy variables

% regress CPI log changes to month dummy variables (seasonality)
% NOTE: The regression returns [coefficients, 95% confidence intervals, residuals, 
%       outlier index, statistics(R-squared, F-statistics, p-value)]

[b,~,~,~,~] = regress(log_changes, d);      
coef_mean = mean(b);                        % compute the average seasonal beta
seasonal_factor = b - coef_mean;            % adjust beta-coef by seasonal avg.

% multiplicative factors and normalization (12-month seasonality)
mult_fact = seasonal_factor + 1; 

%% cubic spline interpolation of zero-coupon inflation swap curves

% strip the numeric component of column and convert to matrix
x = cellfun(@(x) str2double(x(5:end-1)), SWAPS.Properties.VariableNames, ...
    'UniformOutput', false);
x = cell2mat(x);

increment = 1/12;           
xx = 0:increment:30;   

% initialize the memory for the interpolated swap points
interpolated_pts = zeros(size(SWAPS, 1), length(xx));  

% iterate through each of the corresponding rates
for k = 1:size(SWAPS, 1)
    
    y = SWAPS{k, :};                              % zero-coupon inflation swap

    try
        yy = spline(x, y, xx);                    % perform the cubic spline
        interpolated_pts(k, :) = yy;              % assign open row to spline
    catch exception
        interpolated_pts(k, :) = interpolated_pts(k, :) * NaN; 
    end
    
end

%% create the forward rates from interpolated swap points

% index where the 1-yr inflation swap starts (checks the first row)
one_year_mrk = find(xx == 1);   
[N, M] = size(interpolated_pts);                 

% initialize forward swap container
forward_swap = zeros(N, M); 

for row = 1:N
    
    % assign the zero-coupon inflation swaps with maturity 1-year and under  
    forward_swap(row, 1:one_year_mrk) = interpolated_pts(row, 1:one_year_mrk) / 100;

    % assign all maturities over 1-year to the computed forward rate
    % NOTE: refer. Claus Munk, "Financial Markets and Investments", p. 171.
    m = 2:(M-one_year_mrk+1);
    num = (1 + (interpolated_pts(row, one_year_mrk+1:end) / 100)) .^ (m);             % numerator expression 
    den = (1 + (interpolated_pts(row, one_year_mrk:end-1) / 100)) .^ (m-1);           % denominator expression
    
    % assign the forward rate computation for all points post 1-yr inflation swap 
    forward_swap(row, one_year_mrk+1:end) = (num ./ den) - 1;                                
    
end

%% applies the seasonal multiplicative factor to forwards

% initialize the adjusted forward swap container 
adj_forward_swap = forward_swap(:, 2:end);          % zero-year tenor ignored  

for row = 1:size(adj_forward_swap, 1)
    
    % iterate through the tenors of the inflation curve
    for n = 1:29

        look_back = n * 12 + 1;             % n * 12 to view current year, + 1 to 
                                            %   start at year start
        look_forward = (n + 1) * 12;        % (n + 1) * 12 to view the next year, 

        % apply multiplicative adjustment to forward rates
        adjustment = forward_swap(row, look_back:look_forward) .* mult_fact'; 

        % assign each seasonal adjusted rate to the corresponding column
        adj_forward_swap(row, look_back:look_forward) = adjustment;

    end
    
end

%% transforms the forward rates back into spot rates

% initialize the adjusted swap curve (our sub-1yr columns are a direct match)
adj_swap_curve = adj_forward_swap;

for row = 1:size(adj_swap_curve, 1)
    
    % for all columns less than or equal to 1-yr in maturity, we assign
    adj_swap_curve(row, 1:12) = adj_forward_swap(row, 1:12);
    
    for h = 13:size(adj_swap_curve, 2)
        % Formula taken from Claus Munk, "Financial Markets and Investments", p. 171.
        adj_swap_curve(row, h) = prod(adj_forward_swap(row, 12:h) + 1) ^ (1/h) - 1;
    end
    
end

%% reporting relevant database for inflation swap curve

% convert cell matrix to table and recast the table rows
interval = num2cell(0:1/12:30);
interval = cellfun(@(x) round(x, 2) + "y", interval);

interpolated_pts = array2table(interpolated_pts, 'VariableNames', interval);
interpolated_pts.Date = SWAPS.Date;
interpolated_pts = movevars(interpolated_pts, 'Date', 'Before', '0y');
interpolated_pts = table2timetable(interpolated_pts); 

forward_swap = array2table(forward_swap, 'VariableNames', interval);
forward_swap.Date = SWAPS.Date;
forward_swap = movevars(forward_swap, 'Date', 'Before', '0y');
forward_swap = table2timetable(forward_swap); 

adj_forward_swap = array2table(adj_forward_swap, 'VariableNames', interval(2:end));
adj_forward_swap.Date = SWAPS.Date;
adj_forward_swap = movevars(adj_forward_swap, 'Date', 'Before', '0.08y');
adj_forward_swap = table2timetable(adj_forward_swap); 

adj_swap_curve = array2table(adj_swap_curve, 'VariableNames', interval(2:end));
adj_swap_curve.Date = SWAPS.Date;
adj_swap_curve = movevars(adj_swap_curve, 'Date', 'Before', '0.08y');
adj_swap_curve = table2timetable(adj_swap_curve); 

% save contents of table to temporary file
save('Temp/INFADJ', 'interpolated_pts', 'forward_swap', 'adj_forward_swap', ...
    'adj_swap_curve')
