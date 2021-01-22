# Branding-process

This process is for categorising data (brands) based on an existing list of brands and their search strings. 

<b>query_strings.py</b>
  For each delta file in an S3 bucket, the python script will download the file and call the Sql function to import the data and start the branding process.
  
<b>wloaddelta.sql</b>
  Creates the table, imports and creates necessary indexes. Calls the branding process - then exports the results.

<b>brand_match_exper.sql</b>
  This branding process takes a large list of brands and searches the delta table for these brands. It searches in multiple columns, can return cases of multiple matches - and can accept additional sql input.
  
<b>Input brands</b>
<table class="tableizer-table">
<thead><tr class="tableizer-firstrow"><th>brand</th><th>search string</th><th>additional sql</th></tr></thead><tbody>
 <tr><td>TESCO</td><td>\mTESCO\M%</td><td>&nbsp;</td></tr>
 <tr><td>RAPHAELS BANK</td><td>RAPHAELS BANK</td><td>AND SIC8_DESCRIPTION LIKE '%BANK%' AND NOT SIC8_DESCRIPTION LIKE '%ATM%'</td></tr>
 <tr><td>EE</td><td>T-MOBILE</td><td>&nbsp;</td></tr>
 <tr><td>ABBEYFIELD</td><td>ABBEYFIELD % </td><td>&nbsp;</td></tr>
 <tr><td>BARCLAYS BANK</td><td>BARCLAYS PLC%</td><td>AND SIC8_DESCRIPTION LIKE '%BANK%' AND NOT SIC8_DESCRIPTION LIKE '%ATM%'</td></tr>
 <tr><td>WHSMITH</td><td>W_?H_?SMITH%</td><td></td></tr>
</tbody></table>

<b>Results example</b>
<table class="tableizer-table">
<thead><tr class="tableizer-firstrow"><th>name</th><th>trade_name</th><th>franchise_name</th><th>sic8_description</th><th>brandname</th><th>new_brand</th><th>multiple_brands</th><th>matches</th></tr></thead><tbody>
 <tr><td>EXXONMOBIL POWER AND GASE SERVICES INC.</td><td>&nbsp;</td><td>&nbsp;</td><td>GAS AND OTHER SERVICES COMBINED</td><td>EXXON MOBIL</td><td>1</td><td>;EXXON MOBIL</td><td>1</td></tr>
 <tr><td>GODDARD DAIRY QUEEN</td><td>&nbsp;</td><td>&nbsp;</td><td>ICE CREAM STANDS OR DAIRY BARS</td><td>DAIRY QUEEN</td><td>1</td><td>;DAIRY QUEEN</td><td>1</td></tr>
 <tr><td>DAIRY QUEEN</td><td>&nbsp;</td><td>DAIRY QUEEN</td><td>ICE CREAM STANDS OR DAIRY BARS</td><td>DAIRY QUEEN</td><td>1</td><td>;DAIRY QUEEN</td><td>2</td></tr>
 <tr><td>COURTYARD BY MARRIOTT CARROLLTON</td><td>COURTYARD CARROLLTON</td><td>COURTYARD BY MARRIOTT</td><td>HOTELS</td><td>COURTYARD BY MARRIOTT</td><td>1</td><td>;COURTYARD BY MARRIOTT;MARRIOTT</td><td>2</td></tr>
 <tr><td>COURTYARD BY MARRIOTT DELRAY BEACH</td><td>&nbsp;</td><td>COURTYARD BY MARRIOTT</td><td>HOTELS AND MOTELS</td><td>COURTYARD BY MARRIOTT</td><td>1</td><td>;COURTYARD BY MARRIOTT;MARRIOTT</td><td>2</td></tr>
</tbody></table>
