function cp_process
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: loads reprocessed sodar/rass data (use ap-run config file in etc/)
%and UA02D sounding data

%% init
%add lib paths
addpath('../../shared_lib')
addpath('lib')

%read in config
read_config('etc/cp_profile.config','etc/config.mat');
load('etc/config.mat');

%set output ffn for mat file
output_ffn = [out_path,'cp_data_',datestr(now,'yyyymmddHHMM'),'.mat'];
%convert skip_wraob to logical
skip_wraob = logical(skip_wraob);

%% load SODAR/RASS data into daily datafiles

%create struct for sodarrass data
sr_dataset  = struct;

%generate filelisting of sodarrass_path
filelist = dir(sodarrass_path); filelist(1:2) = [];

%load 30min mslp dataset (Archerfield)
%mslp_dataset = read_bom_mslp(mslp_aws_path);

%loop through fielist
for i=50:length(filelist)
    %load data
    tmp_ffn = [sodarrass_path,filelist(i).name];
    %update user
    display(['Processing sodar/rass file:',filelist(i).name]);
    %process file
    sr_dataset = read_sodarrass(tmp_ffn,sr_dataset,site_h);
end
display('SODAR RASS Processing Complete')

%% load UA02D sounding datasets

%create struct for sounding data
snd_dataset  = struct;

%generate filelisting of sodarrass_path
filelist = dir(sounding_path); filelist(1:2) = [];

for i=1:length(filelist)
    %load data
    tmp_ffn = [sounding_path,filelist(i).name];
    %update user
    display(['Processing UA02D file: ',filelist(i).name]);    
    %process file
    dataset  = read_UA02D(tmp_ffn,skip_wraob,utc_offset);
    %add dataset to sounding struct if not empty
    if ~isempty(dataset)
        snd_dataset = adddataset(dataset,snd_dataset);
    end
end
display('UA02D Processing Complete')

%% save to file
save(output_ffn,'snd_dataset','sr_dataset');
display(['cp_process finished, data saved to: ',output_ffn])


