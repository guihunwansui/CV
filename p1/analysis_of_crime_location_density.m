%522370910115 Xintong Liu
T=readtable("Crime_2022.csv","FileType",'text','Delimiter',',','VariableNamingRule','preserve');
%% count the crimes for each community area
Tsort=sortrows(T,"Community Area","ascend");
com_area_num=max(T.("Community Area"));
last_crimes=zeros(com_area_num,1);
for i=1:com_area_num
    if size(find(Tsort.("Community Area")==i,1,"last"))==[0,1]
        last_crimes(i)=last_crimes(i-1);
    else
        last_crimes(i)=find(Tsort.("Community Area")==i,1,"last");
    end
end
com_area_crimes=zeros(com_area_num,1);
com_area_crimes(1)=last_crimes(1);
for i=2:com_area_num
    com_area_crimes(i)=last_crimes(i)-last_crimes(i-1);
end
%% plot the boundary and then add the density
[midlat,midlon]=drawBoundary("CommArea_fixed.csv");
hold on
geolimits("manual");
title("Crime Density of Different Communities","FontSize",28);
geodensityplot(midlat,midlon,com_area_crimes,"FaceColor",'r','HandleVisibility','on');
saveas(gca,"crime_location_density.jpg","jpeg");
