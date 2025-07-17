function coneDetection() %#codegen
    persistent model;
    % Load model
    if isempty(model)
         model = coder.loadDeepLearningNetwork('yoloxConeDetector.mat');
    end

    % Create Jetson hardware object
    hwobj = jetson();     
    
    % Please use your own video file with a frame size of 416x416
    vidName = '/home/xavier/Videos/testConeDetector_416x416.mp4'; 

    % Create video reader object,
    vObj = VideoReader(hwobj,vidName,width= 416, height = 416);

    % Create display object on the target
    dispObj = imageDisplay(hwobj);

    while vObj.hasFrame
        % Grab a frame from the video pipeline
        img = vObj.readFrame();
    
        % Cone detection in the frame
        [bboxes, ~, labels] =  model.detect(img,'Threshold',0.5);
        
        % Annotate detections in the frame.
        if ~isempty(bboxes)
            outImg = insertObjectAnnotation(img,'Rectangle', ...
                bboxes, cellstr(labels));
        else
             outImg = img;
        end

        % Adjust the direction of the frame for output 
        displayImg = cat(3, outImg(:,:,1).', ...
        outImg(:,:,2)',outImg(:,:,3)');

        % Display the frame
        image(dispObj,displayImg);
    end
end

% Copyright 2025 The MathWorks, Inc.