% %%{
% ----------------------------------------------------------------------------
% 
% This file is part of the Sanworks Bpod repository
% Copyright (C) 2018 Sanworks LLC, Stony Brook, New York, USA
%
%Modifications by Francesca Greenstreet SJLab to allow tabs
% 
% ----------------------------------------------------------------------------
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3.
% 
% This program is distributed  WITHOUT ANY WARRANTY and without even the
% implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% %}

function varargout = BpodParameterGUI_with_tabs(varargin)

% BpodParameterGUI('init', ParamStruct) - initializes a GUI with edit boxes for every field in subfield ParamStruct.GUI
% BpodParameterGUI('sync', ParamStruct) - updates the GUI with fields of
%       ParamStruct.GUI, if they have not been changed by the user. 
%       Returns a param struct. Fields in the GUI sub-struct are read from the UI.

% This version of BpodParameterGUI includes improvements 
% from EnhancedParameterGUI, contributed by F. Carnevale

global BpodSystem
Op = varargin{1};
Params = varargin{2};
Op = lower(Op);
switch Op
    case 'init'
        ParamNames = fieldnames(Params.GUI);
        nParams = length(ParamNames);
        BpodSystem.GUIData.ParameterGUI.ParamNames = cell(1,nParams);
        BpodSystem.GUIData.ParameterGUI.nParams = nParams;
        BpodSystem.GUIHandles.ParameterGUI.Labels = zeros(1,nParams);
        BpodSystem.GUIHandles.ParameterGUI.Params = zeros(1,nParams);
        BpodSystem.GUIData.ParameterGUI.LastParamValues = cell(1,nParams);
        if isfield(Params, 'GUIMeta')
            Meta = Params.GUIMeta;
        else
            Meta = struct;
        end
        if isfield(Params, 'GUIPanels')
            Panels = Params.GUIPanels;
            PanelNames = fieldnames(Panels);
            nPanels = length(PanelNames);
            paramNames = fieldnames(Params.GUI);
            nParameters = length(paramNames);
            paramPanels = zeros(1,nParameters);
            % Find any params not assigned a panel and assign to
            % new 'Parameters' panel
            paramsInPanels = {}; 
            for i = 1:nPanels
                paramsInPanels = [paramsInPanels Panels.(PanelNames{i})];
            end
            paramsInDefaultPanel = {};
            
            for i = 1:nParameters
                if ~strcmp(paramNames{i}, paramsInPanels)
                    paramsInDefaultPanel = [paramsInDefaultPanel paramNames{i}];
                end
            end
            if ~isempty(paramsInDefaultPanel)
                Panels.Parameters = cell(1,length(paramsInDefaultPanel));
                for i = 1:length(paramsInDefaultPanel)
                    Panels.Parameters{i} = paramsInDefaultPanel{i};
                end
                PanelNames{nPanels+1} = 'Parameters';
            end
            nPanels = length(PanelNames);
        else
            Panels = struct;
            Panels.Parameters = ParamNames;
            PanelNames = {'Parameters'};
            nPanels = 1;
        end
        
        if isfield(Params, 'GUITabs')
            Tabs = Params.GUITabs;            
        else
            Tabs = struct;
            Tabs.Parameters = PanelNames;
        end
        TabNames = fieldnames(Tabs);
        nTabs = length(TabNames);
        
        Params = Params.GUI;
        PanelNames = PanelNames(end:-1:1);
        GUIHeight = 650.*.7;
        MaxVPos = 0;
        MaxHPos = 0;
        BpodSystem.ProtocolFigures.ParameterGUI = figure('Position', [50 50 450 GUIHeight],'name','Parameter GUI','numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
        BpodSystem.GUIHandles.ParameterGUI.Tabs.TabGroup = uitabgroup(BpodSystem.ProtocolFigures.ParameterGUI);
        ParamNum = 1;
        for t = 1:nTabs
            VPos = 0;
            HPos = 0;
            ThisTabPanelNames = Tabs.(TabNames{t});
            nPanels = length(ThisTabPanelNames);
            BpodSystem.GUIHandles.ParameterGUI.Tabs.(TabNames{t}) = uitab('title', TabNames{t});
            htab = BpodSystem.GUIHandles.ParameterGUI.Tabs.(TabNames{t});
            for p = 1:nPanels
                ThisPanelParamNames = Panels.(ThisTabPanelNames{p});
                ThisPanelParamNames = ThisPanelParamNames(end:-1:1);
                nParams = length(ThisPanelParamNames);
                ThisPanelHeight = (45*nParams)+5;
                BpodSystem.GUIHandles.ParameterGUI.Panels.(ThisTabPanelNames{p}) = uipanel(htab,'title', ThisTabPanelNames{p},'FontSize',12, 'FontWeight', 'Bold', 'BackgroundColor','white','Units','Pixels', 'Position',[HPos VPos 430 ThisPanelHeight]);
                InPanelPos = 10;
                for i = 1:nParams
                    ThisParamName = ThisPanelParamNames{i};
                    ThisParam = Params.(ThisParamName);
                    BpodSystem.GUIData.ParameterGUI.ParamNames{ParamNum} = ThisParamName;
                    if ischar(ThisParam)
                        BpodSystem.GUIData.ParameterGUI.LastParamValues{ParamNum} = NaN;
                    else
                        BpodSystem.GUIData.ParameterGUI.LastParamValues{ParamNum} = ThisParam;
                    end
                    if isfield(Meta, ThisParamName)
                        if isstruct(Meta.(ThisParamName))
                            if isfield(Meta.(ThisParamName), 'Style')
                                ThisParamStyle = Meta.(ThisParamName).Style;
                                if isfield(Meta.(ThisParamName), 'String')
                                    ThisParamString = Meta.(ThisParamName).String;
                                else
                                    ThisParamString = '';
                                end
                            else
                                error(['Style not specified for parameter ' ThisParamName '.'])
                            end
                        else
                            error(['GUIMeta entry for ' ThisParamName ' must be a struct.'])
                        end
                    else
                        ThisParamStyle = 'edit';
                        ThisParamValue = NaN;
                    end
                    BpodSystem.GUIHandles.ParameterGUI.Labels(ParamNum) = uicontrol(htab,'Style', 'text', 'String', ThisParamName, 'Position', [HPos+5 VPos+InPanelPos 200 25], 'FontWeight', 'normal', 'FontSize', 12, 'BackgroundColor','white', 'FontName', 'Arial','HorizontalAlignment','Center');
                    switch lower(ThisParamStyle)
                        case 'edit'
                            
                            
                            BpodSystem.GUIData.ParameterGUI.Styles(ParamNum) = 1;
                            BpodSystem.GUIHandles.ParameterGUI.Params(ParamNum) = uicontrol(htab,'Style', 'edit', 'String', num2str(ThisParam), 'Position', [HPos+220 VPos+InPanelPos+2 200 25], 'FontWeight', 'normal', 'FontSize', 12, 'BackgroundColor','white', 'FontName', 'Arial','HorizontalAlignment','Center');
                        case 'edittext'
                            BpodSystem.GUIData.ParameterGUI.Styles(ParamNum) = 8;
                            BpodSystem.GUIHandles.ParameterGUI.Params(ParamNum) = uicontrol(htab,'Style', 'edit', 'String', ThisParam, 'Position', [HPos+220 VPos+InPanelPos+2 200 25], 'FontWeight', 'normal', 'FontSize', 12, 'BackgroundColor','white', 'FontName', 'Arial','HorizontalAlignment','Center');
                        case 'text'
                            BpodSystem.GUIData.ParameterGUI.Styles(ParamNum) = 2;
                            BpodSystem.GUIHandles.ParameterGUI.Params(ParamNum) = uicontrol(htab,'Style', 'text', 'String', num2str(ThisParam), 'Position', [HPos+220 VPos+InPanelPos+2 200 25], 'FontWeight', 'normal', 'FontSize', 12, 'BackgroundColor','white', 'FontName', 'Arial','HorizontalAlignment','Center');
                        case 'checkbox'
                            BpodSystem.GUIData.ParameterGUI.Styles(ParamNum) = 3;
                            BpodSystem.GUIHandles.ParameterGUI.Params(ParamNum) = uicontrol(htab,'Style', 'checkbox', 'Value', ThisParam, 'String', '   (check to activate)', 'Position', [HPos+220 VPos+InPanelPos+4 200 25], 'FontWeight', 'normal', 'FontSize', 12, 'BackgroundColor','white', 'FontName', 'Arial','HorizontalAlignment','Center');
                        case 'popupmenu'
                            BpodSystem.GUIData.ParameterGUI.Styles(ParamNum) = 4;
                            BpodSystem.GUIHandles.ParameterGUI.Params(ParamNum) = uicontrol(htab,'Style', 'popupmenu', 'String', ThisParamString, 'Value', ThisParam, 'Position', [HPos+220 VPos+InPanelPos+2 200 25], 'FontWeight', 'normal', 'FontSize', 12, 'BackgroundColor','white', 'FontName', 'Arial','HorizontalAlignment','Center');
                        case 'togglebutton' % INCOMPLETE
                            BpodSystem.GUIData.ParameterGUI.Styles(ParamNum) = 5;
                            BpodSystem.GUIHandles.ParameterGUI.Params(ParamNum) = uicontrol(htab,'Style', 'togglebutton', 'String', ThisParamString, 'Value', ThisParam, 'Position', [HPos+220 VPos+InPanelPos+2 200 25], 'FontWeight', 'normal', 'FontSize', 12, 'BackgroundColor','white', 'FontName', 'Arial','HorizontalAlignment','Center');
                        case 'pushbutton'
                            BpodSystem.GUIData.ParameterGUI.Styles(ParamNum) = 6;
                            BpodSystem.GUIHandles.ParameterGUI.Params(ParamNum) = uicontrol(htab,'Style', 'pushbutton', 'String', ThisParamString,...
                                'Value', ThisParam, 'Position', [HPos+220 VPos+InPanelPos+2 200 25], 'FontWeight', 'normal', 'FontSize', 12,...
                                'BackgroundColor','white', 'FontName', 'Arial','HorizontalAlignment','Center','Callback',Meta.OdorSettings.Callback);
                        case 'table'
                            BpodSystem.GUIData.ParameterGUI.Styles(ParamNum) = 7;
                            columnNames = fieldnames(Params.(ThisParamName));
                            if isfield(Meta.(ThisParamName),'ColumnLabel')
                                columnLabel = Meta.(ThisParamName).ColumnLabel;
                            else
                                columnLabel = columnNames;
                            end
                            tableData = [];
                            for iTableCol = 1:numel(columnNames)
                                tableData = [tableData, Params.(ThisParamName).(columnNames{iTableCol})];
                            end
%                             tableData(:,2) = tableData(:,2)/sum(tableData(:,2));
                            htable = uitable(htab,'data',tableData,'columnname',columnLabel,...
                                'ColumnEditable',true(1,numel(columnLabel)), 'FontSize', 12);
                            htable.Position([3 4]) = htable.Extent([3 4]);
                            htable.Position([1 2]) = [HPos+220 VPos+InPanelPos+2];
                            BpodSystem.GUIHandles.ParameterGUI.Params{ParamNum} = htable;
                            ThisPanelHeight = ThisPanelHeight + (htable.Position(4)-25);
                            BpodSystem.GUIHandles.ParameterGUI.Panels.(ThisTabPanelNames{p}).Position(4) = ThisPanelHeight;
                            BpodSystem.GUIData.ParameterGUI.LastParamValues{ParamNum} = htable.Data;
                        otherwise
                            error('Invalid parameter style specified. Valid parameters are: ''edit'', ''text'', ''checkbox'', ''popupmenu'', ''togglebutton'', ''pushbutton''');
                    end
                    InPanelPos = InPanelPos + 35;
                    ParamNum = ParamNum + 1;
                end
                % Check next panel to see if it will fit, otherwise start new column
                Wrap = 0;
                if p < nPanels
                    NextPanelParams = Panels.(ThisTabPanelNames{p+1});
                    NextPanelSize = (length(NextPanelParams)*45) + 5;
                    if VPos + ThisPanelHeight + 45 + NextPanelSize > GUIHeight
                        Wrap = 1;
                    end
                end
                VPos = VPos + ThisPanelHeight + 10;
                if Wrap
                    HPos = HPos + 450;
                    if VPos > MaxVPos
                        MaxVPos = VPos;
                    end
                    VPos = 10;
                else
                    if VPos > MaxVPos
                        MaxVPos = VPos;
                    end
                end
                if HPos > MaxHPos
                    MaxHPos = HPos;
                end
                set(BpodSystem.ProtocolFigures.ParameterGUI, 'Position', [50 50 MaxHPos+350 MaxVPos+35]);
            end            
        end      
        set(BpodSystem.ProtocolFigures.ParameterGUI, 'Position', [900 100 HPos+450 MaxVPos+10]);
    case 'sync'
        ParamNames = BpodSystem.GUIData.ParameterGUI.ParamNames;
        nParams = BpodSystem.GUIData.ParameterGUI.nParams;
        for p = 1:nParams
            ThisParamName = ParamNames{p};
            ThisParamStyle = BpodSystem.GUIData.ParameterGUI.Styles(p);
            ThisParamHandle = BpodSystem.GUIHandles.ParameterGUI.Params(p);
            ThisParamLastValue = BpodSystem.GUIData.ParameterGUI.LastParamValues{p};
            ThisParamCurrentValue = Params.GUI.(ThisParamName); % Use single precision to avoid problems with ==
            switch ThisParamStyle
                case 1 % Edit
                    GUIParam = str2double(get(ThisParamHandle, 'String'));
                    if single(GUIParam) ~= single(ThisParamLastValue)
                        Params.GUI.(ThisParamName) = GUIParam;
                    elseif single(ThisParamCurrentValue) ~= single(ThisParamLastValue)
                        set(ThisParamHandle, 'String', num2str(ThisParamCurrentValue));
                    end
                case 2 % Text
                    GUIParam = ThisParamCurrentValue;
                    Text = GUIParam;
                    if ~ischar(Text)
                        Text = num2str(Text);
                    end
                    set(ThisParamHandle, 'String', Text);
                case 3 % Checkbox
                    GUIParam = get(ThisParamHandle, 'Value');
                    if GUIParam ~= ThisParamLastValue
                        Params.GUI.(ThisParamName) = GUIParam;
                    elseif ThisParamCurrentValue ~= ThisParamLastValue
                        set(ThisParamHandle, 'Value', ThisParamCurrentValue);
                    end
                case 4 % Popupmenu
                    GUIParam = get(ThisParamHandle, 'Value');
                    if GUIParam ~= ThisParamLastValue
                        Params.GUI.(ThisParamName) = GUIParam;
                    elseif ThisParamCurrentValue ~= ThisParamLastValue
                        set(ThisParamHandle, 'Value', ThisParamCurrentValue);
                    end
            end
            if ThisParamStyle ~= 5
                BpodSystem.GUIData.ParameterGUI.LastParamValues{p} = Params.GUI.(ThisParamName);
            end
        end
    otherwise
    error('ParameterGUI must be called with a valid op code: ''init'' or ''sync''');
end
if verLessThan('MATLAB', '8.4')
    drawnow;
end
varargout{1} = Params;
