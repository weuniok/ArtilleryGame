classdef MovingObject < StaticObject
    
    properties
        velocity = struct('x' , 0, 'y' , 0)
        acceleration = struct('x' , 0, 'y', 0)
        % to avoid shots clipping through terrian surfacace on 
        terminalVelocity = -10 
    end
    
    methods
        function obj = MovingObject(axes, position, velocity, acceleration)
            obj@StaticObject(axes, position);
            obj.velocity = velocity;
            obj.acceleration = acceleration;
        end
        
        function updateState(obj, Objects)
            obj.updatePositions(Objects)
        end
        
        function updatePositions(obj, Objects)
            obj.position.x = obj.position.x + obj.velocity.x;
            obj.position.y = obj.position.y + obj.velocity.y;
            
            obj.velocity.x = obj.velocity.x + obj.acceleration.x;
            obj.velocity.y = max(obj.velocity.y + obj.acceleration.y, obj.terminalVelocity);

            if obj.position.y < 0
                obj.velocity.x = 0;      
            end
            if obj.position.x < 0 || obj.position.x > 100 || obj.position.y < -20
                obj.destroy(Objects)
            end
        end
        
        function destroy(obj, Objects)
            delete(obj.plottedBody)
            delete(obj)
            Objects.cleanTrash()
        end
             
        function rotate(obj, angle)
            obj.vertices.x = obj.originalVertices.x * cos(angle) - ...
                obj.originalVertices.y * sin(angle);
            obj.vertices.y = obj.originalVertices.x * sin(angle) + ...
                obj.originalVertices.y * cos(angle);
        end
    end
end

