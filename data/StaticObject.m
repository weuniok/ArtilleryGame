classdef StaticObject < handle

    properties
        originalVertices = struct('x', [0, 0, 2], 'y', [0, 1, 1])
        vertices = struct('x', [0, 0, 2], 'y', [0, 1, 1])
        position = struct('x', 0, 'y', 0)
        body
        plottedBody 
        axes
    end

    methods
        function obj = StaticObject(axes, position)
            obj.position = position;
            obj.axes = axes;
        end
        
        function computeDisplay(obj)
             obj.body = polyshape(obj.vertices.x + obj.position.x, ...
                 obj.vertices.y + obj.position.y);
             obj.plottedBody = plot(obj.axes, obj.body);
        end
        
        function updateDisplay(obj)
            obj.body = polyshape(obj.vertices.x + obj.position.x, ...
                obj.vertices.y + obj.position.y);
            
            set(obj.plottedBody, 'Shape', obj.body);
        end
        
        function updateState(obj, Objects)
           % Function to be overriden by subclasses 
           % TODO: make something not requiring to copying content from
           % superclass
        end
        
    end
end

