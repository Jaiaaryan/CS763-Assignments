%% MyMainScript

tic;
%% Your code here

%{
movingImage1 = rotateAndTranslate(imread('../input/negative_barbara.png'), 23.5, -3);
movingImage2 = rotateAndTranslate(imread('../input/noflash1.jpg'), 23.5, -3);
movingImage1 = addNoise(movingImage1);
movingImage2 = addNoise(movingImage2);
originalImage1 = imread('../input/barbara.png');
originalImage2 = imread('../input/flash1.jpg');
save('Q3Data', 'movingImage1', 'movingImage2', 'originalImage1', 'originalImage2');
%}


% Running rotation is slow because it uses interp

load('Q3Data');


%%downsample for now
entropyGrid1 = zeros(121, 24);

 for i=1:121
     for j=1:25
         currentImage = rotateAndTranslate(movingImage1, i - 61, j - 13);
         entropyGrid1(i, j) = jointEntropy(currentImage, originalImage1);
     end
     i
 end
 
 entropyGrid2 = zeros(121, 24);

originalImage2 = rgb2gray(originalImage2);
for i=1:121
    for j=1:25
        currentImage = rotateAndTranslate(movingImage2, i - 61, j - 13);
        entropyGrid2(i, j) = jointEntropy(currentImage, originalImage2);
    end
    i
end

surf(entropyGrid1);
surf(entropyGrid2);

[M,I] = min(entropyGrid1(:));
[barbaraAngle, barbaraTranslation] = ind2sub(size(entropyGrid1),I);
barbaraAngle = barbaraAngle - 61
barbaraTranslation = barbaraTranslation - 13

[M,I] = min(entropyGrid2(:));
[flashAngle, flashTranslation] = ind2sub(size(entropyGrid2),I);
flashAngle = flashAngle - 61
flashTranslation = flashTranslation - 13

toc;
