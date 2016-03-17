function [RH,Tdp] = calc_sr_humidity(data_T,data_Tv,data_z,site_h)
%Joshua Soderholm, March 2016
%Climate Research Group, University of Queensland

%WHAT: Function Used to Calcualte Humidity for sodar/rass data using fundamental CC equations

%Define Constants
g         = 9.81;
M         = 0.0289644;
R         = 8.31447;
Po        = 101.325;
To_temp   = 288.15;
kb        = 1.3806503*10^-23;
data_T_K  = data_T + 273.15;
data_Tv_K = data_Tv + 273.15;
% Find Pressure
for i=1:numel(data_z)
    h = data_z(i) + site_h;
    To_temp = data_T_K(i);
    P(i,1) = Po*(288.15/To_temp).^(-5.255877);
end
% calc RH
es = 6.11*(10.^((7.5*data_T)./(data_T +237.7)));
ws = 0.621*(es./P);
w = ((data_Tv./data_T)-1)./0.611;
RH = (w./ws) * 100;
%Remove elments over 100%
RH(find(RH > 100)) = NaN;
Tdp = ((RH/100).^(1/8)).*(112+0.9*data_T)+(0.1*data_T)-112;