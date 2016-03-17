function cp_mean
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: plots mean reprocessed sodar/rass data (use ap-run config file in etc/)
%and UA02D sounding data

%% init
%add lib paths
addpath('shared_lib')
addpath('shared_lib/export_fig');
addpath('lib')

%read in config
read_config('etc/cp_profile.config','etc/config.mat');
load('etc/config.mat');

%% load/subset data

%load processed mat
load(cp_data_ffn)

%build sr dt list
sr_dt_list = nan(length(fieldnames(sr_dataset)),1);
for i=1:length(sr_dt_list)
    sr_dt_list(i) = sr_dataset.(['data',num2str(i)]).dt;
end

%build snd dt list
snd_dt_list = nan(length(fieldnames(snd_dataset)),1);
for i=1:length(snd_dt_list)
    snd_dt_list(i) = snd_dataset.(['data',num2str(i)]).dt;
end

%build common snd sr date list
snd_sr_datelist = intersect(unique(floor(sr_dt_list)),unique(floor(snd_dt_list)));

%load sb date list
load('shared_datasets/arch_nonsb_days.mat');
sb_datelist = target_days;

%build common snd sr sb date list
sb_sr_snd_datelist = intersect(snd_sr_datelist,sb_datelist);

%init loop
intp_h_vec = [min_h:bin_h:max_h]';
empty_mat  = nan(length(intp_h_vec),length(sb_sr_snd_datelist));
diff_temp  = empty_mat;
diff_dwpt  = empty_mat;

for i=1:length(sb_sr_snd_datelist)
    %update user
    display(['Processing day: ',num2str(i),' of ', num2str(length(sb_sr_snd_datelist))]);
    
    %find nearest index for snd data
    target_dt                 = addtodate(sb_sr_snd_datelist(i),mean_time,'hour');
    [snd_dt_diff,snd_ind]     = min(abs(snd_dt_list-target_dt));

    if snd_dt_diff*24>max_time_diff
        display('skipping, snd time different too large')
        continue
    end
    
    snd_temp   = snd_dataset.(['data',num2str(snd_ind)]).temp;
    snd_dwpt   = snd_dataset.(['data',num2str(snd_ind)]).dwpt;
    snd_site_h = snd_dataset.(['data',num2str(snd_ind)]).site_h;
    snd_h      = snd_dataset.(['data',num2str(snd_ind)]).h + snd_site_h;
    snd_dt     = snd_dataset.(['data',num2str(snd_ind)]).dt;

    %calc mean wind speed in direction of rass
    sr_target_dt = addtodate(target_dt,1,'hour'); %assume mean sea breeze speed of 25km/h or so (can improve)
    [sr_dt_diff,sr_ind]  = min(abs(sr_dt_list-sr_target_dt));

    if sr_dt_diff*24>max_time_diff
        display('skipping, sr time different too large')
        continue
    end
    
    %extract profiles
    sr_temp   = sr_dataset.(['data',num2str(sr_ind)]).temp;
    sr_dwpt   = sr_dataset.(['data',num2str(sr_ind)]).dwpt;
    sr_site_h = sr_dataset.(['data',num2str(sr_ind)]).site_h;
    sr_h      = sr_dataset.(['data',num2str(sr_ind)]).h + sr_site_h;
    sr_dt     = sr_dataset.(['data',num2str(sr_ind)]).dt;

    %% interpolate onto same vertical grid

    %create nan mask
    sr_nan_mask   = isnan(sr_temp)  | isnan(sr_dwpt);
    snd_nan_mask  = isnan(snd_temp) | isnan(snd_dwpt);

    %skip if no sr data exists
    if sum(~sr_nan_mask)<2
        display('missing sr data')
        continue
    end
    
    %interpolate onto standard height vector
    intp_sr_temp  = interp1(sr_h(~sr_nan_mask),sr_temp(~sr_nan_mask),intp_h_vec,'linear',nan);
    intp_sr_dwpt  = interp1(sr_h(~sr_nan_mask),sr_dwpt(~sr_nan_mask),intp_h_vec,'linear',nan);
    intp_snd_temp = interp1(snd_h(~snd_nan_mask),snd_temp(~snd_nan_mask),intp_h_vec,'linear',nan);
    intp_snd_dwpt = interp1(snd_h(~snd_nan_mask),snd_dwpt(~snd_nan_mask),intp_h_vec,'linear',nan);

    diff_temp(:,i) = intp_sr_temp-intp_snd_temp;
    diff_dwpt(:,i) = intp_sr_dwpt-intp_snd_dwpt;

end

%calc mean diff profiles

mean_diff_temp = nanmean(diff_temp,2);
mean_diff_dwpt = nanmean(diff_dwpt,2);

hfig = figure('color','w','position',[1 1 500 700]); hold on; grid on

plot(mean_diff_temp,intp_h_vec,'r','LineWidth',2)
plot(mean_diff_dwpt,intp_h_vec,'b','LineWidth',2)
plot(zeros(length(intp_h_vec),1),intp_h_vec,'k')
xlabel('Difference of SODAR-YBBN (C)','FontSize',14,'FontWeight','demi')
ylabel('Height AMSL (m)','FontSize',14,'FontWeight','demi')
legend({'Temperature','Dew Point'},'Location','NorthWest','FontSize',12)
set(gca,'FontSize',12,'Xlim',[-2,5])
    

export_fig(hfig,'-dpng','-painters','-r300','-nocrop',[cp_image_path,'mean_nonsb.png']);

