%522370910115 Xintong Liu
T=readtable("Crime_2015_to_2022.csv","FileType",'text','Delimiter',',','VariableNamingRule','preserve');
Ttype = T(:,'Primary Type');
%%
typecount.type=[""];
typecount.count=[0];

%count all the types. If not in list, add the type into typecount.type.
for i=1:height(T)
    str=string(table2array(Ttype(i,1)));
    if ~(str==typecount.type)
        typecount.type=[typecount.type,str];
        typecount.count=[typecount.count,1];
    else 
        idx=find(typecount.type==str);
        typecount.count(idx)=typecount.count(idx)+1;
    end
end
%%
%find the top ten types and sum the others
type_count=typecount.count;
index=zeros(10,1);%find the index of top ten types
for j=1:10
[cnt,index(j)]=max(type_count,[],"all");
type_count(index(j))=0;
end
top_ten_count=typecount.count(index);
top_ten_type=typecount.type(index);
others_count=sum(type_count);
all_count=[top_ten_count,others_count];
all_types=[top_ten_type,'others'];
%%
%plot the pie chart
pie(all_count,all_types);
title('Crime Types over 2015-2022 in Chicago',"FontSize",28); 
legend(all_types,"FontSize",10,"Location","northwestoutside");
saveas(gcf, 'crime_type_pie.jpg', 'jpeg');