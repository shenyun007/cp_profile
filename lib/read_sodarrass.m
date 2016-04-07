function sr_dataset = read_sodarrass(data_ffn,sr_dataset,site_h)
%Joshua Soderholm, March 2016
%Climate Research Group, University of Queensland

%WHAT: loads reprocessed sodar/rass data (use ap-run config file in etc/)
%into sr_data struct. Stores every profile seperately as a struct, rather
%creating images of temporal profiles.

%FORMAT:
% sr_dataset.data#.dt_local  (1x1 datetime number local time)
%                 .h         (nx1 height - m)
%                 .site_h    (1x1 site height - m)
%                 .u         (nx1 uwind - m/s)
%                 .u_a       (nx1 assimilated uwind - m/s)
%                 .u_aqc     (nx1 qc assimilated uwind - m/s)
%                 .v         (nx1 vwind - m/s)
%                 .v_a       (nx1 assimilated vwind - m/s)
%                 .v_aqci    (nx1 qc assimilated vwind - m/s)
%                 .w         (nx1 wwind - m/s)
%                 .w_a       (nx1 assimilated wwind - m/s)
%                 .w_aqc     (nx1 qc assimilated wwind - m/s)
%                 .spd       (nx1 wind speed - m/s)
%                 .spd_a     (nx1 assimialted wind speed - m/s)
%                 .dir       (nx1 wind dir - degTN)
%                 .dir_a     (nx1 assimialted wind dir - degTN)
%                 .temp      (nx1 temperature - degC)
%                 .temp_a    (nx1 assimilated temp - degC)
%                 .tempv     (nx1 virtual temp - degC)
%                 .tempv_a   (nx1 assimilated virtual temp - degC)
%                 .tempv_aqc (nx1 assimilated virtual temp qc - degC)
%                 .shr       (nx1 layer wind shear magnitude - (m/s)/m)
%                 .shr_dir   (nx1 layer wind shear direction - degTN)
%                 .z_raw     (nx1 raw backscatter - db)
%                 .pg        (nx1 Pasquill-Gifford Stability - PG(num))
%                 .tke       (nx1 Total Kinetic Energy - m^2/s^2)
%                 .edr       (nx1 Eddy Dissipation rate - m^2/s^3)


%read data_ffn
fid     = fopen(data_ffn);
C       = textscan(fid,'%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','delimiter',',','TreatAsEmpty',{'N/A'});
fclose(fid);
%process dates
data_dt_str  = C{1};
data_dt      = datenum(data_dt_str,'yyyy-mm-dd HH:MM:SS');
data_dt_uniq = unique(data_dt);
%loop through each unique date
for j=1:length(data_dt_uniq)
    %create data struct and mask
    data      = struct;
    data_mask = data_dt==data_dt_uniq(j);
    %extract data for profile
    data.dt_local  = data_dt_uniq(j);
    data.h         = C{2}(data_mask);
    data.site_h    = site_h;
    data.u         = C{3}(data_mask);
    data.u_a       = C{4}(data_mask);
    data.u_aqc     = C{5}(data_mask);
    data.v         = C{6}(data_mask);
    data.v_a       = C{7}(data_mask);
    data.v_aqc     = C{8}(data_mask);
    data.w         = C{9}(data_mask);
    data.w_a       = C{10}(data_mask);
    data.w_aqc     = C{11}(data_mask);
    data.spd       = C{12}(data_mask);
    data.spd_a     = C{13}(data_mask);
    data.dir       = C{14}(data_mask);
    data.dir_a     = C{15}(data_mask);
    data.temp      = C{16}(data_mask);
    data.temp_a    = C{17}(data_mask);
    data.tempv     = C{18}(data_mask);
    data.tempv_a   = C{19}(data_mask);
    data.tempv_aqc = C{20}(data_mask);
    data.shr       = C{21}(data_mask);
    data.shr_dir   = C{22}(data_mask);
    data.z_raw     = C{23}(data_mask);
    data.pg        = C{24}(data_mask);
    data.tke       = C{25}(data_mask);
    data.edr       = C{26}(data_mask);
    %add profile to sr_data
    sr_dataset = adddataset(data,sr_dataset);
end