%522370910115 Xintong Liu
%After import the crime numbers of each district from location_bubble script, first count the arrest rate of each districts and then plot them with bar
%chart
T=readtable("Crime_2015_to_2022.csv","FileType",'text','Delimiter',',','VariableNamingRule','preserve');
%% import crime numbers
Tsort=sortrows(T,["District","Arrest"],["ascend","descend"]);
%%
district_num=max(T.District,[],"all");
last_crimes=zeros(district_num,1);
for i=1:district_num
    if size(find(Tsort.District==i,1,"last"))==[0,1]
        last_crimes(i)=last_crimes(i-1);
    else
        last_crimes(i)=find(Tsort.District==i,1,"last");
    end
end
district_crimes=zeros(district_num,1);
district_crimes(1)=last_crimes(1);
for i=2:district_num
    district_crimes(i)=last_crimes(i)-last_crimes(i-1);
end
%% count arrest numbers and calculate the arrest rate
arrest_num=zeros(district_num,1);
for i=1:district_num
if i==1
    district_arrest=Tsort(1:district_crimes(1),"Arrest");
    for j=1:height(district_arrest)
    if strcmp(string(cell2mat(district_arrest{j,1})),"false")==1
        arrest_num(i)=j-1;
        break;
    end
    end
else
    district_arrest=Tsort((last_crimes(i-1)+1):last_crimes(i),"Arrest");
    for j=1:height(district_arrest)
    if strcmp(string(cell2mat(district_arrest{j,1})),"false")==1
        arrest_num(i)=j-1;
        break;
    end
    end
end
end
arrest_rate=arrest_num./district_crimes;
%% plot the bar chart
bar(1:31,arrest_rate);
title("Arrest Rate in Different Districts","FontSize",28);
xlabel("District Number","FontSize",18);
ylabel("Arrest Rate","FontSize",18);
saveas(gcf,"Arrest Rate in Different Districts","jpeg");