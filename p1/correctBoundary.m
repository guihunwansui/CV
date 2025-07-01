%522370910115 Xintong Liu
%find the unexpected character through binary_search function and delete
%the following data points and export the new table
function correctBoundary(filename)
T=readtable(filename,"FileType",'text','Delimiter',',','VariableNamingRule','preserve');
h_T=height(T);
str=string(1);
flr=17;% the floor num for binary search
Tout=T;
for i=1:h_T
    str=cell2mat(T.the_geom(i));
    ceil=length(str)-3;
    idx=binary_search(str,flr,ceil);
    if idx==-1
        continue;
    else
        Tout.the_geom(i)={str(1:(idx-1))};
    end
    writetable(Tout,"CommArea_fixed.csv",'Delimiter',',','QuoteStrings',true);
end
end

function idx=binary_search(str,flr,ceil)
    if flr==ceil
        idx=flr;
        return;
    end    
    mid=floor((flr+ceil)/2);
    [splitstr,judge]=str2num(str(flr:mid));
    if judge==0
        idx=binary_search(str,flr,mid);
    else
        [splitstr,judge]=str2num(str((mid+1):ceil));
        if judge==0
            idx=binary_search(str,mid+1,ceil);
        else
            idx=-1;
        end
    end
end