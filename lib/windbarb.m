function [] = windbarb(x_plot,y_plot,u,v,x_scale,y_scale,varargin)
%WINDBARBM Project wind barbs onto map axes
%
%  WINDBARBM(x_plot,y_plot,u,v) projects two dimensional wind barbs onto the 
%  current map axes. The vector components (u,v) are in units of knots and
%  are specified at the points (y_plot,x_plot). It handles winds up to 130 knots.
%  Winds exceeding 130 knots will appear as 130 knots.
%
%  WINDBARBM(x_plot,y_plot,u,v,s) uses the input s to scale the vectors after 
%  they have been automatically scaled to fit within the grid. If omitted, 
%  s = 0.9 is assumed.
%  
%  WINDBARBM(x_plot,y_plot,u,v,'PropertyName',PropertyValue,...) and
%  WINDBARBM(x_plot,y_plot,u,v,s,'PropertyName',PropertyValue,...) uses the 
%  windbarbm object properties specified to display the windbarb objects.
%  The properties supported by windbarbm are the same as the properties
%  supported by linem.
% 
%   
%  MFILE:   windbarbm.m
%  MATLAB:  7.8.0 (R2009a)
%  VERSION: 1.3 (28 November 2011)
%  AUTHOR:  Nick Siler
%  CONTACT: siler@atmos.washington.edu

%Argument tests (from quiverm.m)
if any([ndims(x_plot) ndims(y_plot) ...
        ndims(u)   ndims(v)  ] > 2)
    error(['map:' mfilename ':inputContainsPages'], ...
        'Input data can not contain pages.')

elseif length(x_plot) == 1 && size(x_plot,1) ~= size(u,1)
    error(['map:' mfilename ':invalidLat'], ...
        'y_plot vector input must have row dimension of u.')

elseif length(y_plot) == 1 && size(y_plot,1) ~= size(u,2)
    error(['map:' mfilename ':invalidLon'], ...
        'x_plot vector input must have column dimension of u.')

elseif ~isequal(size(y_plot),size(x_plot),size(u),size(v))
    error(['map:' mfilename ':inconsistentDims'], ...
        'Inconsistent dimensions for inputs.')
end

%check for scale and wind barb property specification
wbproperties = '''color'',''b'''; %default wind barb color is blue.   
%for an odd number of arguments, the first will be the scale factor
for ii = 1:length(varargin)
    if ischar(varargin{ii})
        wbproperties = [wbproperties,',''',varargin{ii},''''];
    else
        wbproperties = [wbproperties,',',num2str(varargin{ii})];
    end
end


%southern hemipshere
v = -v;
u = -u;

umag = sqrt(u.^2+v.^2); %wind speed

%find theta; add pi to atan(v/u) when u<0
dummy = (u<0)*pi;
theta = atan(v./u)+dummy;

[a,b] = size(umag);

%create 18 logical matrices for 18 possible barbs. Non-zero when the barb
%is called for at that gridpoint.
g1 = umag > 7.5 & umag <= 47.5;
g2 = umag > 17.5 & umag <= 47.5;
g3 = umag > 27.5;
g4 = (umag > 37.5 & umag <= 47.5) | (umag > 57.5 & umag <= 97.5);
g5 = umag > 67.5;
g6 = (umag > 77.5 & umag < 97.5) | umag > 107.5;
g7 = umag > 87.5 & umag < 97.5 | umag > 117.5;
g8 = umag > 127.5;
g9 = (umag > 2.5 & umag <= 7.5) | (umag > 12.5 & umag <= 17.5);
g10 = umag > 22.5 & umag <= 27.5;
g11 = (umag > 32.5 & umag <= 37.5) | (umag > 52.5 & umag <= 57.5);
g12 = (umag > 42.5 & umag <= 47.5) | (umag > 62.5 & umag <= 67.5);
g13 = (umag > 72.5 & umag <= 77.5) | (umag > 102.5 & umag <= 107.5); 
g14 = (umag > 82.5 & umag <= 87.5) | (umag > 112.5 & umag <= 117.5);
g15 = (umag > 92.5 & umag <= 97.5) | (umag > 122.5 & umag <= 127.5);
g16 = umag > 47.5;
g17 = umag > 97.5;
g18 = true(a,b);


%position of each barb relative to grid point: [x0 y0; x1 y1]
c1 = [-1 0;-1.125 .325];
c2 = [-.875 0; -1 .325];
c3 = [-.75 0; -.875 .325];
c4 = [-.625 0; -.75 .325];
c5 = [-.5 0; -.625 .325];
c6 = [-.375 0; -.5 .325];
c7 = [-.25 0; -.375 .325];
c8 = [-.125 0; -.25 .325];
c9 = [-.875 0; -.9375 .1625];
c10 = [-.75 0; -.8125 .1625];
c11 = [-.625 0; -.6875 .1625];
c12 = [-.5 0; -.5625 .1625];
c13 = [-.3750 0; -.4375 .1625];
c14 = [-.25 0; -.3125 .1625];
c15 = [-.125 0; -.1875 .1625];
c16 = [-1 0; -.875 .325];
c17 = [-.75 0; -.625 .325];
c18 = [0 0; -1 0];

%set scale based on average latitude spacing
[m,n]=size(y_plot);
%scale = 1;
%scale2 = scale*(max(max(x_plot))-min(min(x_plot)))/n;

%draw the barbs
for nn = 1:18
    eval(['dummy = reshape(g',int2str(nn),',1,a*b);']);
    count = sum(dummy); % number of barbs to draw
    if count == 0
        continue
    end
    
    %rotation operations
    eval(['x1 = c',int2str(nn),'(1,1)*cos(theta)-c',int2str(nn),...
        '(1,2)*sin(theta);']);
    eval(['y1 = c',int2str(nn),'(1,1)*sin(theta)+c',int2str(nn),...
        '(1,2)*cos(theta);']);
    eval(['x2 = c',int2str(nn),'(2,1)*cos(theta)-c',int2str(nn),...
        '(2,2)*sin(theta);']);
    eval(['y2 = c',int2str(nn),'(2,1)*sin(theta)+c',int2str(nn),...
        '(2,2)*cos(theta);']);
    
    x1 = x1*x_scale+x_plot;
    x2 = x2*x_scale+x_plot;
    %multiply y1 and y2 by cos(y_plot) to compensate for the closer spacing of
    %meridians.
    y1 = y1*y_scale.*cos(y_plot*pi/180)+y_plot;
    y2 = y2*y_scale.*cos(y_plot*pi/180)+y_plot;
    x = [reshape(x1(dummy),1,count);reshape(x2(dummy),1,count)];
    y = [reshape(y1(dummy),1,count);reshape(y2(dummy),1,count)];
    eval(['line(x,y,',wbproperties,')']);
end