function [clu, tree] = RunWavClusAlgo(handles)

dim = handles.params.inputs;
fname = handles.params.fname;
fname_in = handles.params.fname_in;

% DELETE PREVIOUS FILES
fileexist = exist([fname '.dg_01.lab'],'file');
if(fileexist~=0)
    delete([fname '.dg_01.lab']);
    delete([fname '.dg_01']);
end

dat = load(fname_in);
n = length(dat);
fid = fopen(sprintf('%s.run',fname),'wt');
fprintf(fid,'NumberOfPoints: %s\n',num2str(n));
fprintf(fid,'DataFile: %s\n',fname_in);
fprintf(fid,'OutFile: %s\n',fname);
fprintf(fid,'Dimensions: %s\n',num2str(dim));
fprintf(fid,'MinTemp: %s\n',num2str(handles.params.mintemp));
fprintf(fid,'MaxTemp: %s\n',num2str(handles.params.maxtemp));
fprintf(fid,'TempStep: %s\n',num2str(handles.params.tempstep));
fprintf(fid,'SWCycles: %s\n',num2str(handles.params.SWCycles));
fprintf(fid,'KNearestNeighbours: %s\n',num2str(handles.params.KNearNeighb));
fprintf(fid,'MSTree|\n');
fprintf(fid,'DirectedGrowth|\n');
fprintf(fid,'SaveSuscept|\n');
fprintf(fid,'WriteLables|\n');
fprintf(fid,'WriteCorFile~\n');
if handles.params.randomseed ~= 0
    fprintf(fid,'ForceRandomSeed: %s\n',num2str(handles.params.randomseed));
end    
fclose(fid);

[str, ~, ~] = computer;
handles.params.system=str;
switch handles.params.system
    case {'PCWIN','PCWIN64'}    
        if exist([pwd '\cluster.exe'],'file') == 0
            directory = which('cluster.exe');
            copyfile(directory,pwd);
        end
        dos(sprintf('cluster.exe %s.run',fname));
    case {'MAC'}
        if exist([pwd '/cluster_mac.exe'],'file') == 0
            directory = which('cluster_mac.exe');
            copyfile(directory,pwd);
        end
        run_mac = sprintf('./cluster_mac.exe %s.run',fname);
	    unix(run_mac);
   case {'MACI','MACI64'}
        if exist([pwd '/cluster_maci.exe'],'file') == 0
            directory = which('cluster_maci.exe');
            copyfile(directory,pwd);
        end
        run_maci = sprintf('./cluster_maci.exe %s.run',fname);
	    unix(run_maci);
   otherwise  %(GLNX86, GLNXA64, GLNXI64 correspond to linux)
        if exist([pwd '/cluster_linux.exe'],'file') == 0
            directory = which('cluster_linux.exe');
            copyfile(directory,pwd);
        end
        run_linux = sprintf('./cluster_linux.exe %s.run',fname);
	    unix(run_linux);
end
        
clu = load([fname '.dg_01.lab']);
tree = load([fname '.dg_01']); 
delete(sprintf('%s.run',fname));
delete *.mag
delete *.edges
delete *.param
delete(fname_in); 
