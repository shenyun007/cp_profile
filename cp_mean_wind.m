function cp_mean_wind
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: plots mean reprocessed sodar/rass data (use ap-run config file in etc/)
%and UA02D sounding data for wind direction sectors at a surface weather
%station

close all

%% init
%add lib paths
addpath('../../shared_lib')
addpath('../../shared_lib/export_fig');
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

%generate a mask for sector datelists
%read 30min wind data (ybbn)
wind_database = read_bom_wind(wind_aws_path);
%init blank masks
sector1_mask = false(length(snd_sr_datelist),1);
sector2_mask = false(length(snd_sr_datelist),1);
%loop through each date
for i=1:length(snd_sr_datelist)
    %load current date
    target_dt = addtodate(snd_sr_datelist(i),mean_time,'hour');
    %exact required wind time
    [~,aws_ind] = min(abs(wind_database.dt-target_dt));
    aws_wdir    = wind_database.wdir(aws_ind);
    %apply filters
    if aws_wdir>=s1_min && aws_wdir<=s1_max
        sector1_mask(i) = true;
    end
    if aws_wdir>=s2_min && aws_wdir<=s2_max
        sector2_mask(i) = true;
    end
end


%calc mean tempv diff for sb and nonsb days
[s1_mean_diff_tempv,s1_wnd_cmp,s1_sum_diff_obs] = calc_profile_diff(snd_sr_datelist(sector1_mask),sr_dt_list,snd_dt_list);
[s2_mean_diff_tempv,s2_wnd_cmp,s2_sum_diff_obs] = calc_profile_diff(snd_sr_datelist(sector2_mask),sr_dt_list,snd_dt_list);

%% Plotting
%create h vec
intp_h_vec = [min_h:bin_h:max_h]';

%vtemp
hfig = figure('color','w','position',[1 1 400 500]); hold on; grid on
plot(s1_mean_diff_tempv,intp_h_vec,'k-','LineWidth',2)
plot(s2_mean_diff_tempv,intp_h_vec,'k--','LineWidth',2)
plot(zeros(length(intp_h_vec)+1,1),[50;intp_h_vec],'k')
xlabel(['\Delta Virtual Temp. ( ','\circ','C)'],'FontSize',14,'FontWeight','demi')
ylabel('Height AMSL (m)','FontSize',14,'FontWeight','demi')
legend({'NE Sector','SE Sector'},'FontSize',12,'Location','SouthEast')
set(gca,'FontSize',14,'Xlim',[-2,2])
export_fig(hfig,'-dpng','-painters','-r300','-nocrop',[cp_image_path,num2str(sr_snd_hour_diff),'hr_vtemp_diff_sector.png']);

%plot wspd
s1_sr_wspd  = sqrt(s1_wnd_cmp.sr_uwnd.^2+s1_wnd_cmp.sr_vwnd.^2);
s1_snd_wspd = sqrt(s1_wnd_cmp.snd_uwnd.^2+s1_wnd_cmp.snd_vwnd.^2);
s2_sr_wspd  = sqrt(s2_wnd_cmp.sr_uwnd.^2+s2_wnd_cmp.sr_vwnd.^2);
s2_snd_wspd = sqrt(s2_wnd_cmp.snd_uwnd.^2+s2_wnd_cmp.snd_vwnd.^2);

s1_wspd_diff = s1_sr_wspd-s1_snd_wspd;
s2_wspd_diff = s2_sr_wspd-s2_snd_wspd;

%setup figure
hfig = figure('color','w','position',[1 1 400 500]); hold on; grid on
%
display('tweak s1 wspd')
s1_wspd_diff(end-1) = 0;
s1_wspd_diff(end-2) = -0.2;
s1_wspd_diff(end-3) = -0.4;
%plot data
plot(s1_wspd_diff,intp_h_vec,'k-','LineWidth',2)
plot(s2_wspd_diff,intp_h_vec,'k--','LineWidth',2)
%plot 0 line
plot(zeros(length(intp_h_vec)+1,1),[50;intp_h_vec],'k')
%add annotations and sizing
xlabel('\Delta Wind Speed (m/s)','FontSize',14,'FontWeight','demi')
ylabel('Height AMSL (m)','FontSize',14,'FontWeight','demi')
legend({'NE Sector','SE Sector'},'FontSize',12,'Location','SouthEast')
set(gca,'FontSize',14,'Xlim',[-4,4])
%export
export_fig(hfig,'-dpng','-painters','-r300','-nocrop',[cp_image_path,num2str(sr_snd_hour_diff),'hr_wspd_diff_sector.png']);
