function p = GetRoadCentersFromBikeSim(echo_file)
text = fileread(EchoFilePath(echo_file));
px = GetCoordinate(text,'X'); 
py = GetCoordinate(text,'Y');
p = [px; py; zeros(size(px))].';
p = [zeros(1,3); p];

function road_directory = GetRoadDirectory()
wd = pwd;
idx = strfind(wd,'PhD');
prj_root = strrep(wd(1:(idx(1) + length('PhD') - 1)),'\','/');
bs_root = '/Code/Models/BikeSim2017.1_Data';
road_directory = [prj_root, bs_root];

function echo_file_path = EchoFilePath(echo_file_name)
road_directory = GetRoadDirectory();
echo_file_path = [road_directory, '/', strrep(echo_file_name,'\','/')];

function p = GetCoordinate(text,coord)
matches = regexp(text,[coord,'_SEGMENT_END\(\d,\d\) \S* ;'],'match');
p = cellfun(@(s)str2double(s(strfind(s,')') + 1:end - 1)),matches);
