# TIPS-Treasury-Puzzle

## 1	Introduction
We construct a mispricing series as outlined in Hanno Lustig, Matthias Fleckenstein, Francis A. Longstaff 2014 paper, entitled “The TIPS-Treasury Bond Puzzle.” We look to extend their computed series as examine its response function over time as a function of various economically significant shocks. This repository is still in progress and will be subject to change in future.

## 2	Software Dependencies
*	MATLAB 2020a with the following toolboxes (Econometrics, Optimization, Financial)
*	Bloomberg Professional Services for historical data
*	MATLAB system environment with at least 3 GB of memory

## 3	Code Structure

### 3.1 	`/Code`
All project code is stored in the `/Code` folder for generating figures and performing analysis. Refer to the headline comment string in each file for a general description of the purpose of the script in question.

* `/.../lib/` stores functions derived from academic papers or individual use to compute statistical tests or perform complex operations. Please refer to the in function documentation for each .m function for granular detail on function arguments and returns.

### 3.2 	`/Input`
Folder for all unfiltered, raw input data for financial time series.

* *INFLATION_SWAPS.xlsx* contains Bloomberg formulas to retrieve USD inflation swap data from 1y-30y maturities
* *PRICE_XXX.xlsx* contains prices data for corresponding fixed income instrument, where "XXX" refers to either STRIPS, TIPS or TREASURY
* *STRIPS.xlsx*, *TIPS.xlsx*, and *TREASURY.xlsx* store active and matured bond data for each respective fixed income instrument as per naming convention  

### 3.3 	`/Temp`
Folder for storing data files after being read and cleaned of missing/obstructed values.

* DATA.mat price series including data from FRED, monetary shocks, and U.S. GSW rates, etc
* INFADJ.mat forward and adjusted swap curves as computed from the zero-coupon inflation swaps
* MATCH.mat stores all matched series connecting TIPS, Treasuries and STRIPS for corresponding coupon windows

### 3.4 	`/Output`
Folder and sub-folders are provided to store graphs and tables for forecasts, regressions, etc.

* `/.../mispricing_results/` stores all mispricing computations for each correpsonding Treasury CUSIP, all corresponding .csv file follow the naming convention *student_adjusted_XXX.csv* where "XXX" represents the Treasury CUSIP
* `bps_mp_by_maturity.mat` stores final outputs for both aggregated and disaggregated mispricing time series 

## 4	Running Code

Data Fields that are automatically updated from HTML connections
1. Consumer Price Index for All Urban Consumers: All Items in U.S. City Average (CPIAUCNS) 

**I. Update the Bond Overview Sheets**

  1. Login into your Bloomberg Professional Service account, you will need it to retrieve historical data.

  2. Go to the Bloomberg terminal and type SRCH <GO> to bring up the Fixed Income Security Search function, add “Ticker” as a search field and enter oen of the corresponding tickers provided (**T = U.S. Treasury Note/Bond**, **TII = U.S. TIPS**, **S = U.S. STRIP**) to retrieve data for one set. 

  3. Change the universe of bonds from “Active” to “Active and Matured” to pull the entire history of bonds issued. 

  4. Click on the results tab and then start to modify the columns shown in the results by adjusting the settings. We should be seeing the following columns (Issuer, Name, Ticker,	Cpn	Maturity,	Maturity Type,	Currency,	Country (Full Name),	First Coupon Date,	Cpn Freq Des,	Coupon Type,	ISIN,	Amt Issued,	Amt Out,	Issue Date,	Security Name,	Calc Type,	Day Count,	CUSIP,	Market Type).

  5. Filter out only "US GOVERNMENT" securities from the "Market Type" column before exporting to an excel file.

  6. Repeat step 5 for each the tickers shown. We should have a seperate file for TIPS, Treasury and STRIPS data, each labeled accordingly.   

**II. Pull New Price Data**

  1. Begin by copying the CUSIPS from each excel file (e.g. TIPS.xlsx) onto an empty excel file and concat each with the " Govt" string to the end of each CUSIP. These strings will be the Bloomberg IDs used to retrieve historical prices. 

  2. In the same excel file, transpose the vertical array of CUSIPS and with an active Bloomberg Session open the Spreadsheet Builder tool to retrieve historical prices 

  3. After retrieving historical prices, "Copy" the entire dataseries and "Paste Values". Follow by performing a Find and Replace on `#N/A N/A` (Bloomberg parse error)
  
  4. Finally, save each price series set for the accompanying security under the price handle. We currently use the convention "PRICES_XXX" where "XXX" is the fixed income security examined (i.e. TIPS, Treasury, STRIPS) 

**III. Pull New Inflation Swap Price Data**

  1. Update the inflation swap prices by opening the INFLATION_SWAPs.xlsx file and hitting Refresh on the Bloomberg tab. The timeseries orientation is handled by Matlab scripts from the raw data pulls. 

**IV. Run the `main.m` script**

Once all data has been updated you are free to run the entire project base. You may opt to run the main.m file in a Matlab interactive session or via terminal on your local machine or HPC cluster.
  ```
  % %    e.g. running code via batch on the FRBNY RAN HPC Cluster
  $ matlab20a-batch-withemail 10 main.m 
  ```
  
## 5	Possible Extensions
* TBD 

## 6	Contributors
* [Rajesh Rao](https://github.com/raj-rao-rr) (Sr. Research Analyst)
