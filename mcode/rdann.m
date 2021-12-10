function varargout=rdann(varargin)
%
% [ann,anntype,subtype,chan,num,comments]=rdann(recordName, annotator, C, N, N0, AT)
%
%    Wrapper to WFDB RDANN:
%         http://www.physionet.org/physiotools/wag/rdann-1.htm
%
% NOTE: The WFDB Toolbox uses 0 based index, and MATLAB uses 1 based index.
%       Due to this difference annotation values ('ann') are shifted inside
%       this function in order to be compatible with the WFDB native
%       library. The MATLAB user should leave the indexing conversion to
%       the WFDB Toolbox.
%
% Reads a WFDB annotation and returns:
%
%
% ann
%       Nx1 integer vector of the annotation locations in samples
%       with respect to the beginning of the record. 
%       To convert this vector to a string of time stamps see WFDBTIME.
%
% anntype
%       Nx1 character vector describing the annotation types.
%       For a list of standard annotation codes used by PhyioNet, see:
%             http://www.physionet.org/physiobank/annotations.shtml
%
% subtype
%       Nx1 integer vector describing annotation subtype.
%       
% chan
%       Nx1 integer vector describing annotation channel.
%
% num
%       Nx1 integer vector describing annotation NUM.
%
% comments
%       Nx1 cell of strings describing annotation comments.
%
%
% Required Parameters:
%
% recorName
%       String specifying the name of the record in the WFDB path or
%       in the current directory.
%
% annotator
%       String specifying the name of the annotation file in the WFDB path or
%       in the current directory.
%
% Optional Parameters are:
%
% C
%       An integer scalar. Return only the annotations with chan = C.
% N
%       An integer specifying the sample number at which to stop reading the
%       record file. Default read all.
% N0
%       A 1x1 integer specifying the sample number at which to start reading the
%       annotion file. Default = 1, begining of the record.
%
% AT
%       The anntype character. Return only annotations with subtype = S. 
%       Default is empty, which returns all annotations.
%
% Written by Ikaro Silva, 2013
% Last Modified: December 4, 2021 : JVillegas
% Version 2.1.2
% Since 0.0.1
%
% %Example 1- Read a signal and annotation from PhysioNet's Remote server:
%[signal,Fs,tm]=rdsamp('challenge/2013/set-a/a01');
%[ann]=rdann('challenge/2013/set-a/a01','fqrs');
%plot(tm,signal(:,1));hold on;grid on
%plot(tm(ann),signal(ann,1),'ro','MarkerSize',4)
%
%%Example 2- Read annotation from the first 500 samples only
% ann=rdann('mitdb/100','atr',[],500);
%
%
%%Example 3- Read annotations with anntype = 'V' only. 
% annV=rdann('mitdb/100', 'atr', [],[],[],'V');
%
%
% See also wfdbtime, wrann

%endOfHelp

persistent javaWfdbExec config
if(isempty(javaWfdbExec))
    javaWfdbExec=getWfdbClass('rdann');
    [~,config]=wfdbloadlib;
end

wfdb_argument = getargument(varargin{:});

if(nargout <= 1)   
    dataJava=javaWfdbExec.execToDoubleArray([wfdb_argument, '-e']);
    if(config.inOctave)
        dataJava=java2mat(ann);
    end
    varargout = {dataJava};
else
    dataJava=javaWfdbExec.execToStringList(wfdb_argument);
    varargout = parseJavaData(dataJava,nargout); 
end




