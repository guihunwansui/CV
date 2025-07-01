%522370910115 Xintong Liu
T=readtable("Crime_2022.csv","FileType",'text','Delimiter',',','VariableNamingRule','preserve');
%% count the crimes in certain district with a sorted table by districts and recorded the lat and lon of the last case in the district
Tsort=sortrows(T,"District","ascend");
district_num=max(T.District,[],"all");
last_crimes=zeros(district_num,1);
latvar=zeros(district_num,1);
lonvar=zeros(district_num,1);
for i=1:district_num
    if size(find(Tsort.District==i,1,"last"))==[0,1]
        last_crimes(i)=last_crimes(i-1);
        latvar(i)=NaN;
        lonvar(i)=NaN;
    else
        last_crimes(i)=find(Tsort.District==i,1,"last");
        latvar(i)=Tsort.Latitude(last_crimes(i));
        lonvar(i)=Tsort.Longitude(last_crimes(i));
    end
end
district_crimes=zeros(district_num,1);
district_crimes(1)=last_crimes(1);
for i=2:district_num
    district_crimes(i)=last_crimes(i)-last_crimes(i-1);
end
%% plot
s_latvar=single(latvar);
s_lonvar=single(lonvar);
district_code=categorical((1:district_num)');
T_geo=table(district_crimes,s_latvar,s_lonvar,district_code,bubblecolor);
gb=geobubble(T_geo,"s_latvar","s_lonvar","SizeVariable","district_crimes","ScalebarVisible","on","ColorVariable","district_code","BubbleWidthRange",[5,25]);
disp(gb);
title(gb,"Crime Distribution for 2022 in Chicago");
gb.SizeLegendTitle = 'Number of Crimes in 2022';
saveas(gcf,"crime_distribution_bubble.jpg","jpeg");