%  GRIDMAXSEARCH find maximum of function 
%     X = GRIDMAXSEARCH(FUN,XMIN,XMAX,NSTEPS) tests all values of X 
%     in a D-dimensional grid ranging from XMIN to XMAX. XMIN and XMAX 
%     are 1-by-D vectors. NSTEPS defines the number of points in the grid 
%     for each dimension. If NSTEPS is scalar, an equal number of steps
%     is used in each direction. FUN accepts a 1-by-D vector X and returns 
%     a scalar function value F evaluated at X. 
%     
%     X = GRIDMAXSEARCH(FUN,XMIN,XMAX,NSTEPS,LOGARITHMIC) performs
%     logarithmic search where LOGARITHMIC is 1.
% 
% 
%     [X,FVAL] = GRIDMAXSEARCH(FUN,XMIN,XMAX,NSTEPS) also returns the optimal
%     function value FVAL.
%     
%     [X] = GRIDMAXSEARCH(FUN,XMIN,XMAX,NSTEPS,OPTION1,...) passes additional
%     options. Possible options are:
%       'hierarchical' for a hierarchical grid search
%       'display' to display information
%       'plot' to visualise the search
%     
%     
%     Copyright notes
%       This function is part of the ClassificationToolbox
%       Author: Wenzhi Liao, Telin, Ghent University, Belgium
%       Date: 12/11/2009
%     
   

function [x,fval] = gridmaxsearch(fun, xmin, xmax, nsteps, varargin)

    
d = numel(xmin);
if (d==0)||~isequal(size(xmin),size(xmax))
    error('XMIN and XMAX should be non-empty, equal sized vectors');
end
if isscalar(nsteps)
    nsteps = nsteps*ones(size(xmin));
end
nsteps(xmin==xmax) = 1;
if any(nsteps<1)
    error('NSTEPS should be a D-dimensional array of positive integers');
end
if any(xmin(nsteps==1)~=xmax(nsteps==1))
    error('NSTEPS should be larger than 1 where XMIN is different from XMAX');
end
if ~isscalar(nsteps)&&~isequal(size(xmin),size(nsteps))
    size(nsteps)
    size(xmin)
    error('NSTEPS should be scalar or have equal size as XMIN and XMAX');
end
if nargin>4&&isnumeric(varargin{1})
    logarithmic = varargin{1};
else
    logarithmic = 0;
end
xmin = xmin.*(logarithmic==0)+log(max(xmin,eps)).*(logarithmic~=0);
xmax = xmax.*(logarithmic==0)+log(max(xmax,eps)).*(logarithmic~=0);


if any(strcmp(varargin,'display'))
    display = 1;
else
    display = 0;
end

if any(strcmp(varargin,'plot'))
    plot = 1;
    if d>2
	warning('cannot visualize more than 2 dimensions');
	plot = 0;
    end
else
    plot = 0;
end
if plot
    lastplottime = now;
    plottimeinterval = .5;
    h = figure;
    haxis = gca;
end

if any(strcmp(varargin,'hierarchical'))
    hierarchical = 1;
    nlevels = max(1,ceil(max(log2(nsteps-1)-1)));
else
    hierarchical = 0;
    nlevels = 1;
end

fgrid = nan(nsteps(:)');

x0 = (xmin+xmax)/2;

if (numel(fgrid)==1)&&(nargout<2)
    x = x0;
    return
end
    

for l=1:nlevels
    for i=1:numel(fgrid)
	
    
	I = cell(1,d);
	[I{:}] = ind2sub(nsteps(:)',i);
	I = reshape(cell2mat(I),size(nsteps));
	x = xmin + (xmax-xmin)./max(1,nsteps-1).*(I-1);
    
	if hierarchical
        
	    if ~isnan(fgrid(i))
		continue;
	    end
	    nstepslevel = max(5,2^(l+1)+1);
	    step = (nsteps-1)./(nstepslevel-1);
        step(step==0) = 1;
	    if any(round(round((I-1)./step).*step)~=(I-1))
		continue;
	    end
	    if any(reshape(x>(x0+(xmax-xmin)/2/l),1,[]))||any(reshape(x<(x0-(xmax-xmin)/2/l),1,[]))
		continue;
	    end
	end
    
	
	tic;
	fval = fun( x.*(logarithmic==0) + exp(x).*(logarithmic~=0) );
	fgrid(i) = fval;
	t = toc;
	
	if display
	    fprintf('f([');
	    fprintf('%f,', x.*(logarithmic==0) + exp(x).*(logarithmic~=0));
	    fprintf('\b]) = %f  (time = %f s)\n',fval,t);
	end
	
	if plot
	    if (now-lastplottime)>(plottimeinterval/(60*60*24))
		try
            himage = imagesc(fgrid,'Parent',haxis);
%             set(himage,'AlphaData',~isnan(fgrid));
            axis(haxis,'off');
            colorbar('peer',haxis);
            drawnow;
        catch
            warning('unable to plot');
        end
		lastplottime = now;
	    end
	end
    end

    [fval0,i] = max(fgrid(:));
    I = cell(1,d);
    [I{:}] = ind2sub(nsteps(:)',i);
    I = reshape(cell2mat(I),size(nsteps));
    x0 = xmin + (xmax-xmin)./max(1,nsteps-1).*(I-1);
    
end

if plot
    delete(h);
end

fval = fval0;
x = x0;
x = x.*(logarithmic==0) + exp(x).*(logarithmic~=0);
if 1%display
    fprintf('** optimal parameters: f([');
    fprintf('%f,',x);
    fprintf('\b]) = %f\n',fval);
end


