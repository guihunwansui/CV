%522370910115 Xintong Liu
T=readtable("Crime_2022.csv","FileType",'text','Delimiter',',','VariableNamingRule','preserve');
%% extract the primary types
Ttype = T(:,'Primary Type');
typecount.type=[""];
typecount.count=[0];
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
%% extract words from description and wordcloud
result=strings(1);
for i=1:height(T)
    char_description=T.Description{i,1};
    char_type=T.("Primary Type"){i,1};
    temp=extractWords(char_description,char_type);
    for k=1:length(temp)
    result=[result;temp{k}];
     end
end
%%
cate=tabulate(result);


descriptions=cate(:,1);
times=cell2mat(cate(:,2));
final=table(descriptions,times);
figure
wordcloud(final,'descriptions','times','Title',"Crime Descriptions for 2022 in Chicago");
% title("Crime Descriptions for 2022 in Chicago","FontSize",28);
saveas(gcf,"crime_description_wordcloud.jpg","jepg");
%% design the extractWords function
function str=extractWords(str_in,type)
    if ~isempty(extract(str_in,type))
        str_out=[extractBefore(str_in,type),extractAfter(str_in,type)];
        str_out=split(str_out);
        a=1;
    else
        str_out=split(str_in);
    end
    str={};
    for i=1:length(str_out)
        if length(str_out{i})>=5
            str{end+1}=str_out{i};
        end
    end

end