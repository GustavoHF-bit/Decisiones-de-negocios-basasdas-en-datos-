cls
clear
import delimited "C:\Users\jgush\Downloads\base.csv"

encode education, generate(education2)
encode marital_status, generate(marital_status2)
drop if income=="NA"
 destring income, replace

* Para replicaciones

set seed 3245

* Partición de la base

*tab mntwines

gen random_var = runiform()
di runiform()

gen train = (random_var <= .5)
drop random_var

tab mntwines train


*Minímos cuadrados-------------------------------------------------------------

regress mntwinesbin income mntfruits mntmeatproducts mntfishproducts mntsweetproducts mntgoldprods numdealspurchases numwebpurchases numcatalogpurchases numwebvisitsmonth i.education2 i.marital_status2 i.complain i.acceptedcmp2 i.acceptedcmp1 i.acceptedcmp5 i.acceptedcmp4 i.acceptedcmp3 if train==1 
predict y_ols, xb
gen target_ols = (y_ols >= .05) if train == 0
gen pe_ols = abs(target_ols - mntwinesbin)
gen pe_ols_2 = pe_ols
sum pe_ols_2 if train == 0
global mpe_ols = r(mean)

* Error de tipo 1
sum target_ols if target == 1
global r2_t1_ols = r(mean)

*Lasso-------------------------------------------------------------------------

lassoregress mntwinesbin income mntfruits mntmeatproducts mntfishproducts mntsweetproducts mntgoldprods numdealspurchases numwebpurchases numcatalogpurchases numwebvisitsmonth i.education2 i.marital_status2 i.complain i.acceptedcmp2 i.acceptedcmp1 i.acceptedcmp5 i.acceptedcmp4 i.acceptedcmp3 if train==1 
predict y_lasso, xb
gen target_lasso = (y_lasso >= .05) if train == 0
gen pe_lasso = abs(target_lasso - mntwinesbin)
gen pe_lasso_2 = pe_lasso
sum pe_lasso_2 if train == 0
global mpe_lasso = r(mean)

* Error de tipo 1
sum target_lasso if target == 1
global r2_t1_lasso = r(mean)

*Ridge-------------------------------------------------------------------------

ridgeregress mntwinesbin income mntfruits mntmeatproducts mntfishproducts mntsweetproducts mntgoldprods numdealspurchases numwebpurchases numcatalogpurchases numwebvisitsmonth i.education2 i.marital_status2 i.complain i.acceptedcmp2 i.acceptedcmp1 i.acceptedcmp5 i.acceptedcmp4 i.acceptedcmp3 if train==1 
predict y_ridge
gen target_ridge = (y_ridge >= .05) if train == 0
gen pe_ridge = abs(target_ridge - mntwinesbin)
gen pe_ridge_2 = pe_ridge
sum pe_ridge if train == 0
global mpe_ridge = r(mean)

* Error de tipo 1
sum target_ridge if target == 1
global r2_t1_ridge = r(mean)

*Elastic Regression------------------------------------------------------------

elasticregress mntwinesbin income mntfruits mntmeatproducts mntfishproducts mntsweetproducts mntgoldprods numdealspurchases numwebpurchases numcatalogpurchases numwebvisitsmonth i.education2 i.marital_status2 i.complain i.acceptedcmp2 i.acceptedcmp1 i.acceptedcmp5 i.acceptedcmp4 i.acceptedcmp3 if train==1 
predict y_elastic
gen target_elastic = (y_elastic >= .05) if train == 0
gen pe_elastic = abs(target_elastic - mntwinesbin)
gen pe_elastic_2 = pe_elastic^2 
sum pe_elastic_2 if train == 0
global mpe_elastic = r(mean)

* Error de tipo 1
sum target_elastic if target == 1
global r2_t1_elastic = r(mean)

*Logit-------------------------------------------------------------------------

logit mntwinesbin income mntfruits mntmeatproducts mntfishproducts mntsweetproducts mntgoldprods numdealspurchases numwebpurchases numcatalogpurchases numwebvisitsmonth i.education2 i.marital_status2 i.complain i.acceptedcmp2 i.acceptedcmp1 i.acceptedcmp5 i.acceptedcmp4 i.acceptedcmp3 if train==1
margins, dydx(*)
predict y_logit
gen target_logit = (y_logit >= .05) if train == 0
gen pe_logit = abs(target_logit - mntwinesbin)
gen pe_logit_2 = pe_logit
sum pe_logit_2 if train == 0
global mpe_logit = r(mean)

* Error de tipo 1
sum target_logit if target == 1
global r2_t1_logit = r(mean)

*Probit-----------------------------------------------------------------------

probit mntwinesbin income mntfruits mntmeatproducts mntfishproducts mntsweetproducts mntgoldprods numdealspurchases numwebpurchases numwebvisitsmonth i.marital_status2 i.acceptedcmp1 i.acceptedcmp2 i.acceptedcmp3 i.acceptedcmp4 i.acceptedcmp5 i.complain i.education2 if train==1

predict y_probit
margins, dydx(*)
gen target_probit = (y_probit >= .05) if train == 0
gen pe_probit = abs(target_probit - mntwinesbin) if train == 0
gen pe_probit_2 = pe_probit
sum pe_probit_2 if train == 0
global mpe_probit = r(mean)

* Error de tipo 1
sum target_probit if target == 1
global r2_t1_probit = r(mean)

*Penalized logit--------------------------------------------------------------

rlassologit mntwinesbin income mntfruits mntmeatproducts mntfishproducts mntsweetproducts mntgoldprods numdealspurchases numwebpurchases numcatalogpurchases numwebvisitsmonth i.education2 i.marital_status2 i.complain i.acceptedcmp2 i.acceptedcmp1 i.acceptedcmp5 i.acceptedcmp4 i.acceptedcmp3 if train==1
margins, dydx(*)
predict y_plogit if train==0,pr
gen target_plogit = (y_plogit >= .05) if train == 0
gen pe_plogit = abs(target_plogit - mntwinesbin)
gen pe_plogit_2 = pe_plogit
sum pe_plogit_2 if train == 0
global mpe_plogit = r(mean)

* Error de tipo 1
sum target_plogit if target == 1
global r2_t1_plogit = r(mean)


*Random Forest-----------------------------------------------------------
rforest mntwinesbin income mntfruits mntmeatproducts mntfishproducts mntsweetproducts mntgoldprods numdealspurchases numwebpurchases numcatalogpurchases numwebvisitsmonth education2 marital_status2 complain acceptedcmp2 acceptedcmp1 acceptedcmp5 acceptedcmp4 acceptedcmp3 if train == 1, type(reg)
predict y_rforest if train == 0
gen target_rforest = (y_rforest >= .05) if train == 0 
gen pe_rforest = abs(target_rforest - mntwinesbin)
gen pe_rforest_2=pe_rforest
sum pe_rforest_2 if train==0
global mpe_rforest=r(mean

* Error de tipo 1
sum target_rforest if target == 1
global r2_t1_rforest = r(mean)

 *Neural Networks-------------------------------------------------------------
 global Xvars mntwinesbin income mntfruits mntmeatproducts mntfishproducts mntsweetproducts mntgoldprods numdealspurchases numwebpurchases numcatalogpurchases numwebvisitsmonth
 brain define if _n<=100, input($Xvars) output(mntwinesbin) hidden(10 10) 
 brain train if _n<=100, iter(500) eta(.10)
 capture drop y_neuralnet
 brain think y_neuralnet 
 gen pe_neuralnet = (y_neuralnet - mntwinesbin) if _n>= 101
 sum pe_neuralnet
 global mpe_neuralnet = r(mean)
 
 * Error de tipo 1
sum target_brain if target == 1
global r2_t1_brain = r(mean)

 di "The mpe for  is " $mpe_ols
 di "The mpe for  is " $mpe_lasso
 di "The mpe for  is " $mpe_ridge
 di "The mpe for  is " $mpe_elastic
 di "The mpe for  is " $mpe_logit
 di "The mpe for  is " $mpe_probit
 di "The mpe for  is " $mpe_plogit
 di "The mpe for  is " $mpe_neuralnet
 di "The mpe for  is " $mpe_rforest
 
 *Error T1
di $r2_t1_ols
di $r2_t1_lasso
di $r2_t1_ridge
di $r2_t1_logit
di $r2_t1_probit
di $r2_t1_elastic
di $r2_t1_plogit
di $r2_t1_rforest
di $r2_t1_brain