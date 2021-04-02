%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code calculates and applies the seasonal adjustments to the
% zero-coupon inflation swap qoutes and performs the cubic spline
% interpolation
%
% Last Edit: 2/26/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars -except root_dir;

%%

% Loads the zero-coupon inflation swap quotes 
if strcmp(mode, 'student_old')
    [num,str] = xlsread([data_dir '\INFLATION SWAP CURVES\DATA\ZC INFLATION SWAP CURVES_numberversion_REVERSED'],1);
else
    [num,str] = xlsread([data_dir 'INFLATION SWAP CURVES\ZC INFLATION SWAP CURVES.xlsx'],1); 
end
% Loads the non-seasonal adjusted index values
[cpi] = xlsread([data_dir 'CPI INDEX\CPIAUCNS.xls'],1);

rates = num;
rates(1,1) = 0;

logchanges = log(cpi(2:end,2)./cpi(1:end-1,2));
m = month(x2mdate(cpi(1:end-1,1),0));
d = dummyvar(m);

%regression
[b] = regress(logchanges,d);
bMean=mean(b);
seasonalFac=b-bMean;

%Multiplicative factors and Normalization
MultFact = seasonalFac+1; 

%Cubic spline interpolation of zero-coupon inflation swap curves
x = rates(1,2:end);
month = 1/12;
xx = 0:month:30;
k = 1;
j = 1;
interpolatedSwapPoints = [0,xx];
baddates = zeros(0,0);
while k <= length(rates(2:end,1))
    y = rates(k+1,2:end);
    date = rates(k+1,1);
        try
        yy = spline(x,y,xx);
        interpolatedSwapPoints = [interpolatedSwapPoints;[date, yy]];
        catch exception
        baddates(j,1) = date;
        j = j + 1;
        end
    k = k + 1;
end

%Creates the forward rates
l = 1; 
m = 1;
forwardSwap = zeros(0,0);
while l <= length(interpolatedSwapPoints(2:end,1)) % downwards, # of curves

    while m <= length(interpolatedSwapPoints(1,14:end)) %along the curve
        if m == 1 %the 1 year forward is just the spot
            forwardSwap(l,m:13) = interpolatedSwapPoints(l+1,2:14)/100;
            m = m + 1;
        else
        forwardSwap(l,m+12) = ((1+(interpolatedSwapPoints(l+1,m+13)/100))^(m) / ...
            (1+(interpolatedSwapPoints(l+1,m+12)/100))^(m-1))-1;
        %Formula taken from Claus Munk, "Financial Markets and Investments", p. 171.
        m = m + 1;
        end
    end
    l = l + 1;
    m = 1;
end

%Applies the seasonal multiplicative factor
n = 1;
i = 1;
adjustedForward = zeros(0,0);
while n <= 29 %number of years on the curve 
    while i <= length(forwardSwap(:,1))
        result = (forwardSwap(i,(((n-1)*12)+1)+12:(n*12)+12)).*MultFact'; 
        adjustedForward(i,(((n-1)*12)+1):n*12) = result;  
        i = i + 1; 
    end
    i = 1;
    n = n + 1;
end

adjustedForward = [forwardSwap(:,2:13), adjustedForward]; %the zero year tenor is ignored

%Transforms the forward rates back into spot rates
h = 1;
f = 1;
AdjustedSwapcurve = zeros(0,0);
while f <= length(adjustedForward(:,1)) %downwards, # of curves
    while h <= length(adjustedForward(1,13:end)) % a long each curve
        if h == 1
            AdjustedSwapcurve(f,1:13) = adjustedForward(f,1:13);
            h = h + 1;
        else
            AdjustedSwapcurve(f,h+12) = prod(adjustedForward(f,13:h+12)+1)^(1/h)-1;
            
            %(((interpolatedSwapPoints(f+1,2)/100)+1)*prod(adjustedForward(f,1:h)+1))^(1/(h+1))-1;
            %Formula taken from Claus Munk, "Financial Markets and Investments", p. 171.
            h = h + 1; 
        end
    end
    h = 1;
    f = f + 1;
end

dates = num(2:end,1);
AdjustedSwapcurve_withdates = [dates, AdjustedSwapcurve];
months = 0:1/12:30;
AdjustedSwapcurve_withmonths = vertcat(months, AdjustedSwapcurve_withdates);








