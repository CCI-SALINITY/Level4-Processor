# Level4-Processor

<h3>Level 4 - Year 1, 2 and 3 Processor</h3>

The processing chain used to generate the CRDP for SSS ECV is drawn on next picture. Three entries are used; one for each main satellite data inputs. The CCI+ SMOS L2 processing chain was not used for the two first CRDPs (Y1 and Y2); instead, the data was retrieved from the CATDS production chain (IFREMER/CNES/ESA). This link is now discarded. In Year 3, it was replaced with the full L2 processing chain that has then been setup and activated 

<img src="https://github.com/CCI-SALINITY/Level4-Processor/blob/master/Year3/CCI%20salinity%20production%20chain.png">

Main updates in version 3 of the dataset with respect to version 2 are as follows:

•	SSS from SMOS have been generated from a complete L2 reprocessing with the following updates: OTT correction computed from ISAS-Argo instead of WOA climatology. Specific RFI filtering. ERA5 auxiliary data instead of ECMWF forecasts dataset. Dielectric constant model of [RD-33] (instead of [RD-34] in v2.3). 

•	Ice mask has been computed from SMOS retrieved pseudo dielectric constant (Acard parameter) estimated over the whole period

•	SMOS seasonal latitudinal biases have been computed by using Pacific + Atlantic region (only Atlantic used in v2.3)

•	Instantaneous rain effect has been corrected, relating surface salinity freshening to IMERG rain rate following [RD-32], before estimating bias correction and before L4 merging for SMOS and SMAP SSS. Bulk SSS is now available in the L4 product. 

•	SSS random uncertainty computation has been updated. 

•	Aquarius SSS have been resampled on the EASE 2 grid using an interpolation with a distance weighting (instead of the closest neighbour algorithm in the v2.3)

•	SSS is now provided much closer to coast, but additional pixels are flagged with the same land-sea mask as in v2.3. So, users who wish to ensure using same pixels as in v2.3 should use this flag; users interested in S variability very close to coast, should not apply this flag but should use data close to coast with care.   

•	Representativity uncertainties considering the various spatio-temporal scales covered by the various sensors are taken into account for all sensors (only for Aquarius in v2.3) when estimating L4 fields. 

The L4 processing chain intends to produce:
-	Weekly L4 and
-	Monthly L4

Both products are formatted in netcdf and are in conformance with the data format convention applied on the CCI projects 

<h3>Satellite data</h3>

The main sources of satellite based SSS data are:
-	SMOS (Soil Moisture and Ocean Salinity)
-	AQUARIUS
-	SMAP (Soil Moisture Active Passive)

Other sensor data such AMSR will appear in the next phase of the project (phase 2).

The input data coverage is detailed in the following figure:

<img src="https://github.com/CCI-SALINITY/Level4-Processor/blob/master/Year3/CCI%20salinity%20satellite%20data%201.png">

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

<img src="https://github.com/CCI-SALINITY/Level4-Processor/blob/master/Year2/CCI%20salinity%20full%20production%20chain.png">

The main processing steps are listed hereafter:
1.	Pre-processing of the SSS L2/L3 products from the different sensors; Latitudinal correction and reprojection on the EASE-2 grid
2.	3-sigma filtering and temporal Optimal Interpolation to generate monthly SSS without inter sensor bias removal
3.	3-sigma filtering and temporal Optimal Interpolation to generate weekly SSS without inter sensor bias removal
4.	 Across-track and inter sensor bias removal
5.	3-sigma filtering and temporal Optimal Interpolation to generate monthly SSS. Error propagation
6.	3-sigma filtering and temporal OI to generate weekly SSS using monthly SSS as prior. Error propagation. 

<h3>Output data</h3>

The final Year 3 L4 dataset version is <b>3.21</b>.

The Level 4 products are computed over two time periods:
-	7 days running mean at one day time sampling

Ex: ESACCI-SEASURFACESALINITY-L4-SSS-MERGED_OI_7DAY_RUNNINGMEAN_DAILY_25km-20120104-fv3.21.nc

-	One month at 15 days time sampling centred.

Ex: ESACCI-SEASURFACESALINITY-L4-SSS-MERGED_OI_Monthly_CENTRED_15Day_25km-20160301-fv3.21.nc

The L4 products are formatted in netcdf 4. They contain the following variables:
- monthly and weekly SSS fields : obtained from OI algorithm.
- SSS error : obtained from OI algorithm.
- number of outliers over the considered time interval (+/-30 days for monthly data and +/-10 days for weekly data). 
-	number of data over the considered time interval (+/-30 days for monthly data and +/-10 days for weekly data). 
-	pct_var : 100x(SSS a posteriori error)²/variability  (%).
-	quality flag =1 if the fraction of outliers (n outlier/n data) present over the considered time interval (+/-30 days for monthly data and +/-10 days for weekly data) is larger than 0.1. 
-	flag ice (CCI V2) : SMOS ice detection (Dg_ice descriptor from SMOS L2OS product) is integrated over a period of +/-30 days for monthly data  or +/-10 days for weekly data. If the integrated value is greater than 0, the ice flag is raised. 
-	coast flag (CCI V2): raised if the grid point is far from the coast at a distance less than 50 km


The products comply with the data standard of the CCI+ project.

All products can be found here (version 1):  https://catalogue.ceda.ac.uk/uuid/9ef0ebf847564c2eabe62cac4899ec41

<b>In case you would like to use them in a presentation or publication, please be aware of the caveats available in the above link.</b>

A DOI has been minted to the dataset (version 1): http://dx.doi.org/10.5285/9ef0ebf847564c2eabe62cac4899ec41



