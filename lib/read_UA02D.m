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
%                  .dt_utc      (1x1 datetime in UTC)
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
data.dt_utc        = datenum([tmp{4},'_',tmp{5}],'dd/mm/yyyy_HH:MM'); %apply utc offset for local time

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
data.tempv = calc_tempv(pres, temp, dwpt);

%decide if it's a wind only raob
if all(isnan(temp(2:end)))
    data.wraob = true;
else
    data.wraob = false;
end

%SHARPPY/shappy/sharptab/thermo.py
function vt=calc_tempv(p, t, td)
%     '''
%     Returns the virtual temperature (C) of a parcel.  If 
%     td is masked, then it returns the temperature passed to the 
%     function.
%     Parameters
%     ----------
%     p : number
%         The pressure of the parcel (hPa)
%     t : number
%         Temperature of the parcel (C)
%     td : number
%         Dew point of parcel (C)
%     Returns
%     -------
%     Virtual temperature (C)
%     '''
eps = 0.62197;
tk  = t + 273.15;
w   = 0.001 .* calc_mixratio(p, td);
vt  = (tk .* (1. + w ./ eps) ./ (1. + w)) - 273.15;

%SHARPPY/shappy/sharptab/params.py
function mixratio=calc_mixratio(p, t)
%     '''
%     Returns the mixing ratio (g/kg) of a parcel
%     Parameters
%     ----------
%     p : number, numpy array
%         Pressure of the parcel (hPa)
%     t : number, numpy array
%         Temperature of the parcel (hPa)
%     Returns
%     -------
%     Mixing Ratio (g/kg) of the given parcel
%     '''
x        = 0.02 .* (t - 12.5 + (7500 ./ p));
wfw      = 1. + (0.0000045 .* p) + (0.0014 .* x .* x);
fwesw    = wfw .* vappres(t);
mixratio = 621.97 .* (fwesw ./ (p - fwesw));

%SHARPPY/shappy/sharptab/params.py
function vp = vappres(t)
%     '''
%     Returns the vapor pressure of dry air at given temperature
%     Parameters
%     ------
%     t : number, numpy array
%         Temperature of the parcel (C)
%     Returns
%     -------
%     Vapor Pressure of dry air
%     '''
pol = t .* (1.1112018e-17 + (t .* -3.0994571e-20));
pol = t .* (2.1874425e-13 + (t .* (-1.789232e-15 + pol)));
pol = t .* (4.3884180e-09 + (t .* (-2.988388e-11 + pol)));
pol = t .* (7.8736169e-05 + (t .* (-6.111796e-07 + pol)));
pol = 0.99999683 + (t .* (-9.082695e-03 + pol));
vp  =  6.1078 ./ pol.^8;
