%Defines arguments for Java Class wrapper
%Based on Code by Ikaro Silva, 2013
%Juan Villegas, December 2021

function varargout = getargument(varargin)

%Set default pararamter values
% [ann, anntype, subtype, chan, num, comments] = rdann(recordName, annotator, C, N, N0, AT)
inputs={'recordName','annotator','C','N','N0','AT'};

N=[];
N0=[];
C=[];
AT=[];
for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end

%Remove file extension if present
if(length(recordName)>4 && strcmp(recordName(end-3:end),'.dat'))
    recordName=recordName(1:end-4);
end

args={'-r',recordName,'-a',annotator};

if(~isempty(N0) && N0>1)
    %-1 is necessary because WFDB is 0 based indexed.
    %RDANN expects timestamp, so convert from sample to timestamp
    start_time=wfdbtime(recordName,N0-1);
    if(~isempty(start_time{end}))
        args{end+1}='-f';
        args{end+1}=[start_time{1}];
    else
        error(['Could not get record header information to find start time.'])
    end
    
end

if(~isempty(N))
    %-1 is necessary because WFDB is 0 based indexed.
    %RDANN expects timestamp, so convert from sample to timestamp
    end_time=wfdbtime(recordName,N-1);
    if(~isempty(end_time{end}))
        args{end+1}='-t';
        args{end+1}=[end_time{1}];
    else
        error(['Could not get record header information to find stop time.'])
    end
end

if(~isempty(AT))
    args{end+1}='-p';
    %-1 is necessary because WFDB is 0 based indexed.
    args{end+1}=AT;
end

if(~isempty(C))
    varargout{end+1}='-c ';
    %-1 is necessary because WFDB is 0 based indexed.
    args{end+1}=[num2str(C-1)];
end

varargout = {args};