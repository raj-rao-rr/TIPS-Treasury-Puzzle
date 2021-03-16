% Primary executable file (run all file)

clear; clc;

%% set the primary directory to work in  
root_dir = pwd;

% enter the root directory 
cd(root_dir)            

%% add paths to acess files
addpath([root_dir filesep 'Code'])                                    
addpath([root_dir filesep 'Input'])
addpath([root_dir filesep 'Temp'])
addpath([root_dir filesep 'Output'])  
 
%% running project scripts in synchronous order 
% run('match_tips_treasuries.m')                                              % Match TIPS and Treasury Issues
% run('cash_flow_dates.m')                                                    % Calculate coupon payment dates for Treasury 
% run('match_strips_treasury.m')                                              % Match STRIPS issues to Treasury coupon payments
% run('actual_cash_flow_dates.m')                                             % Calculate coupon payment for Synthetic Treasury 
% run('inflation_seasonal_adjust.m')                                          % Fit ZCIS Curve from Market Data
% run('compute_mispricing.m')                                                 % Calculate the mispricing 
% run('gen_bps_mp_new.m')                                                     % Aggregate Mispricing (in basis points) 
