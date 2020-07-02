# Level4-Processor

<h3>Level 4 - Year 1 and 2 Processor</h3>

The processing chain used in Year 1 and 2 to generate the CRDP for SSS ECV is drawn on the following picture. 3 entries are used; one for each main satellite data inputs. 

<img src="https://github.com/CCI-SALINITY/Level4-Processor/blob/master/Year1/CCI%20salinity%20production%20chain.png">

The L4 processing chain intends to produce:
-	Weekly L4 and
-	Monthly L4

Both products are formatted in netcdf and are in conformance with the data format convention applied on the CCI projects 

<h3>Satellite data</h3>

The main sources of satellite based SSS data are:
-	SMOS (Soil Moisture and Ocean Salinity)
-	AQUARIUS
-	SMAP (Soil Moisture Active Passive)

Other sensor data such AMSR will appear in the next phase of the project (Year 3).

The input data coverage is detailed in the following figures:

<img src="https://github.com/CCI-SALINITY/Level4-Processor/blob/master/Year1/CCI%20salinity%20satellite%20data%201.png">

<img src="https://github.com/CCI-SALINITY/Level4-Processor/blob/master/Year1/CCI%20salinity%20satellite%20data%202.png">

The above inputs are originally generated on different grids, so a homogenisation of the data has been performed prior to the L4 processing.

-	SMOS is computed on and Icosahedron Snyder Equal Area (ISEA) Aperture 4 Hexagonal (ISEA4H) global grid. Level 2 OS data from CATDS are projected on an EASE2 cylindrical equal area grid. It is a global coverage grid at 25 km resolution.

Version of the Level 2 OS processor is 6.22 and the CATDS production is based on RE05 reprocessed data. Data are formatted in netCDF.

-	AQUARIUS Level 3 data are used in version v5.0 with a latitudinal correction within AQUARIUS processing using ARGO data. No extra correction added.

The original L3 mapped products are given on a Plate-Carrée equidistant cylindrical grid. They consist in binned data accumulated for all Level 2 products over a period of 7 days (Aquarius Level-3 Standard Mapped Image). The data are formatted in HDF at a resolution of 1 degree.

-	SMAP Level 2 data in version v4.0 are used with a latitudinal correction within SMAP RSS processing using ARGO data. No extra correction added.

The Original L2C products have 40 km (39 km x 47 km elliptical footprint) spatial resolution. They are based on L1B SMAP RFI filtered antenna temperatures version 4 [SMAP_L2C]. Data are formatted in netCDF.

In-situ measurements from <b>ARGO</b> are also used. The gridded field of ocean temperature and salinity (on average over 10 Years) at standard ARGO depths produced by the ISAS analysis tool (developed by the LPO – Laboratoire de Physique des Océans) are used for final calibration as input to the Level 4 processor.

<h3>Detailed Level 4 processing chain </h3>

The aim of the L4 processing is: 
-	to merge products from different satellite sensors
-	to produce SSS at:
o	a spatial resolution of about 50 km
o	a time resolution of 1 month or 1 week.
With 
-	a spatial sampling : 25 km EASE V2 grid; 
-	time sampling : 15 days (monthly products) and 1 day (weekly products).

The processing chain breakdown is detailed on the next figure

<img src="https://github.com/CCI-SALINITY/Level4-Processor/blob/master/Year1/CCI%20salinity%20full%20production%20chain.png">

The processing steps are detailed hereafter:
1.	Reading of the SSS L2/L3 products (after latitudinal correction and reprojection).
2.	 Simultaneous computation of the inter sensor biases and the monthly SSS. Use of an Optimal Interpolation algorithm.
3.	3 sigmas filtering by using L2/L3 errors and first SSS(t) estimation: outlier detection.
4.	Computation of the inter sensor biases and the monthly SSS from SSS without ouliers. Computation of the a posteriori monthly SSS error and the number of outliers. 
5.	3 sigmas filtering: weekly variability is added quadratiquely to the L2/L3 error
6.	Computation of the weekly SSS. Use of an Optimal Interpolation algorithm. The inter sensor biases come from the step 2/ and are not computed again at this step. Computation of the a posteriori weekly SSS error and the number of outliers. 
7.	SSS absolute calibration by using ISAS mean SSS. Calibration uses quantiles.


<h3>Output data</h3>

The final Year 2 L4 dataset version is <b>2.31</b>.

The Level 4 products are computed over two time periods:
-	7 days running mean at one day time sampling

Ex: ESACCI-SEASURFACESALINITY-L4-SSS-MERGED_OI_7DAY_RUNNINGMEAN_DAILY_25km-20120104-fv2.31.nc

-	One month at 15 days time sampling centred.

Ex: ESACCI-SEASURFACESALINITY-L4-SSS-MERGED_OI_Monthly_CENTRED_15Day_25km-20160301-fv2.31.nc

The L4 products are formatted in netcdf 4. They contain the following variables:
-	monthly and weekly SSS fields: obtained from OI algorithm (statistical approach which allows error propagation)
-	SSS error:  obtained from OI algorithm
-	SSS mean bias:  mean of the biases applied over a time interval
(+/-30 for monthly data and +/-10 for weekly data). 
-	SSS std bias:  std of the biases applied over a time interval
(+/-30 for monthly data and +/-10 for weekly data).
-	number of outliers: over a time interval
(+/-30 for monthly data and +/-10 for weekly data).
-	number of data: over a time interval
(+/-30 for monthly data and +/-10 for weekly data).
-	quality flag: =1 if no data over a time interval
-	pct_var:  100x(SSS a posteriori error)²/variability  (%)

The products comply with the data standard of the CCI+ project.

All products can be found here:  https://catalogue.ceda.ac.uk/uuid/9ef0ebf847564c2eabe62cac4899ec41

<b>In case you would like to use them in a presentation or publication, please be aware of the caveats available in the above link.</b>

A DOI has been minted to the dataset: http://dx.doi.org/10.5285/9ef0ebf847564c2eabe62cac4899ec41



