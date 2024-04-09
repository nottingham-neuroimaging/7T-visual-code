% ptbSearchHelp - grep ptb code for occurrences of string
%
%      usage: [  ] = ptbSearchHelp( expression )
%         by: denis schluppeck
%       date: 2024-04  (original code 2008-07-31)
%       
%     inputs: expression ; string or cell array of strings
%             options ; command line options to grep
%    outputs: 
%
%    purpose: it's sometimes helpful to search through all the code in
%    psychtoolbox to  look  for  occurrences of  functions,
%    strings, etc. This function  makes use of a matlab implementation
%    of the unix utility GREP.
%
%    help grep % for further info on regexp and options
%
%        e.g: ptbSearchHelp('FillRect')
%            
%            
function [  ] = ptbSearchHelp( expression, options )

if nargin < 2
  % '-r -l ;
  % options = '-If \.m$ -r -u -n';
  options = '-I -i -r -u -n';

end

if nargin < 1
  help ptbSearchHelp
  return
end

% directory above functionts
ptbpath = PsychtoolboxRoot(); % [fileparts(ptblocation) '/../' ];

% create a line separator
sep=@(x) disp(sprintf(repmat('-',1,75)));

sep();


if true() % for now debug with system grep .... ~exist('grep')==2
  disp('(ptbSearchHelp) the matlab grep function is not installed')
  disp('see http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=9647')
  disp('trying system grep instead...')
  assert(~iscell(expression), 'Cell array input not implemented yet!');

  cmd = sprintf('grep %s %s %s', options, expression, ptbpath)
  disp(cmd)
  fl = system(cmd);
  sep();
  return
end

if iscell(expression)
   fl = grep([ options ' -e'],expression{:}, ptbpath)
elseif isstr(expression)
    fl = grep({[ options ' -e'],expression, ptbpath})
else
    disp('(uhoh) expression needs to be a string or cell array of strings!')
end
sep();
end
