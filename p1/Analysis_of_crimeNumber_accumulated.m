%522370910115 Xintong Liu
%sort the table by years
accu_crimes=zeros(8,1);
T=readtable("Crime_2015_to_2022.csv","FileType",'text','Delimiter',',','VariableNamingRule','preserve');
Tsort=sortrows(T,18,'ascend');
h_T=height(T);
%% store the accumulated crime number
for i=1:8
accu_crimes(i)=find(Tsort.Year==i+2014,1,"last");
end
%% plot
    Year=2015:2022;
    plot(Year,accu_crimes);
    legend("Accumulated Crimes","Location","best");
    xlabel("Year","FontSize",18);
    ylabel("Accumulated Crimes","FontSize",18);
    title("Accumulated Crimes over 2015-2022 in Chicago","FontSize",28);
    set(gca,'FontSize',16);
    saveas(gcf,"Accumulated_crimeNumber_line.jpg","jpeg");