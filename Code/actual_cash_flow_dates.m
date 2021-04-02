%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code defines the actual cash-flow dates of the synthetic Treasury
% bond
%
% Last Edit: 2/26/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars -except root_dir;

%%

%Loads the link table between Treasuries and STRIPS
[~,TreasurySTRIPs]  = xlsread([data_dir, bond_excel],strip_sheet);

%Loads the overview table of all STRIPS 
[strips_num,strips] = xlsread([data_dir, bond_excel],3);

actualCashflowDates = zeros(0,0);
i = 1;
while i <= length(TreasurySTRIPs(1,:))
    h = 1;
    IndexS = strfind(TreasurySTRIPs(:,i),']');
    Indexs = find(not(cellfun('isempty', IndexS)));
    filledindexes = setdiff(1:length(TreasurySTRIPs(:,i)),Indexs);
    currenttretostrip = TreasurySTRIPs(filledindexes,i);
    emptyCells = cellfun(@isempty,currenttretostrip);
    currenttretostrip(emptyCells) = [];
    while h <= length(currenttretostrip(2:end,1))
        currentStrip = currenttretostrip(h+1,1);
        % added another apostrophe as excel has 'NO DATA'' 
        if strcmp(currentStrip,{'NO DATA'''}) 
            actualCashflowDates(h,i) = 1;
        elseif strcmp(currentStrip,{'NO DATA'}) 
            actualCashflowDates(h,i) = 1;
        else
            IndexC = strfind(strips(:,9),currentStrip);
            Index = find(not(cellfun('isempty', IndexC)));
            % finds maturity date for strips
            actualCashflowDates(h,i) = strips_num(Index-1,2);
        end    
        h = h + 1;
    end
    i = i + 1;
end


% FOR EACH TREASURY BOND, actualCashflowDates LISTS THE MATURITY DATES OF
% ALL STRIPS MATCHED TO ITS COUPON DATES, and TreasurySTRIPs LISTS STRIPS
% CUSIPS THEMSELVES



 









