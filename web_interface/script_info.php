<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><!-- InstanceBegin template="/Templates/amet3.dwt" codeOutsideHTMLIsLocked="false" -->
<HEAD>
<!-- #BeginEditable "doctitle" --> 
<TITLE>Atmospheric Model Evaluation Tool</TITLE>
<style type="text/css">
<!--
.style3 {color: #FF0000}
-->
</style>
<style type="text/css">
<!--
.style4 {font-size: large}
-->
</style>
<style type="text/css">
<!--
.style5 {font-size: medium}
-->
</style>
<style type="text/css">
<!--
.style7 {font-family: Arial, Helvetica, sans-serif}
-->
</style>
<style type="text/css">
<!--
.style8 {font-size: 13px}
-->
</style>
t
<style type="text/css">
<!--
.style9 {font-size: 16px}
-->
</style>
<!-- #EndEditable --> 
<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<LINK rel="stylesheet" href="general.css" type="text/css">
<style type="text/css">
<!--
@import url("generalie.css");
.style1 {font-family: Broadway, "Brush Script"}
-->
</style>
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
  eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
  if (restore) selObj.selectedIndex=0;
}//-->
</script>
</HEAD>
<BODY bgcolor="#000000" text="#000000">
<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
  <TR> 
    <TD background="images/images_03.jpg" valign="TOP"> <TABLE border="0" cellspacing="0" cellpadding="0" width="647">
        <TR> 
          <TD width="594" height="53" background="images/header_02.jpg" class="companyname">&nbsp;</TD>
          <TD background="images/images_03.jpg" width="53"><IMG src="images/images_03.jpg" alt="" name="spacer" width="53" height="53" id="spacer"></TD>
        </TR>
      </TABLE></TD>
  </TR>
  <TR> 
    <TD valign="TOP"> <TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
        <TR> 
          <TD valign="top" bgcolor="#FFFFFF">&nbsp; </TD>
          <TD valign="top" bgcolor="#FFFFFF"> <table width="717" border="0" cellspacing="2" cellpadding="5">
              <tr> 
                <td width="703" valign="TOP"><!-- InstanceBeginEditable name="Text" --> 
                 <h1 class="generic">Descriptions of Available R Scripts </h1>
                  <p><a href="#SpecieStatsandPlots">Species Statistics and Plots</a><br>
                    <a href="#scatterplot">Model/Ob Scatterplot</a><br>
                    <a href="#scatterplot_mtom">Model/Model Scatterplot</a><br>
                    <a href="#four_panel">4-Panel Model/Ob Scatterplot</a><br>
                    <a href="#soccergoal">&quot;Soccergoal&quot; Plot</a><br>
                    <a href="#bugleplot">&quot;Bugle&quot; Plot</a><br>
                    <a href="#timeseries">Time-Series Plot </a><br>
                    <a href="#spatialplot">Model/Ob Spatial Plot</a><br>
                    <a href="#monthlyboxplot">Monthly Boxplot</a><br>
                    <a href="#diurnalboxplot">Hourly Boxplot</a><br>
                    <a href="#stackedbar">PM2.5 Stacked Bar Plot</a><br>
                    <a href="#paveoverlay">Create PAVE Obs Overlay File</a> </p>
                  <p>&nbsp;</p>
                  <p><u><strong><span class="style2"><a name="SpecieStatsandPlots"></a></span></strong></u><strong><span class="style2"><span class="style3">Species Statistics and Plots</span></span></strong></p>
                  <p>This script creates two comma separated files (.csv) that can be viewed as text or imported to various spreadsheet programs, such as Excel. The script also creates several spatial plots, specially Normalized Mean Bias (NMB), Normalized Mean Error (NME), Fractional Bias (FB), Fractional Error (FE) and Root Mean Square Error (RMSE). These plots are provided in two formats, PNG and PDF. The PNG format is similar to GIF and JPG format and is recommended for web viewing.</p>
                  <p><u>INPUTS</u>: The script should be provided with a species to analyze (e.g. SO4), a set of up to three networks (e.g. STN, IMPROVE and CASTNet) and a time period in which to analyze. The script can only process one species at a time, but can process the same species for several networks. The user should attempt to choose networks for which the desired species is observed. Failure to do so could result in an error. </p>
                  <p><u>OUTPUTS</u>: Two .csv files are provided, one containing the domain wide statistics and another containing the individual site statistics. Five PNG (and corresponding PDF) images are produced. The statistics and plots will be separated by network, with a legend provided on the plot to identify the different network sites. </p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>: Not choosing any networks or a species. Choosing a species for a network for which the desired species is not available. Setting a time period which results in an empty query. Setting a georgraphical area in which there are no sites for the specified network. </p>
                  <p>&nbsp;</p>
                  <p><u><strong><span class="style2"><a name="scatterplot"></a></span></strong></u><strong><span class="style2"><span class="style3">Model/Ob Scatterplot:</span></span></strong> </p>
                  <p>This script creates a scatterplot of model and observation values. A single image is produced, in both PNG and PDF formats. Several selected statistics are included on the scatterplot. These are NMB, NME and RMSE. </p>
                  <p><u>INPUTS</u>: The script should be provided a single species to analyze, up to three networks to include and a time period in which to analyze. The script can only process one species at a time. The user can also choose which confidence lines to include on the plot (Scatter Plot Confidence Lines) using the check boxes. The 30% confidence lines are checked by default. The user can only choose to average the individual observations into monthly average values using the Temporal Averaging drop down box. The user can also specify the x and y axes limits using the AMET PLots Axis Options box. Simply fill in a number for the desired x and y limits on the scatter plot. This is particularly useful when trying to compare scatter plots that normally result in axes of different maximum values. </p>
                  <p><u>OUTPUTS</u>: The script will output a single PNG (and corresponding PDF) image for the desired scatter plot. Observations are plotted on the x-axis and model values are plotted on the y-axis. Statistics are including in the lower right corner of the plot, along with some other information regarding the plot.</p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>: Not choosing any networks or a species. Choosing a species for a network for which the desired species is not available. Setting a time period which results in an empty query. Setting a georgraphical area in which there are no sites for the specified network. </p>
                  <p>&nbsp;</p>
                  <p><strong><span class="style2"><span class="style3"><a name="scatterplot_mtom"></a>Model to Model Scatterplot:</span></span></strong> </p>
                  <p>This script is similar to the model/ob scatter plot except that instead of observations being plotted against model values, model values are plotted against other model values. This is useful for comparing the difference between two model runs. The model values only correspond to those at the sites for the network(s) chosen, and does not plot all the grid cell values for the entire domain modeled. A single image is produced, in both PNG and PDF formats. Several selected statistics are included on the scatterplot. These are Bias, Error and Correlation. </p>
                  <p><u>INPUTS</u>: The user must specify two model runs to use, the main model run and a secondary model run from another drop down list. A species must be specified, along with a network(s) to plot (although observations are not plotted). A time period must also be specified. The plot options the user can specify are the same as those with the model/ob scatter plot. </p>
                  <p><u>OUTPUTS</u>: The script will output a single PNG (and corresponding PDF) image for the desired scatter plot. Statistics are including in the lower right corner of the plot, along with some other information regarding the plot. </p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>: Not choosing any networks or a species. Choosing a species for a network for which the desired species is not available. Setting a time period which results in an empty query. Setting a georgraphical area in which there are no sites for the specified network. Choosing two model runs in which the time periods modeled are not the same (there must be at least some overlap between the two modeling time periods). </p>
                  <p>&nbsp;</p>
                  <p><strong><span class="style2"><span class="style3"><a name="four_panel"></a>4-Panel Model/Ob Scatterplot:</span></span></strong> </p>
                  <p>This script is similar to the model/ob scatter plot except that instead of observations being plotted against model values, model values are plotted against other model values. This is useful for comparing the difference between two model runs. The model values only correspond to those at the sites for the network(s) chosen, and does not plot all the grid cell values for the entire domain modeled. A single image is produced, in both PNG and PDF formats. Several selected statistics are included on the scatterplot. These are Bias, Error and Correlation. </p>
                  <p><u>INPUTS</u>: </p>
                  <p><u>OUTPUTS</u>: </p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>: </p>
                  <p>&nbsp;</p>
                  <p><strong><span class="style2"><span class="style3"><a name="soccergoal"></a>&quot;Soccergoal&quot; Plot:</span></span></strong> </p>
                  <p>This script plots bias (NMB or FB) on the x-axis and error (NME or FE) on the y-axis. Since the bias and error are plotted as percentages, any number of networks and species can be plotted on a single plot. Along with the bias and error, &quot;goal&quot; lines are included for both bias and error. These goal lines form a &quot;soccergoal&quot; for which model performance is targeted. </p>
                  <p><u>INPUTS</u>: The user can choose any number of networks to be plotted. If a species is specified, only that species will be plotted for the choosen networks. The species must be available for all the networks choosen or the program will return an error. If no species is specified, all available species for the networks choosen will be plotted. A time period to analyze must be specified. The user can also choose weather to plot NMB and NME,  FB and FE or NMdnB and NMdnE as percentages using the drop down box.</p>
                  <p><u>OUTPUTS</u>: The script produces a PNG (and corresponding PDF) images. Each network is color coded and each species is given a different symbol so that individual species and networks can be identified. </p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>: Not choosing any networks or a species. Choosing a species for a network for which the desired species is not available (based on first network chosen in the network check list). Setting a time period which results in an empty query. Setting a georgraphical area in which there are no sites for the specified network. </p>
                  <p><strong>REFERENCE:</strong> Boylan, J.W., Russell, A.G., 2006. PM and light extinction model performance metrics, goals, and criteria for three-dimensional air quality models. Atmospheric Environment 40 (26), 4946-4959.</p>
                  <p>&nbsp;</p>
                  <p><strong><span class="style2"><span class="style3"><a name="bugleplot"></a>&quot;Bugle&quot; Plot:</span></span></strong> </p>
                  <p>This script plots bias and error as functions of the average concentration. Bias and error are plotted on separate plots. Also plotted are criteria and goal lines for model performance, which when plotted form the shape of a bugle. The concept behind this type of plot is that model performance goals should vary depending on the concentration of the species. Therefore, as the average concentration of the species decreases, the criteria and goal lines for bias and error increase, allowing for greater acceptable levels of bias and error at lower concentrations. </p>
                  <p><u>INPUTS</u>: The user can choose any number of networks to be plotted. A species must be specified. A time period to analyze must be specified. The user can also choose weather to plot NMB and NME or FB and FE as percentages using the drop down box.</p>
                  <p><u>OUTPUTS</u>: The script produces two PNG (and corresponding PDF) images, one for bias and one for error. At this point, only one species can be plotted at a time. Each network is color coded and has a different symbol so that the individual networks can be identified.</p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>:Not choosing any networks or a species. Choosing a species for a network for which the desired species is not available (based on first network chosen in the network check list). Setting a time period which results in an empty query. Setting a georgraphical area in which there are no sites for the specified network. </p>
                  <p><strong>REFERENCE:</strong> Boylan, J.W., Russell, A.G., 2006. PM and light extinction model performance metrics, goals, and criteria for three-dimensional air quality models. Atmospheric Environment 40 (26), 4946-4959.</p>
                  <p>&nbsp;</p>
                  <p><strong><span class="style2"><span class="style3"><a name="timeseries"></a>Time-series Plot:</span></span></strong> </p>
                  <p>This script creates a time-series plot for an individual or multiple sites for an individual network and single species. Multiple sites are averaged into a single time-series. Temporal averaging does not apply to this type of plot.</p>
                  <p><u>INPUTS</u>: The user can choose multiple networks to be plot, although a single network will work better. A species must be specified and will be used. A time period to analyze must be specified. The user can specify an individual site (enter site name manually) or can use the find station link to locate individual or multiple stations. The user can specify a second model run to plot. The same time period for the first model run will be used for the second model run. </p>
                  <p><u>OUTPUTS</u>: A single PNG image (no PDF image) of the time-series will be created. If multiple networks are chosen, number image files for each network will be provided. </p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>:Not choosing any networks or a species. Choosing a species for a network for which the desired species is not available (based on first network chosen in the network check list). Setting a time period which results in an empty query. Setting a georgraphical area in which there are no sites for the specified network. Entering a site name that does not exist for the chosen network, or entering a site name that does exist but does not contain any data for the time period selected. </p>
                  <p>&nbsp;</p>
                  <p><strong><span class="style2"><span class="style3"><a name="spatialplot"></a>Model/Ob Spatial Plot:</span></span></strong> </p>
                  <p>This script plots spatially the observed and modeled values (and the difference between the two) as three separate images. Values are plotted as concentrations. Multiple values for individual sites are averaged. Values are color coded into concentration ranges. </p>
                  <p><u>INPUTS</u>: The user can choose any up to three networks to be plotted. A species must be specified. A time period to analyze must be specified. </p>
                  <p><u>OUTPUTS</u>: Three PNG (and corresponding PDF) images will be created. One plot for the observation values, one for the modeled values and one for the difference between the model and observation values. </p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>:Not choosing any networks or a species. Choosing a species for a network for which the desired species is not available (based on first network chosen in the network check list). Setting a time period which results in an empty query. Setting a georgraphical area in which there are no sites for the specified network. </p>
                  <p>&nbsp;</p>
                  <p><strong><span class="style2"><span class="style3"><a name="monthlyboxplot"></a>Monthly Box Plot:</span></span></strong> </p>
                  <p>This script creates a box plot on a monthly time period. Included on the plot is the 25% to 75% quartiles (shaded) and the median values (points and lines) for both model and observations. The whiskers typically shown on a box plot are removed. </p>
                  <p><u>INPUTS</u>: The user must specify a network and species to plot. Only one network and one species can be chosen for a single plot. A time period for analysis must be specified. At little as one month can be specified. Months from mutiple years will be plotted as one month. Individual model/ob pairs from the same month will automatically be analyzed together, so temporal averaging does not need to be set to monthly average. </p>
                  <p><u>OUTPUTS</u>: A single PNG (and corresponding PDF) image will be created. </p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>: Not choosing any networks or a species. Choosing a species for a network for which the desired species is not available (based on first network chosen in the network check list). Setting a time period which results in an empty query. Setting a georgraphical area in which there are no sites for the specified network. </p>
                  <p>&nbsp;</p>
                  <p><strong><span class="style2"><span class="style3"><a name="diurnalboxplot"></a>Hourly Box Plot:</span></span></strong> </p>
                  <p>This script is similar to the monthly box plot, however instead of plotting on a monthly time period, model and ob values are plotted on an hourly time period. As such, this script requires hourly data as the input. The result of the plot is essentially a diurnal curve showing the model performance through the diurnal cycle. </p>
                  <p><u>INPUTS</u>: The user must specify a network and species to plot. Only one network and one species can be chosen for a single plot. A time period for analysis must be specified. Hourly data must be chosen (e.g. AQS hourly, SEARCH). </p>
                  <p><u>OUTPUTS</u>: A single PNG (and corresponding PDF) image will be created. </p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>:Not choosing a network or species. Not selected an hourly data set to use. Setting a time period that results in an empty query. Selecting a geographic area that results in an empty query. </p>
                  <p>&nbsp;</p>
                  <p><strong><span class="style2"><span class="style3"><a name="stackedbar"></a>PM2.5 Stacked Bar Plot:</span></span></strong> </p>
                  <p>This script creates a stacked bar plot using only STN data, since it is the only network that consistently observes all the species that make-up PM2.5 in the model (excluding other). The script will plot two stacked bars, one for the observations and one for the model. Also included is the percentage that each species contributes to the total concentration. The concentration is given along the y-axis and the percentages are provided in the plot area. The legend indentifies the different colors corresponding to each species making up the stacked bars. It is not necessary to chose the network or species for this script, although doing so will not affect the function of the script. A time period to analyze must be specified however. </p>
                  <p><u>INPUTS</u>: STN data for all species (by default) and a user specified time period and region (not necessary). Individual sites or groups of sites can also be specified using the find station function. </p>
                  <p><u>OUTPUTS</u>: A single stacked bar PNG (and corresponding PDF) image.</p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>: Choosing a time period during which not STN data are available, or specifying a region within which no STN sites exist. </p>
                  <p>&nbsp;</p>
                  <p><strong><span class="style2"><span class="style3"><a name="paveoverlay"></a>Create PAVE Obs Overlay File:</span></span></strong> </p>
                  <p>This script creates an IOAPI file that is compatible with PAVE as an obs overlay file. The script requires either hourly or daily data as the input. </p>
                  <p><u>INPUTS</u>: This script can utilize either hourly or daily data. There is also the option to create daily 1-hour max or 8-hour max values from hourly data (generally applied to ozone). Depending on the type of input, the user must specify either hourly, daily, 1hr max or 8hr max from the drop down box for PAVE Overlay Options. This script will not currently work with data that are not hourly or daily, such as IMPROVE and STN, which measure every third day. </p>
                  <p><u>OUTPUTS</u>: The output from this script is an IOAPI file that is suitable for import into PAVE as an obs overlay file. The user will need to save the file to a directory where it can be loaded into PAVE. The user will need to load a model file into PAVE, then select overlay and choose this file as an overlay. </p>
                  <p><u>REASONS FOR POSSIBLE ERRORS</u>: Not choosing a network or species. Choosing a data set that is not either hourly or daily. Choosing to use 1hr max or 8hr max with daily data. Choosing a large number of sites (such as AQS) can result in a long processing time. There is apparently a limit of 1000 sites as the maximum number of sites that can be included in the file. Therefore, if using a large domain with a large number of sites, some sites may not be included in the obs file created. </p>
                  <!-- InstanceEndEditable --></td>
              </tr>
              <tr> 
                <td valign="TOP"><hr width="70%" color="#0000CC"> 
                  <p align="center"><b><a href="Templates/amet.php">Home</a> 
                    &nbsp;<img src="images/bullet.gif" width="10" height="10" border="0"> 
                    &nbsp;<a href="dbasesetup_aq.php">New Project</a> &nbsp;<img src="images/bullet.gif" width="10" height="10" border="0"> 
                    &nbsp;<a href="met-utils.php">Meteorological Analysis</a> &nbsp;<img src="images/bullet.gif" width="10" height="10" border="0"> 
                    &nbsp;<a href="aq-utils.php">Air-Quality Analysis</a>&nbsp;<img src="images/bullet.gif" width="10" height="10" border="0"> 
                    &nbsp;<a href="contact.html">Contact</a><br>
                  </b><A href="http://www.epa.gov/asmdnerl/index.html">Atmospheric Sciences Modeling Division</A></p>
                </td></tr>
            </table></TD>
        </TR>
      </TABLE></TD>
  </TR>
  <TR> 
    <TD background="Templates/images/blkbottom.gif"> <DIV align="center"> 
        <P><A href="http://www.snakeyewebtemplates.com" target="_blank" class="type1"><BR>
          &nbsp;&nbsp; </A></P>
      </DIV></TD>
  </TR>
</TABLE>
</BODY>
<!-- InstanceEnd --></HTML>
