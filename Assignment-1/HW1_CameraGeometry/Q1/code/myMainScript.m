% Data Collection

%image = imread('../data/input.jpg');
%[X,Y,Z] = size(image);
%N = 6;
%image_points = readPoints(image,N); % We can select more points as well (Ziesserman says 28!) 
%save('locations','image_points','object_points');

% object_points = zeros([3,N]); % Manually add point locations of 3D space
% objects_points(1,1) = 0;
% objects_points(1,2) = 2;
% objects_points(1,3) = 1;
% objects_points(1,4) = 5;
% objects_points(1,5) = 2;
% objects_points(1,6) = 3;
% objects_points(2,1) = 1;
% objects_points(2,2) = 1;
% objects_points(2,1) = 0;
% objects_points(2,3) = 5;
% objects_points(3,4) = 2;
% objects_points(3,5) = 4;
% objects_points(3,6) = 2;

% These are Euclidean coordinates!!

% End Data Collection

load('locations.mat')
N = size(image_points);
N = N(2);
image_mean = mean(image_points,2);
object_mean = mean(object_points,2);

image_avg_dist = mean(sqrt(sum((image_points - repmat(image_mean, [1, N])).^2,1))); 
object_avg_dist = mean(sqrt(sum((object_points - repmat(object_mean, [1, N])).^2,1)));

image_scale = sqrt(2)/image_avg_dist;
object_scale = sqrt(3)/object_avg_dist;

T = image_scale*[eye(2) , -1*image_mean];
T = [T; [zeros(1,2) , 1]];

U = object_scale*[eye(3) , -1*object_mean];
U = [U; [zeros(1,3) , 1]];

original_image_points = image_points;
original_object_points = object_points;

image_points = [image_points; ones(1,N)];
object_points = [object_points; ones(1,N)];

image_points = T * image_points;
object_points = U * object_points;

A = zeros(2*N,12);
for i = 1:N
    A(2*i-1,1:4) = 0;
    A(2*i-1,5:8) = -1*object_points(:,i);
    A(2*i-1,9:12) = image_points(2,i)*object_points(:,i);
    A(2*i,1:4) = -1*object_points(:,i);
    A(2*i,5:8) = 0;
    A(2*i,9:12) = image_points(1,i)*object_points(:,i);
end

[~,~,V] = svd(A);
Phat = V(:,12);
Phat = reshape(Phat,[4,3])'; K_
P = inv(T)*Phat*U;

% P = [M | -M X_0]

M = P(1:3,1:3);

[R,K] = qr(M);
K_normalised = K/K(3,3);

% R is the rotation matrix and K is a upper triangular matrix

X_0 = -1*inv(M)*P(:,4);

%{
predicted_points = P*[original_object_points; ones(1, N)];
predicted_points(1,:) = predicted_points(1,:)./(predicted_points(3,:));
predicted_points(2,:) = predicted_points(2,:)./(predicted_points(3,:));
predicted_points(3,:) = predicted_points(3,:)./(predicted_points(3,:));

rmse = norm(predicted_points-[original_image_points; ones(1, N)])/6;
predicted_euclidean_points = predicted_points(1:2,:);


rmse
predicted_euclidean_points
original_image_points


for i=1:N
    plot(original_image_points(1, i), original_image_points(2, i), 'r*');
    hold on;
    plot(predicted_points(1, i), predicted_points(2, i), 'go');
    hold on;
end
title('Image points and Predicted points', 'FontSize', 24);

%}