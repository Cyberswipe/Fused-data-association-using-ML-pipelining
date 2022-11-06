%  CLASSIFIER creates an object for image classification purposes
%     OBJ = CLASSIFIER(TYPE) creates a classifier object of type TYPE. TYPE
%     refers to a directory with basic classification functions. These
%     functions have TYPE as prefix and should include: train, sim and
%     parameters. Possible values for TYPE are: svm, ann, ...
%
%
%     OBJ = TRAIN(OBJ,INPUT,LABELS,MASK) trains the classifier
%     OUT = CLASSIFY(OBJ,INPUT,MASK) classifies the input image
%     
%     Copyright notes
%       This function is part of the ClassificationToolbox
%       Author: Wenzhi Liao, Telin, Ghent University, Belgium
%       Date: 12/11/2009
%     

classdef Classifier

    properties (Access = private)
	type;
	normpars;
	model;
	validationmethod;
	
	optimfun;
    end


    methods
	function obj = Classifier(type)
        addpath(fullfile(fileparts(mfilename('fullpath')),type));
	    obj.type = type;
	    obj.optimfun = @gridmaxsearch;
	    obj.validationmethod = 'spatialcrossvalidation';
	end
	
	function obj = train(obj,input,labels,mask,modelparameters)
	    [input,obj.normpars] = Classifier.normalize(input);
	    trainfun = str2func([obj.type 'train']);
	    simfun = str2func([obj.type 'sim']);

if strcmp(obj.type,'dectree')
traininput = input;
trainlabels = labels;
else
        input = reshape(input,[],size(input,3));
        trainI = find( (mask>0)&(labels>0) );
        trainI = trainI(:);
        traininput = reshape(input(trainI,:),length(trainI),1,[]);
        trainlabels = labels(trainI);
end        
	    trainFcn = @(m,modelpars)trainfun(traininput,trainlabels,m,modelpars);
	    evalFcn = @(model,evalmask)Classifier.evaluate(simfun,model,traininput,trainlabels,evalmask);

        if nargin<5
            switch obj.validationmethod
            case {'spatialcrossvalidation','crossvalidation'}
                Ndivisions = 10;
                type = obj.validationmethod(1:7);
                Nsmalltrain = 1000;
                Fsmalltrain = Nsmalltrain/sum(sum((mask>0)&(labels>0)));
                masks = Classifier.dividetraindata(mask>0,type,Ndivisions);
                submask = mask&(rand(size(mask))<Fsmalltrain);
                for i=1:length(masks)
                    masks{i}(~submask&masks{i}==1) = 0;% = masks{i}.*submask;
if ~strcmp(obj.type,'dectree')
                    masks{i} = masks{i}(trainI);
end
                end
                
                perfFcn = @(modelpars)mean(arrayfun(@(i)evalFcn(trainFcn(masks{i}==1,modelpars),masks{i}==2),1:Ndivisions));
            otherwise
                error('unknown validation method');
            end
	    
            [parmin,parmax,nsteps,logarithmic] = feval([obj.type 'parameters']);
            optPar = obj.optimfun(perfFcn,parmin,parmax,nsteps,logarithmic,'hierarchical');
        else
            optPar = modelparameters;
        end
    
        Nlargetrain = 10000;
        Flargetrain = 1;%Nlargetrain/sum(sum((mask>0)&(labels>0)));
        fulltrainmask = (mask>0)&(rand(size(mask))<Flargetrain);
if ~strcmp(obj.type,'dectree')
        fulltrainmask = fulltrainmask(trainI);
end

        obj.model = trainFcn(fulltrainmask,optPar);
	
    end
    
    function out = classify(obj,input,mask)
        if isempty(obj.model)
            error('Classifier not yet trained');
        end
        if nargin<3
            mask = ones(size(input,1),size(input,2),'uint8');
        end
        input = Classifier.normalize(input,obj.normpars);
        simfun = str2func([obj.type 'sim']);
        out = simfun(obj.model,input,mask);
    end
    
    end
    
    methods (Access = protected,Static)
	function perf = evaluate(simfun,model,input,labels,mask)
        labels(mask==0) =0;
	    out = simfun(model,input,mask);
	    perf = sum(sum(out==labels&labels>0))/sum(sum(labels>0));
    end
	
    
	function [input,pars] = normalize(input,pars)
	    [h,w,d] = size(input);
	    input = reshape(input,h*w,d);
	    if nargin<2
		pars.mean = mean(input);
		pars.std = std(input);
	    end
	    input = (input-ones(h*w,1)*pars.mean)./(ones(h*w,1)*pars.std);
	    input = reshape(input,h,w,d);
	end
	
	
	function masks = dividetraindata(trainmask,type,Ndivisions)
	    switch type
		case {'spatial'}
		    [objects,nobjects] = bwlabel(trainmask>0,4);
		otherwise
		    objects = double(trainmask>0).*reshape((1:numel(trainmask)),size(trainmask));
		    nobjects = max(objects(:));
	    end
	    I = [0,randperm(nobjects)];
	    objects = I(objects+1);
	    objects = ceil(objects/nobjects*Ndivisions);

	    masks = cell(1,Ndivisions);
	    for i=1:Ndivisions
		masks{i} = reshape((objects==i)*2+((objects~=i)&(objects>0)),size(trainmask));
	    end
	end
    
    end


end
