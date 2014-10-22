figure(1);
n = 10;
xs = rand(n,1);
ys = rand(n,1);
zs = rand(n,1)*3;
plot3(xs,ys,zs,'r.')
xlabel('x');ylabel('y');zlabel('z');
p  = patchline(xs,ys,zs,'linestyle','--','edgecolor','g','linewidth',3,'edgealpha',0.2);

x = [0 10 20 50 60];
y = [0 5 10 5 0];
xflip = [x(1 : end - 1) fliplr(x)];
yflip = [y(1 : end - 1) fliplr(y)];
patch(xflip, yflip, 'r', 'EdgeAlpha', 0.1, 'FaceColor', 'none');
p  = patchline(x,y,'linestyle','-','edgecolor','g','linewidth',1,'edgealpha',0.2);

figure;
for i = 1:length(detectStruct.spkWaveforms)
    
    y = detectStruct.spkWaveforms(i,:);
    x = 1:1:length(detectStruct.spkWaveforms(1,:));
    
    xflip = [x(1 : end - 1) fliplr(x)];
    yflip = [y(1 : end - 1) fliplr(y)];

    patch(xflip, yflip, 'EdgeColor','g', 'EdgeAlpha', 0.25, 'FaceColor', 'red');
    
    hold on
    
end