classdef Tank < MovingObject

    properties
        graphicalElements
        projectileSpeed = 5;
        projectileCoefficients = [0.7, 1.5];
        reloaded = true;
        parentApp
        destroyed = false;
        maxAngle = pi/3
        speed = 0.2
        aimAngle = 0 
        aimSpeed = 0
        maxAimSpeed =  pi / 8 /10
        gravity = -0.4
    end
    
    methods
        function obj = Tank(app, graphicalElements, position, ...
                velocity, acceleration, startingAimAngle)
            obj@MovingObject(app.UIAxes, position, velocity, acceleration)
            obj.graphicalElements = graphicalElements;
            % Shape
            obj.vertices = struct('x', [-2, -1, 1, 2], 'y', [0, 2, 2, 0]); 
            obj.originalVertices = struct('x', [-2, -1, 1, 2], 'y', [0, 2, 2, 0]);
            obj.aimAngle = startingAimAngle;
            obj.parentApp = app;
            
            obj.graphicalElements.addElement(...
                TankBarrel(obj.axes, obj))
        end
        
        function computeDisplay(obj)
            obj.body = polyshape(obj.vertices.x + obj.position.x, ...
                obj.vertices.y + obj.position.y);
            obj.plottedBody = plot(obj.axes, obj.body);
            set(obj.plottedBody, ...
                'FaceAlpha', 1);
        end
        
        function aimCounterClock(obj)
            obj.aimSpeed = -obj.maxAimSpeed;
        end
        
        function aimClock(obj)
            obj.aimSpeed = obj.maxAimSpeed;
        end
        
        function rideLeft(obj)
            obj.velocity = struct('x', -obj.speed, 'y', 0);
        end
        
        function rideRight(obj)
            obj.velocity = struct('x', obj.speed, 'y', 0);
        end
        
        function stopRide(obj)
            obj.velocity = struct('x', 0, 'y', 0);
        end
        function stopAim(obj)
            obj.aimSpeed = 0;
        end
        
        function shoot(obj)
            if obj.reloaded == true && obj.destroyed == false
                vSpeed = obj.projectileSpeed * cos(obj.aimAngle) * ...
                    obj.projectileCoefficients(2);
                hSpeed = obj.projectileSpeed * sin(obj.aimAngle) * ...
                    obj.projectileCoefficients(1);
                
                obj.graphicalElements.addElement(...
                    Projectile(obj.axes, ...
                    struct('x', obj.position.x, 'y', obj.position.y+1), ...
                    struct('x', hSpeed, 'y', vSpeed), ...
                    struct('x', 0, 'y', obj.gravity), ...
                    obj)...
                    )
                obj.reloaded = false;
            end
        end
        
        function moveBarell(obj)
            obj.aimAngle = obj.aimAngle + obj.aimSpeed;
            if obj.aimAngle > obj.maxAngle
                obj.aimAngle = obj.maxAngle;
            else
                if obj.aimAngle < -obj.maxAngle
                    obj.aimAngle = -obj.maxAngle;
                end
            end
        end
        
        function updateState(obj, Objects)
            obj.updatePositions(Objects)
            
            % TODO put terrain inside Objects
            terrain = obj.parentApp.terrain;
            obj.handleCollision(terrain)
            obj.moveBarell()
        end
        
        function handleCollision(obj, terrain)
            %Terrain collisions
            [~, terrainIndex] = min(abs(terrain.body.Vertices(:,1) - obj.position.x));
            
            try
                rightTerrainHeight = ...
                    terrain.body.Vertices(terrainIndex + 1, 2);
                
                leftTerrainHeight = ...
                    terrain.body.Vertices(terrainIndex - 1, 2);
                
                currentDerivative = ...
                    rightTerrainHeight * 0.5 -...
                    leftTerrainHeight * 0.5;
                
                interpolatedY = leftTerrainHeight +  ...
                    currentDerivative * ...
                    (obj.position.x - terrain.body.Vertices(terrainIndex - 1, 1));
                
            catch
                interpolatedY = terrain.body.Vertices(terrainIndex, 2);
                currentDerivative = 0;
            end
            
            obj.position.y = interpolatedY;
            obj.rotate(atan(currentDerivative))
        end
        
        function checkExplosion(obj, explosionBody)
            if intersect(obj.body, explosionBody).NumRegions ~= 0
                obj.explode()
            end
        end
        
        function explode(obj)
            set (obj.plottedBody, ...
                'FaceColor', 'black', 'FaceAlpha', 1);
            obj.destroyed = true;
            obj.speed = 0;
            obj.maxAimSpeed = 0;
            obj.velocity.x = 0;
            obj.velocity.y = 0;
        end
    end
end

