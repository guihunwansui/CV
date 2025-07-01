%522370910115 Xintong Liu
%first extract every point (lat,lon) in string, then split them into two
%num array lat and lon and draw the boundary.
function [midlat,midlon]=drawBoundary(filename)
T=readtable(filename,"FileType",'text','Delimiter',',','VariableNamingRule','preserve');
%%
for i=1:height(T)
    boundary_points=[];
    str_points=cell2mat(T.the_geom(i));
    str_points_sepa=split(str_points(17:end-3),',');
for j=1:length(str_points_sepa)
    str_points_lat_lon=split(str_points_sepa(j),' ');
    if j>=2
        str_points_lat_lon(1)=[];
    end
    boundary_points=[boundary_points;str2double(str_points_lat_lon)'];
end
    boundary_points=[boundary_points;boundary_points(1,:)];
    lat=boundary_points(:,2);
    lon=boundary_points(:,1);
    midlat(i)=((max(lat)+min(lat))/2);
    midlon(i)=((max(lon)+min(lon))/2);
    geoplot(lat,lon,'b-')
    text(midlat(i),midlon(i),num2str(T.AREA_NUMBE(i)));
    hold on
end

end