# Software for L4 product generation.CCI+SSS (year2)

# aux_files 
is the sub-directory which contains the auxiliary files required as input for other routines

(auxiliary files are not part of the source in github)

* latlon_ease.mat : EASE grid specification
* maskdmin_ease2.mat : EASE GP distance from coast
* SM_OPER_AUX_MINMAX_20050909T023037_20500101T000000_624_001_2.nc : SSS variability and SSS min/max values
* ERR_REP_50km1d_50km30d_smooth.mat : representativity error from Mercator (+ smoothing) between maps at 50km-1d resolution and maps at 50km-30d
* ERR_REP_150km7d_50km30d_smooth.mat : representativity error from Mercator (+ smoothing) between maps at 150km-7d resolution and maps at 50km-30d  (Aquarius)
* isas_CATDS : SAS15 and NRT projected on EASE grid
* smos_isas_rmsd_ease_smooth.mat : rmsd of SSS from SMOS and ISAS data on EASE grid.
* smosA_20140101.mat : contains xswath specification
* corrSSS.mat : contains data allowing SMOS latitudinal correction (SMOS CATDS CECv3)
* corrSSS_v5.mat : contains data allowing SMOS latitudinal correction (SMOS CATDS CECv4)
* mask_smos.mat : masque terre-mer SMOS

# corr_lat_function 
is the directory containing the programs allowing to apply latitudinal correction on SMOS data

* L3OS_moyenne_main_xswath_SSS_SST_v4.m : program for computing SMOS SSS monthly fields at different xswath
* choix_dwell_ref_SST_v5.m : program for latitudinal bias estimation for SMOS data
* corr_biaisLAT_L2_SST.m : program which applies SST and latitudinal correction for SMOS data

# merge_product_function 
is the sub-directory which contains the program allowing merging products (SMOS L2, Aquarius L3 and SMAP L2)

* compute_biais_CCI.m : program which computes intersensor biases and monthly and weekly SSS fields.


# read_function 
is the sub-directory which contains reading programs (SMOS L2, Aquarius L3 and SMAP L2). These functions read formatted products provided by the different agencies and project the data on a common EASE grid.

* lecL2_SMAP.m : program for SMAP L2 product reading. Projection over the EASE grid
* lecL2_SMOS.m : program for SMOS L2 product reading.
* lecL3_AQUARIUS.m : program for Aquarius L3 product reading. Projection over the EASE grid

# write_function 
contains L4 product writing program. 

* write_CONF.m : program for conf report writing
* prepare_data_linux_v6.m : program for L4 netcdf product writing


