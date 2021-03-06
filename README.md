# TIPS-Treasury-Puzzle

```diff
- IN PROGRESS DUE TO FAILED REPLICATION
```

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

  2. Go to the Bloomberg terminal and type SRCH <GO> to bring up the Fixed Income Security Search function. Add “Ticker” as a search field and enter the ticker necessary (T for Treasury, TII for TIPS, S for STRIPS). Add “Sovereign” as another search field to ensure that all bonds returned are strictly government issued (i.e., T also points to AT&T corporate bonds without this additional field). 

  3. Change the universe of bonds to include both “Active” to and “Matured” to pull the entire history of bonds issued.

  4. Click on the results tab and then start to modify the columns shown in the results by adjusting the settings. We should be seeing the following columns (Issuer, Name, Ticker,	Cpn	Maturity,	Maturity Type,	Currency,	Country (Full Name),	First Coupon Date,	Cpn Freq Des,	Coupon Type,	ISIN,	Amt Issued,	Amt Out,	Issue Date,	Security Name,	Calc Type,	Day Count,	CUSIP,	Market Type).

  5. Repeat step 5 for each the tickers shown. We should have a separate file for TIPS, Treasury and STRIPS data, each labeled accordingly.   

**II. Pull New Price Data**

  1. Begin by copying the CUSIPS from each bond excel file (e.g. TIPS.xlsx) onto an empty excel file and concatenate each with the " Govt" string to the end of each CUSIP. These strings will be the Bloomberg IDs used to retrieve historical prices. 

  2. In the same excel file, transpose the vertical array of CUSIPS in cell `A1` and with an active Bloomberg Session, continue with the following: 
  
      1. Click on the Spreadsheet Builder from the Bloomberg tab and select the Historical Data Table.
      2. Select all securities that you have copied and transposed over from the first Sheet as the Selected Securities.
      3. Search for the Last Price field from the search box and select it, this will return the last traded price for the security.
      4. Enter the furthest date you would like to retrieve prices for, this is our start date.
      5. Select only to Show Date and Show Security from the preview screen and press the finish button.

  3. After retrieving historical prices, "Copy" the entire data series and "Paste Values" at the same location. Follow by performing a Find and Replace on `#N/A N/A` (Bloomberg parse error). This process will take a long time to complete and may cause excel to not respond in the process, depending on the number of securities queried. In future this process WILL be improved
  
  4. Finally, save each price series set for the accompanying security under the price handle. We currently use the convention "PRICES_XXX" where "XXX" is the fixed income security examined (i.e., TIPS, Treasury, STRIPS) 

**III. Pull New Inflation Swap Price Data**

  1. Update the inflation swap prices by opening the INFLATION_SWAPs.xlsx file and hitting Refresh on the Bloomberg tab. The timeseries orientation is handled by MATLAB scripts from the raw data pulls. 

**IV. Run the `main.m` script**

1.	Modify the Boolean variable  on line 20 and 21 of the `main.m` to the user specifications. Note that `inflation_adj_flag` toggles for base inflation adjustment to the cash flow series and `winsor_flag` toggles for winsorizing individual pair results to remove outliers

2. Once all data has been updated you are free to run the entire project base. You may opt to run the main.m file in a MATLAB interactive session or via terminal on your local machine or HPC cluster.
  ```
  % %    e.g., running code via batch on the FRBNY RAN HPC Cluster
  $ matlab20a-batch-withemail 10 main.m 
  ```
  
## 5	Possible Extensions
* Currently there are issues in replication due to negative synthetic bond prices (see compute_mispricing.m) 
* Work to improve the method for collecting Bloomberg price data to be more efficient, and less suceptible to hard data querying limits  

## 6	Contributors
* [Rajesh Rao](https://github.com/raj-rao-rr) (Sr. Research Analyst)
