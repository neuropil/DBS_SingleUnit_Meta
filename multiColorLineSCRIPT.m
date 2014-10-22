clear
clc

[X,Y,Z] = peaks;

n = 22;
x = Y(:,n);
y = Z(:,n);

subplot(2,1,1)
plot(x,y,'.')

c = y;

subplot(2,1,2);
multiColorLine(x,y,c,winter)