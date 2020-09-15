
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




********** set-up putdocx
**************************************************************************************************************
clear
putdocx clear

local today : display %tdCYND date(c(current_date), "DMY")
display "`today'"

putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)

putdocx  paragraph, tofooter(footer) halign(right)
putdocx pagenumber

putdocx paragraph, toheader(header) 
putdocx text ("Corina Rueegg			AHUS-NO-COVID-19 Preliminary Report				`today'")

putdocx paragraph, style(Title) halign(center)
putdocx text ("AHUS-NO-COVID-19 report")

putdocx paragraph, halign(center)
putdocx text ("Corina Rueegg, PhD")
putdocx paragraph, halign(center)
putdocx text ("`today'")

putdocx paragraph, style(Heading1)
putdocx text ("Introduction")
putdocx paragraph
putdocx text ("This report presents the preliminary results of the AHUS-NO-COVID-19 trial. The safety analysis is based on the Safety Analysis Set including all subjects with any safety information after baseline (N=53). Patients randomised to hydroxychloroquine without receiving any amount of the treatment will be excluded from the safety population (nobody was excluded based on that condition). The primary efficacy analysis is based on the Full Analysis Set (FAS) including all randomised subjects who have had at least one baseline and one post-randomisation evaluation of efficacy (N=51). The secondary efficacy analysis is based on the Per Protocol Set including all participants of the FAS who took at least 7 of the 8 first hydroxychloroquine doses (N=49)")
putdocx paragraph
putdocx text ("Analysis according to final SAP version 2.1, dated 28.05.2020")
putdocx paragraph
putdocx text ("Data extraction Viedoc electronic data capture system, time stamped: 26.05.2020 12:06 UTC")




******** patient enrolment and disposition
**************************************************************************************************************
use data/anon/disposition, clear

putdocx paragraph, style(Heading1)
putdocx text ("1.	Patient enrolment and disposition")

** inclusion by treatment arm
putdocx paragraph, style (Heading2)
putdocx text ("1.1. Inclusion by treatment arm")

gen count=1
graph bar (count) count, over(allocation) ytitle(Number of randomised participants) asyvars bar(1, color(green)) bar(2, color(gold)) graphregion(color(white)) blabel(total) bargap(20) legend(nobox region(lstyle(none)))
graph export results/figs/treat_rand.png, replace

putdocx paragraph, halign(center)
putdocx image results/figs/treat_rand.png, width(5) height(4)


putdocx save results/`today'_nocovid_report_preliminary.docx, replace

** description of randomisation and disposition by study arm
putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style (Heading2)
putdocx text ("1.3. Description of patient disposition")
putdocx save results/`today'_nocovid_report_preliminary.docx, append

label define eosreascd 1 "Voluntary discontinuation" 4 "Lost to follow-up" 6 "Death" 99 "Other", replace
label var eosyn "Study completed"

summtab, by(allocation) catvars(eosyn eosreas) contvars() word  wordname(results/`today'_nocovid_report_preliminary.docx) title("Table 1. Overview of study completion and reasons for non-completion") append


** description of protocol deviations
putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style (Heading2)
putdocx text ("1.4. Description of protocol deviations")

list pdcate if pdcate !=.

putdocx paragraph
putdocx text ("One protocol deviation reported in the standard of care arm: Patient moved to ICU and started chloroquine treatment at the time of moving. At this stage of the pandemic, chloroquine was considered SOC for those who had serious covid-19. Date of deviation: 27.03.2020")

putdocx save results/`today'_nocovid_report_preliminary.docx, append




******** patient baseline characteristics
**************************************************************************************************************

putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style(Heading1)
putdocx text ("2.	Baseline characteristics")
putdocx save results/`today'_nocovid_report_preliminary.docx, append



use data/anon/baseline
count

*combine astma and copd in obstructive pulmonary diseases
generate opd = 0
recode opd 0=1 if kols==1
recode opd 0=1 if astma==1
label var opd "Obstructive pulmonary disease"
label val opd yesno_lab
tab opd

*obesity
gen obesity = 0 if vsbmi!=.
recode obesity 0=1 if vsbmi>=30 & vsbmi!=.
label var obesity "Obesity"
label val obesity yesno_lab

*generate combined morbidity variable
gen any_morbidity = 0
recode any_morbidity 0=1 if hypertension==1
recode any_morbidity 0=1 if diabetes==1
recode any_morbidity 0=1 if cad==1
recode any_morbidity 0=1 if kols==1
recode any_morbidity 0=1 if astma==1
recode any_morbidity 0=1 if obesity==1
label var any_morbidity "Any coexisting condition"
label def morbidity_lab 0 "No codition" 1 "≥1 condition"
label val any_morbidity morbidity_lab
tab any_morbidity

*fever
gen fever = 0 if temp!=.
recode fever 0=1 if temp>37.8 & temp!=.
label var fever "Temperature >37.8"
label val fever yesno_lab



summtab, by(allocation) catvars(sex supplemental_oxygen hypertension diabetes cad opd obesity any_morbidity fever smoking) contvars(news dmage vsbmi respiratory_rate temp sbp dbp saturation pulse) total mean median range pnonmiss catmisstype(missnoperc) word wordname(results/`today'_nocovid_report_preliminary.docx) title("Table 2. Baseline characteristics for all randomised participants (N=53)") append




******** study drug exposure
**************************************************************************************************************

putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style(Heading1)
putdocx text ("3.	Study drug exposure")
putdocx save results/`today'_nocovid_report_preliminary.docx, append



use data/anon/tabletintake


*recode variables
egen float dose_cum = rowtotal(dose1 dose2 dose3 dose4 dose5 dose6 dose7 dose8 dose9 dose10 dose11 dose12 dose13 dose14 dose15)

gen totaldose=dose_cum*200
gen tablet_doses = dose_cum/2

tab tablet_doses
codebook totaldose


*labels
label var tablet_doses	"Total number of 400mg doses received"
label var totaldose "Total dose (mg)"


summtab, catvars(tablet_doses) contvars(totaldose) median range pnonmiss catmisstype(missnoperc) medfmt(0) rangefmt(0) word wordname(results/`today'_nocovid_report_preliminary.docx) title("Table 3. Description of study drug exposure among those randomised to the hydroxychloroquine arm (N=27)") append




******* safety analysis
***************************************************************************************************************

putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style(Heading1)
putdocx text ("4.	Safety analysis")
putdocx paragraph, style(Heading2)
putdocx text ("4.1.	Adverse events of special interest")

putdocx save results/`today'_nocovid_report_preliminary.docx, append

use data/anon/safety_aesi

gen day=event-1

label def number_lab 1 "Number of events"

gen nausea=sq_naus
recode nausea 98=0
recode nausea 0=.
label var nausea "Vomiting/nausea"
label val nausea number_lab

gen diarrhoea=sq_diar
recode diarrhoea 98=0
recode diarrhoea 0=.
label var diarrhoea "Diarrhoea"
label val diarrhoea number_lab

gen pain=sq_abdp
recode pain 98=0
recode pain 0=.
label var pain "Abdominal pain"
label val pain number_lab

gen rash=sq_skin
recode rash 98=0
recode rash 0=.
label var rash "Skin rash"
label val rash number_lab

gen blurry=sq_blur
recode blurry 98=0
recode blurry 0=.
label var blurry "Blurry vision"
label val blurry number_lab

tab sqnauss if nausea==1, mis
tab sqdiars if diarrhoea==1, mis
tab sqabdps if pain==1, mis
tab sqskins if rash==1, mis
tab sqblurs if blurry==1, mis




summtab, by(allocation) catvars(nausea sqnauss diarrhoea sqdiars pain sqabdps rash sqskins blurry sqblurs) contvars()  total mean range catmisstype(none) medfmt(0) rangefmt(0) word wordname(results/`today'_nocovid_report_preliminary.docx) title("Table 4. Description of Adverse Events of Special Interest (AESI)") append

/*
putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph
putdocx text ("Note: The numbers in the table title reflect the number of days where AESI were assessed and reported in Viedoc")
putdocx save `today'_nocovid_report_preliminary.docx, append
*/

label def event_lab 0 "0" 1 "1" 2 "2" 3 "≥3"

sort randid day

foreach var of varlist nausea diarrhoea pain rash blurry {

bysort randid (day): generate `var'_cum = sum(`var')
egen `var'_max = max(`var'_cum), by(randid)
replace `var'_max=. if day>0

gen `var'_bin = `var'_max 
replace `var'_bin = 1 if nausea_max>0 & nausea_max!=.

gen `var'3 = `var'_max
replace `var'3 = 3 if `var'3 >2 & `var'3!=.
label val `var'3 event_lab

}

label var nausea3 "Number of nausea events per person"
label var diarrhoea3 "Number of diarrhea events per person"
label var pain3 "Number of abdominal pain events per person"
label var rash3 "Number of skin rash events per person"
label var blurry3 "Number of blurry vision events per person"

egen float any_aesi = rowtotal(nausea_max diarrhoea_max pain_max rash_max blurry_max)
replace any_aesi = 3 if any_aesi >2 & any_aesi!=.
label val any_aesi event_lab
label var any_aesi "Number of any AESI per person"



summtab if day==0, by(allocation) catvars(nausea3 diarrhoea3 pain3 rash3 blurry3 any_aesi) contvars() total mean range catmisstype(none) medfmt(0) rangefmt(0) word wordname(results/`today'_nocovid_report_preliminary.docx) title("Table 5. Description of patients with Adverse Events of Special Interest (AESI, N=53)") append


putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style(Heading2)
putdocx text ("4.2.	Additional adverse events and serious adverse events")
putdocx paragraph
putdocx text ("Note: there was no patient with more than one adverse event/serious adverse event")
putdocx save results/`today'_nocovid_report_preliminary.docx, append



use data/anon/safety_ae, clear

gen any_ae = eventseq
recode any_ae 2=1 .=0
label var any_ae "Patients with any adverse event"
label def ae_lab 0 "No AE" 1 "With AE"
label val any_ae ae_lab
tab any_ae

gen any_sae = aeser
recode any_sae .=0
label var any_sae "Patients with any serious adverse event"
label def sae_lab 0 "No SAE" 1 "With SAE"
label val any_sae sae_lab
tab any_sae

encode pt_name, gen(ae_term)
recode ae_term .=0
label var ae_term "Adverse event by Preferred Term"
label define ae_term 1 "Acute respiratory distress syndrome" 2 "Dyspnoea" 3 "Hypoaesthesia" 4 "Pneumonia" 5 "Respiratory failure" 6 "Urinary tract infection" 0 "No AE", replace
tab ae_term

encode soc_name, gen(ae_soc)
recode ae_soc .=0
label var ae_soc "Adverse event by System Organ Class"
label define ae_soc 1 "Infections and infestations" 2 "Nervous system disorders" 3 "Respiratory, thoracic and mediastinal disorders" 0 "No AE", replace
tab ae_soc

gen sae_term = ae_term if aeser==1
recode sae_term .=0
label define sae_term 1 "Acute respiratory distress syndrome" 2 "Dyspnoea" 3 "Hypoaesthesia" 4 "Pneumonia" 5 "Respiratory failure" 6 "Urinary tract infection" 0 "No SAE", replace
label val sae_term sae_term
label var sae_term "Serious adverse event by Preferred Term"
tab sae_term

gen death_term = ae_term if aesdth==1
recode death_term .=0
label define death_term 1 "Acute respiratory distress syndrome" 2 "Dyspnoea" 3 "Hypoaesthesia" 4 "Pneumonia" 5 "Respiratory failure" 6 "Urinary tract infection" 0 "Not resulted in death", replace
label val death_term death_term
label var death_term "SAEs resulting in death"
tab death_term

gen susar_term = ae_term if saeexp==2 & aeser==1
recode susar_term .=0
label define susar_term 1 "Acute respiratory distress syndrome" 2 "Dyspnoea" 3 "Hypoaesthesia" 4 "Pneumonia" 5 "Respiratory failure" 6 "Urinary tract infection" 0 "No SUSAR (expected SAE)", replace
label val susar_term susar_term
label var susar_term "SUSAR"
tab susar_term



summtab, by(allocation) catvars(any_ae any_sae ae_term ae_soc sae_term death_term susar_term) contvars() total mean range catmisstype(none) medfmt(0) rangefmt(0) word wordname(results/`today'_nocovid_report_preliminary.docx) title("Table 6. Description of patients with Adverse Events (N=53)") append




******** modelling of treatment effect
**************************************************************************************************************

**load data
 
use data/anon/efficacy_fas, clear

**recode and re-label of relevant variables

gen log_viralload=log10(viralload+1)
label var log_viralload "Viral load log10 in RNA copies/ml"
label var day "Timepoint"



**description of hypothesis in the report
putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style(Heading1)
putdocx text ("5.	Effect of hydroxychloroquine on viral load")
putdocx paragraph, style (Heading2)
putdocx text ("5.1. Hypothesis to be tested")
putdocx paragraph
putdocx text ("The primary null hypothesis is that there is no difference in the slope of the viral load from randomisation to 48 and 96 hours between the two treatment regimes.")

**descriptive statistics of the viral load data
putdocx paragraph, style (Heading2)
putdocx text ("5.2. Description of the viral load data")

putdocx save results/`today'_nocovid_report_preliminary.docx, append

putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
summtab, by(day) catvars() contvars(viralload log_viralload) median mean range total word wordname(results/`today'_nocovid_report_preliminary.docx) title("Table 7. Description of viral load overall and by study time point") append

**mixed model to assess the treatment effect FAS
putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style (Heading2)
putdocx text ("5.3. Results from modelling of the treatment effect in the FAS (N=51)")
putdocx paragraph
putdocx text ("Model: The primary endpoint (slope of the viral load (log10) from baseline to 48h and 96 hours post-randomisation) was analysed using a mixed model with fixed and random intercept and slope.")

rename day Study_Day
sort randid

mixed log_viralload c.Study_Day i.allocation c.Study_Day#i.allocation || randid:Study_Day, ml 
putdocx table tab8 = etable, title("Table 8. Model results") 

margins allocation, dydx(Study_Day) /* Slope by trt*/
putdocx table tab9 = etable, title("Table 9. Estimated slope for each treatment group") 

margins r.allocation ,dydx(Study_Day) /* Difference in slope, also seen in model */
putdocx table tab10 = etable, title("Table 10. Estimated difference in slope between the treatment groups") 

margins allocation, at(Study_Day == 4) /* Intercept by trt */
putdocx table tab11 = etable, title("Table 11. Estimated marginal mean by treatment group at time point 96 hours") 

margins, dydx(allocation) at(Study_Day == 4) /* Difference at week 1 */
putdocx table tab12 = etable, title("Table 12. Estimated marginal mean difference between the treatment groups at time point 96 hours") 


mixed log_viralload i.Study_Day i.allocation i.Study_Day#i.allocation || randid:Study_Day, ml 
margins Study_Day#allocation
marginsplot, graphregion(color(white)) graphregion(color(white)) plotregion(color(white)) ytitle("Marginal estimates") ylabel(,nogrid labsize(small)) xlabel(,labsize(small)) legend(region(color(none) lstyle(none)) cols(1) ring(0) bplacement(nwest)) title("")

putdocx paragraph
putdocx text ("Figure 3. Marginsplot to illustrate the estimated mean viral load (log10) with 95% CIs over time and by treatment arm"), bold
graph export results/figs/marginsplot.png, replace
graph save results/figs/marginsplot_itt.gph, replace
putdocx paragraph, halign(center)
putdocx image results/figs/marginsplot.png, width(5) height(4)

putdocx save results/`today'_nocovid_report_preliminary.docx, append


**mixed model assumption check
*plotting residuals vs observed (linearity)
predict residuals, residuals
scatter log_viralload residuals

*plotting residuals vs fitted
predict fitted, xb
scatter fitted residuals 

*linearity of residuals
qnorm residuals

*test homogenecity of variance
gen residuals_absolute = abs(residuals)
gen residuals_square = residuals_absolute^2
regress residuals_square randid




**mixed model to assess the treatment effect Per protocol 
putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style (Heading2)
putdocx text ("5.4. Results from modelling of the treatment effect in the Per Protocol Set (N=49)")
putdocx paragraph
putdocx text ("Model: The primary endpoint (slope of the viral load (log10) from baseline to 48h and 96 hours post-randomisation) was analysed using a mixed model with fixed and random intercept and slope.")



drop if pp == 0


mixed log_viralload c.Study_Day i.allocation c.Study_Day#i.allocation || randid:Study_Day, ml 
putdocx table tab13 = etable, title("Table 13. Model results") 

margins allocation, dydx(Study_Day) /* Slope by trt*/
putdocx table tab14 = etable, title("Table 14. Estimated slope for each treatment group") 

margins r.allocation ,dydx(Study_Day) /* Difference in slope, also seen in model */
putdocx table tab15 = etable, title("Table 15. Estimated difference in slope between the treatment groups") 

margins allocation, at(Study_Day == 4) /* Intercept by trt */
putdocx table tab16 = etable, title("Table 16. Estimated marginal mean by treatment group at time point 96 hours") 

margins, dydx(allocation) at(Study_Day == 4) /* Difference at week 1 */
putdocx table tab17 = etable, title("Table 17. Estimated marginal mean difference between the treatment groups at time point 96 hours") 


mixed log_viralload i.Study_Day i.allocation i.Study_Day#i.allocation || randid:Study_Day, ml 
margins Study_Day#allocation
marginsplot, graphregion(color(white)) graphregion(color(white)) plotregion(color(white)) ytitle("Marginal estimates") ylabel(,nogrid labsize(small)) xlabel(,labsize(small)) legend(region(color(none) lstyle(none)) cols(1) ring(0) bplacement(nwest)) title("")

putdocx paragraph
putdocx text ("Figure 4. Marginsplot to illustrate the estimated mean viral load (log10) with 95% CIs over time and by treatment arm"), bold
graph export results/figs/marginsplot2.png, replace
graph save results/figs/marginsplot_perprotocol.gph, replace
putdocx paragraph, halign(center)
putdocx image results/figs/marginsplot2.png, width(5) height(4)

putdocx save results/`today'_nocovid_report_preliminary.docx, append


**mixed model assumption check
*plotting residuals vs observed (linearity)
predict residuals2, residuals
scatter log_viralload residuals2

*plotting residuals vs fitted
predict fitted2, xb
scatter fitted2 residuals2

*linearity of residuals
qnorm residuals2

*test homogenecity of variance
gen residuals_absolute2 = abs(residuals2)
gen residuals_square2 = residuals_absolute2^2
regress residuals_square2 randid








****************************************************************************************************************
**************** POSTHOC


use data/anon/efficacy_fas, clear


**recode and re-label of relevant variables

gen log_viralload=log10(viralload+1)
label var log_viralload "Viral load log10 in RNA copies/ml"
label var day "Timepoint"

rename day Study_Day





putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style(Heading1)
putdocx text ("6.	Post-hoc analyses")
putdocx paragraph, style (Heading2)
putdocx text ("6.1. Individual viral load trajectories")

twoway line log_viralload Study_Day, by(allocation, note("")) connect(L) lwidth(thin) color(navy%50) xlabel(0"Randomization" 2"48 hours" 4 "96 hours", labsize(small)) ytitle("Viral load in RNA copies/ml (log10)")

graph export results/figs/trajectories.png, replace
graph save results/figs/trajectories.gph, replace
putdocx paragraph, halign(center)
putdocx image results/figs/trajectories.png, width(5) height(4)

putdocx save results/`today'_nocovid_report_preliminary.docx, append



putdocx begin, pagesize(A4) pagenum(decimal) footer(footer) header(header)
putdocx paragraph, style (Heading2)
putdocx text ("6.2. Estimated marginal mean differences at baseline and time point 48h")
putdocx paragraph
putdocx text ("Estimated marginal means based on the model described under section 5.3., FAS (N=51)")


**mixed model to assess the treatment effect FAS

mixed log_viralload c.Study_Day i.allocation c.Study_Day#i.allocation || randid:Study_Day, ml 

margins allocation, at(Study_Day == 0) /* Intercept by trt */
putdocx table tab18 = etable, title("Table 18. Estimated marginal mean by treatment group at baseline") 

margins, dydx(allocation) at(Study_Day == 0) /* Difference at week 1 */
putdocx table tab19 = etable, title("Table 19. Estimated marginal mean difference between the treatment groups at baseline") 


margins allocation, at(Study_Day == 2) /* Intercept by trt */
putdocx table tab20 = etable, title("Table 20. Estimated marginal mean by treatment group at time point 48 hours") 

margins, dydx(allocation) at(Study_Day == 2) /* Difference at week 1 */
putdocx table tab21 = etable, title("Table 21. Estimated marginal mean difference between the treatment groups at time point 48 hours") 


putdocx save results/`today'_nocovid_report_preliminary.docx, append







