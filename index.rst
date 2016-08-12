========
 blsAPI
========
Request Data from the U.S. Bureau of Labor Statistics API

Introduction
============
blsAPI is an R package that allows users to request data for one or multiple series through the U.S. Bureau of Labor Statistics API. Users provide parameters as specified in http://www.bls.gov/developers/api_signature.htm and the function returns a JSON string or data frame.

Installation
============
blsAPI can be installed easily through `CRAN <http://cran.r-project.org/web/packages/blsAPI/index.html>`_
or `GitHub 
<https://github.com/mikeasilva/blsAPI>`_  Select which repository you would like to use and type the following commands in R:

CRAN
----
``install.packages('blsAPI')``

GitHub
------
``library(devtools); install_github('mikeasilva/blsAPI')``

API Basics
==========
The blsAPI package supports two versions of the BLS API. API Version 2.0 requires registration and offers greater query limits. It also allows users to request net and percent changes and series description information. See below for more details.

========================================  ========================  ==========================
Service                                   Version 2.0 (Registered)  Version 1.0 (Unregistered)
========================================  ========================  ==========================
Daily query limit	                        500	                      25
Series per query limit	                   50                        25
Years per query limit                     20                        10
Net/Percent Changes	                      Yes                       No
Optional annual averages	                 Yes                       No
Series description information (catalog)	 Yes                       No
========================================  ========================  ==========================

