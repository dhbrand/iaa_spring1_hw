data smoking;
input   agecat     smokes     deaths     pyears;
lpyears = log(pyears); 
cards; 
        1          1         32     52407
        2          1        104     43248
        3          1        206     28612
        4          1        186     12663
        5          1        102      5317
        1          0          2     18790
        2          0         12     10673
        3          0         28      5710
        4          0         28      2585
        5          0         31      1462
;



*Do a proc genmod on a smoking dataset
*Estimate the relative rate of death  
*for non-smokers vs smokers*
;
