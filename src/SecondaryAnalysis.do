
********************************************
*** combine datasets for safety analysis ***
********************************************




*** ORIG DATASETS
* AE: adverse events --> use for safety data
* BB: biobank sampling, yesno, date, time, id --> merge with viralload.dta
* BIO: lab tests at screening, almost everything missing --> no use
* CM: prior and concomitant medication
* CS: clinical status at day 14
* DA: tablets dispatched, dispatch date, number of tables taken, discrepancies
* DH: hospital dispach date, time, dispatch location
* DM: demographics --> use age and sex for baseline table
* EOS: end of study form
* ICU: admission to ICU, intubation, return to ward
* IE: inclusion, exclusion 
* MedDRA: adverse events system class codes --> use for safety data
* OA: date and time of admission and first symptom
* PDV: protocol deviations
* PRE: pregnancy test at screening
* RAN: randomisation
* SQ: mortality, admissions, adverse events of special interest, tablets deviation, concomitant medications
* TF: same as SQ but for telefone follow-up
* VS: only height and weight at screening --> ad to baseline table 

* allocation: true and dummy allocation
* viralload: viral load results from lab
* morbidities: baseline co-morbidities from additional excel file


*** GENERATED/CLEANED DATASETS
*safety_ae: combinatino of AE, MEDDRA and allocation
*safety_aesi: combination of SQ and allocation
*baseline: combination of DM and VS and morbidities 
*disposition: combination of RAN, EOS and PDV
*efficacy_fas: combinatin of viralload and allocation including only FAS
*drugintake: from seperate excel file

*secondaryendpoints: from excel file received from study group
*




********** set-up putdocx
**************************************************************************************************************
clear
putdocx clear

local today : display %tdCYND date(c(current_date), "DMY")
display "results/`today'"

putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)

putdocx  paragraph, tofooter(footer) halign(right)
putdocx pagenumber

putdocx paragraph, toheader(header) 
putdocx text ("Corina Rueegg			AHUS-NO-COVID-19 Secondary Endpoints				results/`today'")

putdocx paragraph, style(Title) halign(center)
putdocx text ("AHUS-NO-COVID-19 Secondary Endpoints")

putdocx paragraph, halign(center)
putdocx text ("Corina Rueegg, PhD")
putdocx paragraph, halign(center)
putdocx text ("results/`today'")

putdocx paragraph
putdocx text ("This report presents the results of additional analyses of the secondary endpoints of the AHUS-NO-COVID-19 trial. The analysis was performed as response to the reviewer comments on the manuscript submitted to Nature Communication. The analyses are based on the Full Analysis Set (FAS) including all randomised subjects who have had at least one baseline and one post-randomisation evaluation of efficacy of the primary endpoint (N=51).")
putdocx paragraph
putdocx text ("The analysis is performed based on the pre-specified short description of analysis of secondary continuous, categorical and time-to-event data in the study protocol. The analysis of the ordinal endpoint was not specified in the protocol and was decided posthoc (but before looking at any results of the secondary endpoints). Protocol Version 1.3, dated 26.03.2020.")
putdocx paragraph
putdocx text ("Data extraction Viedoc electronic data capture system, time stamped: 26.05.2020 12:06 UTC. Additional data on secondary endpoints received from the study group, 11.09.2020")





******** Clinical status according to a 6-point ordinal scale --> ordinal data --> ordinal logistic regression
**************************************************************************************************************

putdocx paragraph, style(Heading1)
putdocx text ("1.	Clinical status 14 days after randomisation")
putdocx paragraph
putdocx text ("Ordinal logistic regression model with 7-point scale as outcome and allocation as exposure. Output set to OR.")


clear
use data/anon/efficacy_fas

keep if day==0
drop viralload SDRNAcopiesPCRreaction 

merge 1:1 randid using data/anon/secondaryendpoints, nogen

*keep only FAS (N=51)
drop if itt == 0

label var scale_7 "7-point clinical status scale"

** ordinal logistic regression on 6-point likert scale with allocation as exposure
putdocx save results/`today'_nocovid_report_secondaryendpoints.docx, replace

summtab, catvars(scale_7) contvars() by(allocation) pnonmiss catmisstype(missperc) title("Number and proportion of participants in each level of the 7-point clinical state scale, stratified by group allocation") word wordname(results/`today'_nocovid_report_secondaryendpoints.docx) append

putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)


ologit scale_7 allocation, or

putdocx table tab1 = etable, title("Table 1. Results from ordinal logistic regression model") 



******** Duration of hospital stay --> time-to-event data --> Kaplan Meier method and log rank test
**************************************************************************************************************

putdocx paragraph, style(Heading1)
putdocx text ("2.	Duration of hospital stay")
putdocx paragraph
putdocx text ("Kaplan Meier method to estimate time from randomisation to hospital discharge by allocation. Comparison of the two groups with a log rank test.")


gen event = 1 
recode event 1=0 if mortality_inhospital==1

stset time, failure(event)

stsum
putdocx paragraph
putdocx text ("Description of overall survival data"), bold
putdocx paragraph
putdocx text ("51 observations, 49 failures (=discharges), 347 days of total analysis time at risk and under observation")

sts list, by(allocation)


sort allocation
sts graph, by(allocation) xlabel(0(5)60, labsize(vsmall)) ylabel(0 "0" 0.2 "20" 0.4 "40" 0.6 "60" 0.8 "80" 1.0 "100", labsize(vsmall)) xtitle("Days since randomisation" " ", size(small)) ytitle("Kaplan-Meier estimated percent in hospital "" ", size(small)) title("Kaplan-Meier survival estimates for time from randomisation to hospital discharge", size(medsmall)) legend(label(1 "Standard of care") label(2 "Chloroquine therapy + standard of care") size(small)) scheme(s1color) name(KM_curve, replace)

graph export results/figs/KM_curve.png, replace
graph save results/figs/KM_curve.gph, replace
putdocx paragraph, halign(center)
putdocx image results/figs/KM_curve.png, width(5) height(4)

sts test allocation
putdocx paragraph
putdocx text ("Results from log-rank test for equality of survivor functions"), bold
putdocx paragraph
putdocx text ("Standard of care arm: observed events=24, expected events=25.15; Chloroquine therapy + standard of care arm: observed events=25; expected events=23.85; p-value=0.7137")





******** Change in National Early Warning Score (NEWS) from randomization to 96 hours --> repeated measures --> mixed model
*****************************************************************************************************************************

putdocx paragraph, style(Heading1)
putdocx text ("3.	Change in NEWS score from randomisation to 96 hours")
putdocx paragraph
putdocx text ("Change in the NEWS score from baseline to 96 hours post-randomisation. Analysed using a linear mixed model with fixed and random intercept. Time in days was entered categorical in the model.")


clear
use data/anon/efficacy_fas

drop viralload SDRNAcopiesPCRreaction 

*rename count count_primary

merge 1:1 randid day using data/anon/news

sort _merge day
drop if itt == 0

sort randid day

drop if day>4		// we only look up to 96 hours
drop if _merge==1  // master only, missing NEWS score


*fill allocation for the missing days
by randid: replace allocation=allocation[_n-1] if allocation==.
tab allocation if day==0

drop count
sort randid day
by randid: generate count = _n

label define day_lab 1 "24 hours", add
label define day_lab 3 "72 hours", add
tab day allocation

putdocx save results/`today'_nocovid_report_secondaryendpoints.docx, append

summtab, catvars(day) contvars() by(allocation) total pnonmiss catmisstype(missperc) title("Number of available NEWS assessments per day, stratified by group allocation") word wordname(results/`today'_nocovid_report_secondaryendpoints.docx) append

putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)



rename day Study_Day
sort randid


putdocx paragraph
putdocx text ("Results from linear mixed model"), bold

mixed news i.Study_Day i.allocation i.Study_Day#i.allocation || randid:, ml 
putdocx table tab2 = etable, title("Table 2. Model results") 

margins allocation, dydx(Study_Day) /* Slope by trt*/
putdocx table tab3 = etable, title("Table 3. Estimated change from baseline at each time point") 

margins r.allocation ,dydx(Study_Day) /* Difference in slope, also seen in model */
putdocx table tab4 = etable, title("Table 4. Estimated difference of the change between the treatment groups at each time point") 

margins allocation, at(Study_Day == 4) /* Intercept by trt */
putdocx table tab5 = etable, title("Table 5. Estimated marginal mean by treatment group at time point 96 hours") 


mixed news i.Study_Day i.allocation i.Study_Day#i.allocation || randid:, ml 
margins Study_Day#allocation
marginsplot, graphregion(color(white)) graphregion(color(white)) plotregion(color(white)) ytitle("Marginal estimates") ylabel(,nogrid labsize(small)) xlabel(,labsize(small)) legend(region(color(none) lstyle(none)) cols(1) ring(0) bplacement(nwest)) title("")

putdocx paragraph
putdocx text ("Figure 2. Marginsplot to illustrate the estimated mean NEWS score with 95% CIs over time and by treatment arm"), bold
graph export results/figs/marginsplot.png, replace
graph save results/figs/marginsplot.gph, replace
putdocx paragraph, halign(center)
putdocx image results/figs/marginsplot.png, width(5) height(4)

putdocx save results/`today'_nocovid_report_secondaryendpoints.docx, append





**mixed model assumption check
*plotting residuals vs observed (linearity)
predict residuals, residuals
scatter news residuals

*plotting residuals vs fitted
predict fitted, xb
scatter fitted residuals 

*linearity of residuals
qnorm residuals

*test homogenecity of variance
gen residuals_absolute = abs(residuals)
gen residuals_square = residuals_absolute^2
regress residuals_square randid




