{smcl}
{* *! version 0.6 August 19, 2009}{...}
{cmd:help pantob}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:pantob} {hline 2}}Estimation of Static Panel Data Censored Regression Models{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:pantob} {varlist} {ifin} [{cmd:,} {cmd: absloss} {cmd: bootstrap} {cmd: details}]

{p 4 6 2}
{it:varlist} has the dependent variables as its first element and the group-identifier as its last element. The remaining elements are the explanatory variables. {p_end}

{title:Despription}

{pstd}{cmd:pantob} implements the estimators in Honoré (1992).

{title:Options}

{phang}{opt absloss} specifies that the estimator is based on the absolute error loss function.

{phang}{opt bootstrap} specifies that standard errors are to be estimated by the bootstrap.

{phang}{opt details} specifies that details form the numerical optimization are displayed.

{title:Examples}

{phang}. pantob y x* z1 tren{p_end}
{phang}. pantob y x* z1 tren, bootstrap{p_end}
{phang}. pantob y x* z1 tren, absloss{p_end}
{phang}. pantob y x* z1 tren, absloss bootstrap{p_end}
{phang}. pantob y x* z1 tren, absloss bootstrap details{p_end}

{title:References}

{phang}Honoré, Bo E. (1992): "Trimmed Lad and Least Squares Estimation of Truncated and Censored Regression Models with Fixed Effects"
{it:Econometrica}, Vol. 60, No. 3, pp. 533-565.{p_end}
{phang}Honoré, Bo E. and Ekaterini Kyriazidou (2000): "Estimation of Tobit--Type Models with Individual Specific Effects" {it:Econometric Reviews}, vol. 19, no. 3, pp. 341-366{p_end}

{title:Author}

{phang}Bo E. Honoré, Princeton University, honore@princeton.edu{p_end}




