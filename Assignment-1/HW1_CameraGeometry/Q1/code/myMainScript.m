% Data Collection

%image = imread('../data/input.jpg');
%[X,Y,Z] = size(image);
%N = 6;
%image_points = readPoints(image,N); % We can select more points as well (Ziesserman says 28!) 
%object_points = zeros([3,N]); % Manually add point locations of 3D space
%save('locations','image_points','object_points');

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
P = V(:,12);
P = reshape(P,[4,3])'; 

%P = inv(T)*P*U;

%[~,~,V] = svd(P); % Can also be computed algebraically actually (Ziesermann pg150)
%X0 = V(:,4); % Check -- Last homogeneous coordinated almost 1 but not exactly
%X0 = X0(1:3); 

% P = [M | -M X_0]

M = P(1:3,1:3);
[R,K] = qr(M);
% R is the rotation matrix and K is a upper triangular matrix

X_0 = -1*inv(M)*P;

%%%%%%%%%%
%predicted_points = P*object_points;
%predicted_points(1,:) = predicted_points(1,:)./(predicted_points(3,:));
%predicted_points(2,:) = predicted_points(2,:)./(predicted_points(3,:));
%predicted_points(3,:) = predicted_points(3,:)./(predicted_points(3,:));

%norm(predicted_points-image_points)
%%%%%%%%%%
