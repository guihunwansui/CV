%522370910115 Xintong Liu
accu_crimes=zeros(8,1);
T=readtable("Crime_2015_to_2022.csv","FileType",'text','Delimiter',',','VariableNamingRule','preserve');
Tsort=sortrows(T,18,'ascend');
h_T=height(T);
%% use accumulated numbers to subtract the number before to get the yearly number
for i=1:8
accu_crimes(i)=find(Tsort.Year==i+2014,1,"last");
end
yearly_crimes=zeros(8,1);
yearly_crimes(1)=accu_crimes(1);
for i=2:8
yearly_crimes(i)=accu_crimes(i)-accu_crimes(i-1);
end
%% plot
    Year=2015:2022;
    bar(Year,yearly_crimes);
    legend("Yearly Number of Crimes","Location","north");
    xlabel("Year","FontSize",18);
    ylabel("Yearly Number of Crimes","FontSize",18);
    title("Yearly Number of Crimes over 2015-2022 in Chicago","FontSize",28);
    set(gca,'FontSize',16);
    saveas(gcf,"Yearly_crimeNumber_bar.jpg","jpeg")