classdef GraphicalElementsList < handle

    properties
        Elements 
    end
    
    methods
        function obj = GraphicalElementsList()
           obj.Elements = {};
        end
        
        function clearList(obj)
            obj.Elements = {};
        end
        
        function addElement(obj, inputElement)
            obj.Elements{end+1} = inputElement;
        end
        
        function cleanTrash(obj)
           validElements = cellfun(@(element) isvalid(element), obj.Elements); 
           obj.Elements = obj.Elements(validElements);
        end
        
    end
end

