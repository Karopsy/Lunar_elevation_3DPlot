%Code to plot the DEM on a sphere

%% 1. Recover the data of the original DEM and downsize because too big
demPath = '/Users/louis/Desktop/Thèse UCSD/RESEARCH/Old Moon Spacecrafts Study/Lunar_LRO_LOLA_Global_LDEM_118m_Mar2014.tif';

%Take a long time
disp('The DEM is loading...')
% Load DEM and referencing object
[Z, R] = readgeoraster(demPath);
Z = single(Z); % convert to single to save memory
disp('The DEM has finished loading')

scaleFactor = 15; % Default downsampling factor
% Downsample DEM using imresize (requires Image Processing Toolbox)
Z_small = flipud(imresize(Z, 1/scaleFactor, 'bilinear'));

xLimits = R.XWorldLimits;
yLimits = R.YWorldLimits;
rasterSize_small = size(Z_small_flipped);
R_small = maprefcells(xLimits, yLimits, rasterSize_small);

%% 2. 

% Constants
R_moon = 1737.4e3; % Moon radius in meters

% Extract raster size
[nRows, nCols] = size(Z_small);

% Generate world coordinates in projected space (X, Y in meters)
x = linspace(R_small.XWorldLimits(1), R_small.XWorldLimits(2), nCols);
y = linspace(R_small.YWorldLimits(1), R_small.YWorldLimits(2), nRows);

% Generate 2D grids of X and Y
[X_map, Y_map] = meshgrid(x, y);

% Convert from projected X/Y back to longitude and latitude
% Assumes simple equirectangular projection: scale X to lon and Y to lat
% Longitude: [-180, 180], Latitude: [-90, 90]
lon = (X_map / max(abs(R_small.XWorldLimits))) * 180; % scale X
lat = (Y_map / max(abs(R_small.YWorldLimits))) * 90;  % scale Y

% Convert to radians
LonRad = deg2rad(lon);
LatRad = deg2rad(lat);

% Radial distance (elevation above mean radius)
r = R_moon + Z_small;

% Convert spherical to Cartesian
X = r .* cos(LatRad) .* cos(LonRad);
Y = r .* cos(LatRad) .* sin(LonRad);
Z = r .* sin(LatRad);

% Plot the sphere
figure;
surf(X, Y, Z, Z_small, 'EdgeColor', 'none'); % Color by elevation
axis equal;
colormap(parula); % Change if desired
colorbar;
xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');
title('Lunar DEM on 3D Sphere');
lighting gouraud;
camlight headlight;
material dull;
view(3);
