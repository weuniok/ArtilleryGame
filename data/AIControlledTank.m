classdef AIControlledTank < Tank
    
    properties
        correctAngle
        accuracy = 0.2
        timer = 0
        rangesList
        heightAdvantageList
        anglesList
        playerNumber
    end
    
    methods
        function obj = AIControlledTank(app, graphicalElements, position, ...
                velocity, acceleration, startingAimAngle, playerNumber)
            obj@Tank(app, graphicalElements, position, velocity, ...
                acceleration, startingAimAngle)
            
            obj.playerNumber = playerNumber;
            obj.generateAimLookup()
            obj.rideRight()
        end 
        
        function generateAimLookup(obj)
            % The Lowground ranges LookupTable is wrong as it calculates the angle the opponent 
            % would have to use if his projectile's final velocity would be equal to projectile
            % initial velocity
            % TODO: fix
            % TODO: almost vertical shots seem very unaccurate for AI, fix
            % TODO: derive explicit formula for aimAngle instead of using lookup table
            
           
            angles = -obj.maxAngle:0.05:obj.maxAngle;
            obj.anglesList = angles;
            V0 = obj.projectileSpeed;
            Vx = obj.projectileCoefficients(1) * V0 * sin(angles);
            Vy = obj.projectileCoefficients(2) * V0 * cos(angles);
            g = abs(obj.gravity);
            
            % Calculated height differences
            hHighground = 0:100;
            hLowground = -100:-1;
            
            % Initial velocity of correct attack if the opponent was the one shooting
            Vyk = Vy - sqrt(abs(hLowground).' * 2 * g);
            
            rangesHighground = Vx/g .* (Vy + sqrt(Vy .* Vy + 2 * g * hHighground.'));
            rangesLowground = Vx/g .* (Vyk + sqrt(Vyk .* Vyk + 2 * g * abs(hLowground).'));
            
            obj.rangesList = [rangesLowground; rangesHighground];
            obj.heightAdvantageList =  [hLowground, hHighground].';
        end
        
        function updateState(obj, Objects)
            obj.updatePositions(Objects)
            
            terrain = obj.parentApp.terrain;
            obj.handleCollision(terrain)
            obj.moveBarell()
            
            % AI Simulation
            obj.calculateAngle()
            obj.controlAim()
            % TODO: add dodging 
            obj.controlMove()
        end
        
        function calculateAngle(obj)
            otherPlayer = obj.parentApp.(strcat('player', num2str(3 - obj.playerNumber)));
            
            distance = - obj.position.x + ...
                otherPlayer.position.x;
            heightAdv = obj.position.y - ...
                otherPlayer.position.y;
            
            [~, heightIndex] = min(abs(obj.heightAdvantageList - heightAdv));
            [~, angleIndex] = min(abs(obj.rangesList(heightIndex, :) - distance));
            obj.correctAngle = obj.anglesList(angleIndex);
        end
         
        function controlAim(obj)
            if abs(obj.correctAngle - obj.aimAngle) < obj.accuracy
                obj.shoot()
            else
                if obj.correctAngle < obj.aimAngle
                    obj.aimCounterClock()
                    
                else
                    obj.aimClock()
                end
            end
        end
        
        function controlMove(obj)
            % TODO: something instead of if nesting            
            if obj.position.x > 90
                obj.rideLeft()
            else
                if obj.position.x < 10
                    obj.rideRight()
                else
                    obj.timer = obj.timer + 1;
                    if obj.timer == 48
                        obj.timer = 0;
                        if obj.position.x < 70 && obj.position.x > 30
                            if rand() < 0.5
                                obj.rideLeft()
                            else 
                                obj.rideRight()
                            end
                        end
                    end
                end
            end 
        end
    end
end

