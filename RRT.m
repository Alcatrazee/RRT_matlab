%***************************************
%Author: Chaoqun Wang
%Date: 2019-10-15
%***************************************
%% ���̳�ʼ��
clc
clear all; close all;
x_I=1; y_I=1;           % ���ó�ʼ��
x_G=700; y_G=700;       % ����Ŀ��㣨�ɳ����޸��յ㣩
Thr=50;                 % ����Ŀ�����ֵ
Delta= 30;              % ������չ����
%% ������ʼ��
T.v(1).x = x_I;         % T������Ҫ��������v�ǽڵ㣬�����Ȱ���ʼ����뵽T������
T.v(1).y = y_I; 
T.v(1).xPrev = x_I;     % ��ʼ�ڵ�ĸ��ڵ���Ȼ���䱾��
T.v(1).yPrev = y_I;
T.v(1).dist=0;          % �Ӹ��ڵ㵽�ýڵ�ľ��룬�����ȡŷ�Ͼ���
T.v(1).indPrev = 0;     %
%% ��ʼ����������ҵ����
figure(1);
ImpRgb=imread('newmap.png');
Imp=rgb2gray(ImpRgb);
imshow(Imp)
xL=size(Imp,2);%��ͼx�᳤��
yL=size(Imp,1);%��ͼy�᳤��
hold on
plot(x_I, y_I, 'ro', 'MarkerSize',10, 'MarkerFaceColor','r');
plot(x_G, y_G, 'go', 'MarkerSize',10, 'MarkerFaceColor','g');% ��������Ŀ���
count=1;
bFind = false;

for iter = 1:3000
%     x_rand=[];
    %Step 1: �ڵ�ͼ���������һ����x_rand
    %��ʾ���ã�x_rand(1),x_rand(2)����ʾ�����в����������
    x_rand = round(800*rand(1,2));
    
    
    x_near=[];
    %Step 2: ���������������ҵ�����ڽ���x_near 
    %��ʾ��x_near�Ѿ�����T��
    [x_near_x,x_near_y,near_index] = find_nearest_point(T,x_rand);
    x_near = [x_near_x,x_near_y];
    
%     x_new=[];
    %Step 3: ��չ�õ�x_new�ڵ�
    %��ʾ��ע��ʹ����չ����Delta
    vec = x_rand - x_near;
    theta = atan2(vec(2),vec(1));
    x_new = round(Delta*[cos(theta),sin(theta)])+x_near;
    
    %���ڵ��Ƿ���collision-free
    if ~collisionChecking(x_near,x_new,Imp) 
       continue;
    end
    count=count+1;
    
    %Step 4: ��x_new������T 
    %��ʾ���½ڵ�x_new�ĸ��ڵ���x_near
    T.v(count).x = x_new(1);         
    T.v(count).y = x_new(2); 
    T.v(count).xPrev = x_near(1);     
    T.v(count).yPrev = x_near(2);
    T.v(count).dist=norm(x_new - x_near);         
    T.v(count).indPrev = near_index;     
    
    %Step 5:����Ƿ񵽴�Ŀ��㸽�� 
    %��ʾ��ע��ʹ��Ŀ�����ֵThr������ǰ�ڵ���յ��ŷʽ����С��Thr����������ǰforѭ��
    for i = 1:size(T.v,2)
        if norm([T.v(i).x - x_G,T.v(i).y - y_G])<Thr
            bFind = true;
            break
        end
    end
    
    if bFind == false
        line([x_near(1),x_new(1)],[x_near(2),x_new(2)]);
    else
        line([x_G,x_new(1)],[y_G,x_new(2)]);
        break
    end
    hold on
    %Step 6:��x_near��x_new֮���·��������
    %��ʾ 1��ʹ��plot���ƣ���ΪҪ�����ͬһ��ͼ�ϻ����߶Σ�����ÿ��ʹ��plot����Ҫ����hold on����
    %��ʾ 2�����ж��յ���������forѭ��ǰ���ǵð�x_near��x_new֮���·��������
   
    pause(0.00001); %��ͣһ�ᣬʹ��RRT��չ�������׹۲�
end
%% ·���Ѿ��ҵ��������ѯ
if bFind
    path.pos(1).x = x_G; path.pos(1).y = y_G;
    path.pos(2).x = T.v(end).x; path.pos(2).y = T.v(end).y;
    pathIndex = T.v(end).indPrev; % �յ����·��
    j=0;
    while 1
        path.pos(j+3).x = T.v(pathIndex).x;
        path.pos(j+3).y = T.v(pathIndex).y;
        pathIndex = T.v(pathIndex).indPrev;
        if pathIndex == 1
            break
        end
        j=j+1;
    end  % ���յ���ݵ����
    path.pos(end+1).x = x_I; path.pos(end).y = y_I; % ������·��
    for j = 2:length(path.pos)
        plot([path.pos(j).x; path.pos(j-1).x;], [path.pos(j).y; path.pos(j-1).y], 'b', 'Linewidth', 3);
    end
else
    disp('Error, no path found!');
end

function [nearest_pt_x,nearest_pt_y,index] = find_nearest_point(tree,point)
%     T.v(1).x = x_I;         % T������Ҫ��������v�ǽڵ㣬�����Ȱ���ʼ����뵽T������
%     T.v(1).y = y_I; 
%     T.v(1).xPrev = x_I;     % ��ʼ�ڵ�ĸ��ڵ���Ȼ���䱾��
%     T.v(1).yPrev = y_I;
%     T.v(1).dist=0;          % �Ӹ��ڵ㵽�ýڵ�ľ��룬�����ȡŷ�Ͼ���
%     T.v(1).indPrev = 0;     %
    index = 1;
    shortest_distance = norm([(tree.v(1).x - point(1)),(tree.v(1).y - point(2))]);
    for i = 1:size(tree.v,2)
        dis = norm([(tree.v(i).x - point(1)),(tree.v(i).y - point(2))]);
        if dis < shortest_distance
            index = i;
            shortest_distance = dis;
        end
    end
    nearest_pt_x = tree.v(index).x;
    nearest_pt_y = tree.v(index).y;
end
