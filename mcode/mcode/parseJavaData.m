% Convert Data from Java call into matlab arrays

function varargout = parseJavaData(dataJava, nargs)
    outputs={'ann','anntype','subtype','chan','num','comments'};

    data=dataJava.toArray();
    N=length(data);
    ann=zeros(N,1);
    anntype=[];             % Size to be defined at runtime
    subtype=zeros(N,1);
    chan=zeros(N,1);
    num=zeros(N,1);
    comments=cell(N,1);
    str=char(data(1));
    if(~isempty(strfind(str,'init: can''t open header for record')))
        error(str)
    end
    if(~isempty(str) && strcmp(str(1),'['))
        % Absolute time stamp. Also possibly a date stamp
        % right after the timestamp such as:
        % [00:11:30.628 09/11/1989]      157     N    0    1    0
        % but not always. The following case is also possible:
        % [00:11:30.628]      157     N    0    1    0
        %
        % So we remove the everything between [ * ]  prior to parsing
        for n=1:N
            str=char(data(n));
            if(~isempty(str))
                del_str=findstr(str,']');
                str(1:del_str)=[];
                C=textscan(str,'%d %s %d %d %d',1);
                ann(n)=C{1};
                if(isempty(anntype))
                    T=size(C{2},2);
                    anntype=zeros(N,T);
                end
                CN=length(char(C{2}));
                anntype(n,1:CN)=char(C{2});  
                subtype(n)=C{3};
                chan(n)=C{4}+1; %Convert to MATLAB indexing
                
                if(~isempty(C{5}))
                    num(n)=C{5};
                end
                tabpos=findstr(str,char(9));
                if(tabpos)
                    comments{n}=str(tabpos(1)+1:end);
                end
            end
        end
    else
        %In this case there is only a relative timestamp such as:
        % 0:00.355      355     N    0    0    0
        str=data(1);
        if(~isempty(strfind(str,['annopen: can''t read annotator'])))
            error(str)
        end
        for n=1:N
            str=char(data(n));
            if(~isempty(str))
                C=textscan(str,'%s %d %s %d %d %d',1);
                ann(n)=C{2};
                if(isempty(anntype))
                    T=size(C{3}{:},2);
                    anntype=zeros(N,T);
                end
                CN=length(C{3}{:});
                anntype(n,1:CN)=C{3}{:};
                
                subtype(n)=C{4};
                chan(n)=C{5}+1;%Convert to MATLAB indexing
                
                if(~isempty(C{6}))
                    num(n)=C{6};
                end
                tabpos=findstr(str,char(9));
                if(tabpos)
                    comments{n}=str(tabpos(1)+1:end);
                end
            end
        end
    end
    anntype=char(anntype);

    ann=ann+1; %Convert to MATLAB indexing

    for n=1:nargs
        eval(['varargout{n}=' outputs{n} ';'])
    end
    varargout = {varargout};
end