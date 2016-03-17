function data = read_UA02D(data_ffn,skip_wraob,utc_offset)
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland
%
%WHAT:
% Fastest reader of 10second data from the BOM UA02D SIG format on the
% planet. About 0.005 seconds per sounding on my machine.
% skip_wraob (logical) - skip wind raobs
%
%FORMAT:
% snd_data.data#.flight      (1x1 uniq flight number)
%                  .dt          (1x1 datetime number local time (uses utc_offset))
%                  .id          (1x1 bom site id)
%                  .wmo_id      (1x1 wmo site id)
%                  .lat         (1x1 site lat dec degs)
%                  .lon         (1x1 site lon dec degs)
%                  .elev        (1x1 site elevation dec degs)
%                  .pres        (nx1 presure - hpa)
%                  .gpm         (nx1 height - m)
%                  .temp        (nx1 temperature - degC)
%                  .dwpt        (nx1 dew point temperature - degC
%                  .wdir        (nx1 wind direction - degTN)
%                  .wspd        (nx1 wind speed - m/s)
%                  .wraob       (1x1 true for wind only sounding)
%Input
%read entire file to strings
%note: whitespace option preserves leading white spaces
fid     = fopen(data_ffn);
rawtext = textscan(fid, '%s','delimiter', '\n','whitespace',''); rawtext=rawtext{1};
fclose(fid);

%read id and flight time
tmp            = textscan(rawtext{2},'%s','delimiter',' ','MultipleDelimsAsOne',1); tmp=tmp{1};
data.flight    = tmp{3};
data.dt        = addtodate(datenum([tmp{4},'_',tmp{5}],'dd/mm/yyyy_HH:MM'),utc_offset,'hour'); %apply utc offset for local time

%read station number and wmo code
tmp            =  textscan(rawtext{3},'%s','delimiter',' ','MultipleDelimsAsOne',1); tmp=tmp{1};
data.id        = tmp{3};
data.wmo_id    = tmp{6};

%read latlon and height
tmp         = textscan(rawtext{4},'%s','delimiter',' ','MultipleDelimsAsOne',1); tmp=tmp{1};
data.lat    = tmp{3};
data.lon    = tmp{4};
data.site_h = tmp{5};

%Search for 10second data header
data_index = find(strcmp(rawtext,' SIGNIFICANT LEVELS / 10 SECOND DATA '));
data_index = data_index+4; %skip to start of data

%preallocate
empty_vec = nan(length(rawtext)-data_index,1);
pres      = empty_vec;
gpm       = empty_vec;
temp      = empty_vec;
dwpt      = empty_vec;
wdir      = empty_vec;
wspd      = empty_vec;

%extract data
for i=1:length(empty_vec)
    %extract raw text
    rawtext_idx = i+data_index;
    tline       = rawtext{rawtext_idx};
    %convert as necessart
    tmp_pres  = sscanf(tline(1:7),'%f');    if isempty(tmp_pres);  tmp_pres = nan;  end
    tmp_gpm   = sscanf(tline(8:14),'%f');   if isempty(tmp_gpm);   tmp_gpm  = nan;   end
    tmp_temp  = sscanf(tline(15:21),'%f');  if isempty(tmp_temp);  tmp_temp = nan;  end
    tmp_dwpt  = sscanf(tline(22:28),'%f');  if isempty(tmp_dwpt);  tmp_dwpt = nan;  end
    tmp_wdir  = sscanf(tline(41:46),'%f');  if isempty(tmp_wdir);  tmp_wdir = nan;  end
    tmp_wspd  = sscanf(tline(48:53),'%f');  if isempty(tmp_wspd);  tmp_wspd = nan;  end
    % on the second line (first line contains ground obs), if skip_wraob is
    % true decide whether to skip file using temp and dwpt obs (which will
    % be missing if it's a wind raob)
    if i==2 && skip_wraob && isnan(tmp_temp) && isnan(tmp_dwpt)
        %dump data
        data = [];
        %update uder
        display(['*** skipping wraob file'])
        %exit function
        return
    end
    pres(i) = tmp_pres; gpm(i) = tmp_gpm; temp(i) = tmp_temp; dwpt(i) = tmp_dwpt; wdir(i) = tmp_wdir; wspd(i) =  tmp_wspd; 
end

%wrap w_dir
wdir(wdir==360) = 0;

%add to struct
data.pres  = pres;
data.h     = gpm;
data.temp  = temp;
data.dwpt  = dwpt;
data.wdir  = wdir;
data.wspd  = wspd;

%decide if it's a wind only raob
if all(isnan(temp(2:end)))
    data.wraob = true;
else
    data.wraob = false;
end
