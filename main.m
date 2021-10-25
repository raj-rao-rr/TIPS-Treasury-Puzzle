% Primary executable file (run all file)

clear; clc;

%% set the primary directory to work in  
root_dir = pwd;

% enter the root directory 
cd(root_dir)            

%% add paths to acess files 
addpath([root_dir filesep 'Code'])    
addpath([root_dir filesep 'Code' filesep 'lib'])  
addpath([root_dir filesep 'Input'])
addpath([root_dir filesep 'Temp'])
addpath([root_dir filesep 'Output'])  

%% user option specifications (model settings)

inflation_adj_flag = false;       % toggle for base inflation adjustment
winsor_flag        = false;       % toggle for winsorizing individual pair results  

%% running project scripts in synchronous order 
% run('data_reader.m')                   % Reads in updated bond and swap data
% run('match_tips_treasury.m')           % Match TIPS and Treasury Issues
% run('cash_flow_dates.m')               % Calculate coupon payment dates for UST 
% run('match_strips_treasury.m')         % Match STRIPS issues to Treasury coupon 
% run('actual_cash_flow_dates.m')        % Calculate coupon payment for Synthetic  
% run('inflation_seasonal_adjust.m')     % Fit ZCIS Curve from Market Data
% run('compute_mispricing.m')            % Calculate the mispricing 
% run('gen_bps_mp_new.m')                % Aggregate Mispricing (in basis points) 
