Crime=readtable('Crime_2022.csv','FileType','text', 'Delimiter', ',','VariableNamingRule','preserve');
Map=readtable('CommArea_fixed.csv');
Crime=sortrows(Crime,'Community Area');
Map=sortrows(Map,'AREA_NUM_1');
pre=0;
count=[];
for i=1:height(Crime)
    k=Crime{i,'Community Area'};
    if pre==k
        count(end)=count(end)+1;
    else
        pre=k;
        count(end+1)=1;
    end
end
%%
[poslat,poslon]=drawBoundary(Map);
hold on;
geodensityplot(poslat,poslon,count);
title("Crime density of different communities");
geolimits('auto');
ax=gca;
exportgraphics(ax,'crime_location_density.jpg');

    