% trying out movie stuff
%
% ds 2024-02-27
%
%
% ** make sure we are running on the correct arch!
%
% octave:54> system('arch')
% i386
% 
% matlab>>!arch
% i386

% local movie stimuli from a Vogels lab study
% todo - add our own / centrally available resources?% 
% dname = '/Users/lpzds1/data/vogels-face-patch-data/Stimuli/dynamic_bodies/'
dname = '/Users/lpzds1/data/rich_movies/'

% if somewhere else, use local folder...
if ~exist(dname,'dir'), dname = '.'; end

cwd = pwd()

files = dir([dname filesep '*.avi'])

nMovies = numel(files)
iMovie = randi(nMovies);
% gotcha: https://stackoverflow.com/a/22776389

% ffmpeg -i ${fname} -c:v copy -c:a copy ${fname%%.avi}.mp4
theMovie = [files(iMovie).folder filesep files(iMovie).name];
fprintf('Trying %s', theMovie)
PlayMoviesDemo(theMovie)
