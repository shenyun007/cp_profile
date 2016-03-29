function cp_mean_sb
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: plots mean reprocessed sodar/rass data (use ap-run config file in etc/)
%and UA02D sounding data for sea/nonsb days

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

%load sb date list
load('../../shared_datasets/arch_sb_days.mat');
sb_datelist = target_days;
load('../../shared_datasets/arch_nonsb_days.mat');
nonsb_datelist = target_days;

%build common snd sr sb date list
sb_sr_snd_datelist    = intersect(snd_sr_datelist,sb_datelist);
nonsb_sr_snd_datelist = intersect(snd_sr_datelist,nonsb_datelist);

%calc mean tempv diff for sb and nonsb days
[sb_mean_diff_tempv,sb_wnd_cmp,sb_sum_diff_obs]          = calc_profile_diff(sb_sr_snd_datelist,sr_dt_list,snd_dt_list);
[nonsb_mean_diff_tempv,nonsb_wnd_cmp,nonsb_sum_diff_obs] = calc_profile_diff(nonsb_sr_snd_datelist,sr_dt_list,snd_dt_list);

%% Plotting
%create h vec
intp_h_vec = [min_h:bin_h:max_h]';

%plot vtemp
%setup figure
hfig = figure('color','w','position',[1 1 500 600]); hold on; grid on
%plot data
plot(sb_mean_diff_tempv,intp_h_vec,'k-','LineWidth',2)
plot(nonsb_mean_diff_tempv,intp_h_vec,'k--','LineWidth',2)
%plot 0 line
plot(zeros(length(intp_h_vec),1),intp_h_vec,'k')
%add annotations and sizing
xlabel('vtemp diff of SODAR-YBBN (C)','FontSize',14,'FontWeight','demi')
ylabel('Height AMSL (m)','FontSize',14,'FontWeight','demi')
legend({'SB Days','nonSB Days'},'FontSize',12)
set(gca,'FontSize',12,'Xlim',[-1,6])
%export
export_fig(hfig,'-dpng','-painters','-r300','-nocrop',[cp_image_path,num2str(sr_snd_hour_diff),'hr_vtemp_diff_sb.png']);

%plot wspd
sb_sr_wspd     = sqrt(sb_wnd_cmp.sr_uwnd.^2+sb_wnd_cmp.sr_vwnd.^2);
sb_snd_wspd    = sqrt(sb_wnd_cmp.snd_uwnd.^2+sb_wnd_cmp.snd_vwnd.^2);
nonsb_sr_wspd  = sqrt(nonsb_wnd_cmp.sr_uwnd.^2+nonsb_wnd_cmp.sr_vwnd.^2);
nonsb_snd_wspd = sqrt(nonsb_wnd_cmp.snd_uwnd.^2+nonsb_wnd_cmp.snd_vwnd.^2);

sb_wspd_diff    = sb_sr_wspd-sb_snd_wspd;
nonsb_wspd_diff = nonsb_sr_wspd-nonsb_snd_wspd;

%setup figure
hfig = figure('color','w','position',[1 1 500 600]); hold on; grid on
%plot data
plot(sb_wspd_diff,intp_h_vec,'k-','LineWidth',2)
plot(nonsb_wspd_diff,intp_h_vec,'k--','LineWidth',2)
%plot 0 line
plot(zeros(length(intp_h_vec),1),intp_h_vec,'k')
%add annotations and sizing
xlabel('wspd diff of SODAR-YBBN (m/s)','FontSize',14,'FontWeight','demi')
ylabel('Height AMSL (m)','FontSize',14,'FontWeight','demi')
legend({'SB Days','nonSB Days'},'FontSize',12)
set(gca,'FontSize',12,'Xlim',[-5,6])
%export
export_fig(hfig,'-dpng','-painters','-r300','-nocrop',[cp_image_path,num2str(sr_snd_hour_diff),'hr_wspd_diff_sb.png']);
