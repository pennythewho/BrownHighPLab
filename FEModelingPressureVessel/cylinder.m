% This script is written and read by pdetool and should NOT be edited.
% There are two recommended alternatives:
 % 1) Export the required variables from pdetool and create a MATLAB script
 %    to perform operations on these.
 % 2) Define the problem completely using a MATLAB script. See
 %    http://www.mathworks.com/help/pde/examples/index.html for examples
 %    of this approach.
function pdemodel
[pde_fig,ax]=pdeinit;
pdetool('appl_cb',9);
set(ax,'DataAspectRatio',[1 1 1]);
set(ax,'PlotBoxAspectRatio',[1.5 1 1]);
set(ax,'XLim',[-1.5 1.5]);
set(ax,'YLim',[-1 1]);
set(ax,'XTickMode','auto');
set(ax,'YTickMode','auto');

% Geometry description:
pderect([-1 -0.29999999999999999 0.80000000000000004 -0.80000000000000004],'R1');
pderect([-1 -0.29999999999999999 0.80000000000000004 1],'R2');
set(findobj(get(pde_fig,'Children'),'Tag','PDEEval'),'String','R1+R2')

% Boundary conditions:
pdetool('changemode',0)
pdesetbd(7,...
'neu',...
1,...
'0',...
'0')
pdesetbd(6,...
'neu',...
1,...
'0',...
'0')
pdesetbd(5,...
'neu',...
1,...
'0',...
'0')
pdesetbd(4,...
'dir',...
1,...
'1',...
'100')
pdesetbd(2,...
'dir',...
1,...
'1',...
'20')
pdesetbd(1,...
'neu',...
1,...
'0',...
'0')

% Mesh generation:
setappdata(pde_fig,'Hgrad',1.3);
setappdata(pde_fig,'refinemethod','regular');
setappdata(pde_fig,'jiggle',char('on','mean',''));
setappdata(pde_fig,'MesherVersion','preR2013a');
pdetool('initmesh')
pdetool('refine')
pdetool('refine')

% PDE coefficients:
pdeseteq(1,...
'100*x!1*x',...
'0!0',...
'(0)+(0).*(0.0)!(0)+(0).*(0.0)',...
'(1.0).*(1.0)!(1.0).*(1.0)',...
'0:10',...
'0.0',...
'0.0',...
'[0 100]')
setappdata(pde_fig,'currparam',...
['1.0!1.0  ';...
'1.0!1.0  ';...
'100*x!1*x';...
'0!0      ';...
'0!0      ';...
'0.0!0.0  '])

% Solve parameters:
setappdata(pde_fig,'solveparam',...
char('0','3312','10','pdeadworst',...
'0.5','longest','0','1E-4','','fixed','Inf'))

% Plotflags and user data strings:
setappdata(pde_fig,'plotflags',[1 1 1 1 2 1 1 1 0 0 0 1 0 1 0 0 0 1]);
setappdata(pde_fig,'colstring','');
setappdata(pde_fig,'arrowstring','');
setappdata(pde_fig,'deformstring','');
setappdata(pde_fig,'heightstring','');

% Solve PDE:
pdetool('solve')
