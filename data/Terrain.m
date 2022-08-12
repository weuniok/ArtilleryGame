classdef Terrain < StaticObject & matlab.mixin.Copyable
    %TERRAIN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        maxHeight = 70
    end
    
    methods
        function obj = Terrain(axes)
            obj@StaticObject(axes, struct('x', 0, 'y', 0));
            % Generate  terrain
            altitudes = smoothdata(randi([0 obj.maxHeight], 1, 101), 'gaussian', 15);
            obj.vertices.x = [0, 0:100, 100];
            obj.vertices.y = [-100, altitudes, -100];
        end
        
        function computeShadowDisplay(obj)
            obj.body = polyshape(obj.vertices.x + obj.position.x, ...
                obj.vertices.y + obj.position.y);
            obj.plottedBody = plot(obj.axes, obj.body, ...
                'FaceColor', 'black', 'FaceAlpha', 0.3);
        end
        
        function updateDisplay(obj)
            % Only update display on explosion by projectile
        end
        
    end
end

