classdef TankBarrel < StaticObject

    properties
        parentTank
        barrelLength = 3
        barrelWidth = 3
    end
    
    methods
        function obj = TankBarrel(axes, parentTank)
            obj@StaticObject(axes, parentTank.position);
            obj.parentTank = parentTank;
            
            obj.updateState()
        end
        
        function updateState(obj, ~)
            obj.position = obj.parentTank.position;
            
            obj.vertices.x = [0 obj.barrelLength*sin(obj.parentTank.aimAngle)]; 
            obj.vertices.y = [0 obj.barrelLength*cos(obj.parentTank.aimAngle)];
        end
        
        function computeDisplay(obj)
             obj.body = {obj.vertices.x + obj.position.x, ...
                obj.vertices.y + obj.position.y +1};
             obj.plottedBody = plot(obj.axes, obj.body{1}, obj.body{2},...
                 'LineWidth', obj.barrelWidth,...
                 'Color', 'black');
        end
        
        function updateDisplay(obj)
            obj.body = {obj.vertices.x + obj.position.x, ...
                obj.vertices.y + obj.position.y + 1};
            
            set(obj.plottedBody, {'XData', 'YData'}, obj.body);
        end
        
    end
end

