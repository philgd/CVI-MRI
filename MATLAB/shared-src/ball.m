function out = ball(r)
% out = ball(radius)
% creates a ball.

    narginchk(1,1);
    nargoutchk(1,1);
    
    R = ceil(r);
    [x y z] = ndgrid(-R:R, -R:R, -R:R);
    
    out = sqrt(x.*x + y.*y + z.*z) <= r;