clear

process_path = dir(fullfile('**/*.*'));

process_path = process_path(cell2mat({process_path.isdir})==1 & ~startsWith({process_path.name},'..') & ~contains({process_path.folder},'git') & ~startsWith({process_path.name},'.git'));


for i = 2:length(process_path)
    copyfile('./.gitkeep',[process_path(i).folder '/.gitkeep'])
    %delete([process_path(i).folder '/.gitignore'])
end