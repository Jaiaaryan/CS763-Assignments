load('Q3Data');


%%downsample for now
movingImage = movingImage1(1:4:end, 1:4:end);
originalImage = originalImage1(1:4:end, 1:4:end);

[h, w] = size(movingImage);
movingImage = floor(movingImage/10) + 1;
originalImage = floor(originalImage/10) + 1;
movingImage = reshape(movingImage, h*w, 1);
originalImage = reshape(originalImage, h*w, 1);
indices = [movingImage, originalImage];

histo = zeros(26, 26);
%%vectorise this part!

for i=1:size(indices, 1)
   histo(indices(i, 1), indices(i, 2)) = histo(indices(i, 1), indices(i, 2)) + 1; 
end