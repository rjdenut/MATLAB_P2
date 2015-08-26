function Rot_x = rot_x(flipAngle)

Rot_x = zeros(3,3);
Rot_x(1,1:3) = ([1, 0 , 0]);
Rot_x(2,1:3) = ([0, cos(flipAngle), sin(flipAngle)]);
Rot_x(3,1:3) = ([0, -sin(flipAngle) , cos(flipAngle)]);

end
