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
    sr_dt_list(i) = sr_dataset.(['data',num2str(i)]).dt_local;
end

%build sd dt list
sd_dt_list = nan(length(fieldnames(snd_dataset)),1);
for i=1:length(sd_dt_list)
    sd_dt_list(i) = snd_dataset.(['data',num2str(i)]).dt_utc;
end
%convert to local time
for i=1:length(sd_dt_list)
    sd_dt_list(i) = addtodate(sd_dt_list(i),utc_offset,'hour');
end

%build common sd sr date list
sd_sr_datelist = intersect(unique(floor(sr_dt_list)),unique(floor(sd_dt_list)));

%extract morning time data
[m_vtemp,m_wnd_cmp] = process_profile(sd_sr_datelist,sr_dt_list,sd_dt_list,9);
[m_sr_mean_wdir,~]  = cart2compass(nanmean(m_wnd_cmp.sr_uwnd,1),nanmean(m_wnd_cmp.sr_vwnd,1));
[m_sd_mean_wdir,~]  = cart2compass(nanmean(m_wnd_cmp.sd_uwnd,1),nanmean(m_wnd_cmp.sd_vwnd,1));

%apply sector filters
m_sector1_mask = m_sr_mean_wdir>=s1_min & m_sr_mean_wdir<=s1_max & m_sd_mean_wdir>=s1_min & m_sd_mean_wdir<=s1_max;
m_sector2_mask = m_sr_mean_wdir>=s2_min & m_sr_mean_wdir<=s2_max & m_sd_mean_wdir>=s2_min & m_sd_mean_wdir<=s2_max;

%calc mean vtemp for sb and nonsb days
s1_sr_vtemp  = nanmean(m_vtemp.sr_vtemp(:,m_sector1_mask),2);
s1_sd_vtemp  = nanmean(m_vtemp.sd_vtemp(:,m_sector1_mask),2);
s2_sr_vtemp  = nanmean(m_vtemp.sr_vtemp(:,m_sector2_mask),2);
s2_sd_vtemp  = nanmean(m_vtemp.sd_vtemp(:,m_sector2_mask),2);

s1_sr_wspd  = nanmean(m_wnd_cmp.sr_uwnd(:,m_sector1_mask),2);
s1_sd_wspd  = nanmean(m_wnd_cmp.sd_uwnd(:,m_sector1_mask),2);
s2_sr_wspd  = nanmean(m_wnd_cmp.sr_uwnd(:,m_sector2_mask),2);
s2_sd_wspd  = nanmean(m_wnd_cmp.sd_uwnd(:,m_sector2_mask),2);

%% Plotting
%create h vec
intp_h_vec = [min_h:bin_h:max_h]';

%vtemp
hfig = figure('color','w','position',[1 1 500 500]); hold on; grid on
plot(s1_sr_vtemp,intp_h_vec, 'k-','LineWidth',1)
plot(s1_sd_vtemp,intp_h_vec,'k--','LineWidth',1)
plot(s2_sr_vtemp,intp_h_vec,'k-','LineWidth',2)
plot(s2_sd_vtemp,intp_h_vec,'k--','LineWidth',2)
plot(zeros(length(intp_h_vec)+1,1),[50;intp_h_vec],'k')
xlabel(['\Delta Virtual Temp. ( ','\circ','C)'],'FontSize',14,'FontWeight','demi')
ylabel('Height AMSL (m)','FontSize',14,'FontWeight','demi')
legend({'NE SR','NE SD','SE SR','SE SD'},'FontSize',12,'Location','EastOutside')
set(gca,'FontSize',14,'Xlim',[22,28])
export_fig(hfig,'-dpng','-painters','-r300','-nocrop',[cp_image_path,'hr_vtemp_diff_sector.png']);

%plot wspd


%setup figure
hfig = figure('color','w','position',[1 1 500 500]); hold on; grid on
%
%plot data
plot(s1_sr_wspd,intp_h_vec,'k-','LineWidth',1)
plot(s1_sd_wspd,intp_h_vec,'k--','LineWidth',1)
plot(s2_sr_wspd,intp_h_vec,'k-','LineWidth',2)
plot(s2_sd_wspd,intp_h_vec,'k--','LineWidth',2)
%plot 0 line
plot(zeros(length(intp_h_vec)+1,1),[50;intp_h_vec],'k')
%add annotations and sizing
xlabel('\Delta Wind Speed (m/s)','FontSize',14,'FontWeight','demi')
ylabel('Height AMSL (m)','FontSize',14,'FontWeight','demi')
legend({'NE SR','NE SD','SE SR','SE SD'},'FontSize',12,'Location','EastOutside')
set(gca,'FontSize',14,'Xlim',[0,8])
%export
export_fig(hfig,'-dpng','-painters','-r300','-nocrop',[cp_image_path,'hr_wspd_diff_sector.png']);
