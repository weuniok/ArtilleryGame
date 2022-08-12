classdef Projectile < MovingObject
    
    properties
        explosionVetices
        hitDistance = 8;
        parentTank
    end
    
    methods
        function obj = Projectile(axes, position, velocity, acceleration, parentTank)
            obj@MovingObject(axes, position, velocity, acceleration)
            obj.vertices = struct('x', sin(0:pi/6:2*pi), 'y', cos(0:pi/6:2*pi));
            obj.explosionVetices = struct('x', 3*sin(0:pi/6:2*pi), 'y', 3*cos(0:pi/6:2*pi));
            obj.parentTank = parentTank;
            
            obj.computeDisplay()
        end
        
        function updateState(obj, Objects)
            obj.updatePositions(Objects)
            if isvalid(obj) 
                % to stop updateState on explosion, 
                %probably oculd be done differnetly by overriding delete() 
                obj.handleCollision(Objects)
            end
        end
        
        function handleCollision(obj, Objects)
             terrain = obj.parentTank.parentApp.terrain;
             
            % Finding closest terrain vertice
            [~, closestPoints] = ...
                mink(abs(terrain.body.Vertices(:,1) - obj.position.x), 5);

            [distance, closestSinglePoint] = ...
                min(vecnorm ...
                (terrain.body.Vertices(closestPoints,:) -...
                [obj.position.x, obj.position.y], 2, 2));
            
            terrainIndex = closestPoints(closestSinglePoint); 
            
            currentTerrainHeight = terrain.body.Vertices(terrainIndex, 2);
             
            % Checking for collision
            if distance < 1.5
                obj.explode(terrain, Objects)
                return
            end
            if obj.position.y < currentTerrainHeight
                if obj.position.y < -10
                    obj.position.y = 0;
                    obj.explode(terrain, Objects)
                else
                    if currentTerrainHeight - obj.position.y < obj.hitDistance
                        obj.position.y = currentTerrainHeight;
                        obj.explode(terrain, Objects)
                    end
                end
            end
        end
        
        function explode(obj, terrain, Objects)
            obj.parentTank.reloaded = true;
            obj.body = polyshape(obj.explosionVetices.x + obj.position.x, ...
                obj.explosionVetices.y + obj.position.y);
            terrain.body = subtract(terrain.body, obj.body);
            set(terrain.plottedBody, 'Shape', terrain.body);
            
            obj.parentTank.parentApp.announceExplosion(obj.body);
            obj.destroy(Objects)
        end    
        
        function delete(obj)
           obj.parentTank.reloaded = true; 
        end
        
    end
end

