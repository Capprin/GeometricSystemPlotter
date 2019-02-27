function meshdemo2d
%MESHDEMO2d Distmesh2d examples.

%   Copyright (C) 2004-2006 Per-Olof Persson. See COPYRIGHT.TXT for details.

rand('state',111); % Always the same results
set(gcf,'rend','z');

disp('(1a) Unit circle, h=0.4')
fd=inline('sqrt(sum(p.^2,2))-1','p');
[p,t]=distmesh2d(fd,@huniform,0.4,[-1,-1;1,1],[]);
post(p,t,@huniform)

disp('(1b) Unit circle, h=0.2')
fd=inline('sqrt(sum(p.^2,2))-1','p');
[p,t]=distmesh2d(fd,@huniform,0.2,[-1,-1;1,1],[]);
post(p,t,@huniform)

disp('(1c) Unit circle, h=0.1')
fd=inline('sqrt(sum(p.^2,2))-1','p');
[p,t]=distmesh2d(fd,@huniform,0.1,[-1,-1;1,1],[]);
post(p,t,@huniform)

disp('(2) Unit circle with hole')
fd=inline('ddiff(dcircle(p,0,0,1),dcircle(p,0,0,0.4))','p');
box=[-1,-1;1,1];
[p,t]=distmesh2d(fd,@huniform,0.1,box,[]);
post(p,t,@huniform)

disp('(3a) Square with hole (uniform)')
fd=inline('ddiff(drectangle(p,-1,1,-1,1),dcircle(p,0,0,0.4))','p');
box=[-1,-1;1,1];
fix=[-1,-1;-1,1;1,-1;1,1];
[p,t]=distmesh2d(fd,@huniform,0.15,box,fix);
post(p,t,@huniform)

disp('(3b) Square with hole (refined at hole)')
fd=inline('ddiff(drectangle(p,-1,1,-1,1),dcircle(p,0,0,0.4))','p');
box=[-1,-1;1,1];
fix=[-1,-1;-1,1;1,-1;1,1];
fh=inline('min(4*sqrt(sum(p.^2,2))-1,2)','p');
[p,t]=distmesh2d(fd,fh,0.05,box,fix);
post(p,t,fh)

disp('(4) Polygons')
fd=inline('ddiff(dpoly(p,fix),dpoly(p,.5*fix*[cos(pi/6),-sin(pi/6);sin(pi/6),cos(pi/6)]))','p','fix');
n=6;
phi=(0:n)'/n*2*pi;
box=[-1,-1;1,1];
fix=[cos(phi),sin(phi)];
[p,t]=distmesh2d(fd,@huniform,0.1,box,[fix;.5*fix*[cos(pi/6),-sin(pi/6);sin(pi/6),cos(pi/6)]],fix);
post(p,t,@huniform)

disp('(5) Geometric Adaptivity')
fix=[-1,0;-.95,0;.1,0;1,0];
[p,t]=distmesh2d(@fd5,@fh5,0.015,[-1,0;1,1],fix);
post(p,t,@fh5)

%%% (6) and (7) are very slow

%disp('(6) Superellipse')
%box=[-1.05,-1.05;1,1];
%[p,t]=distmesh2d(@fd6,@fh6,0.08,box,[]);
%post(p,t,@fh6)

%disp('(7) Implicit')
%box=[-5*pi/2,-5;5*pi/2,2];
%fix=5*pi/2*[-1,0;1,0];
%[p,t]=distmesh2d(@fd7,@huniform,0.75,box,fix);
%post(p,t,@huniform)

disp('(8) Pie with holes')
c=(sqrt(119)-9)/20;
fix=[.9+c,c;cos(pi/12),sin(pi/12)];
fix=[fix;fix];
fix(3:4,2)=-fix(3:4,2);
fix=[fix;0,0;0.9,0];
box=[0,-1;1,1];
[p,t]=distmesh2d(@fd8,@fh8,0.005,box,fix);
post(p,t,@fh8)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function post(p,t,fh,varargin)

q=simpqual(p,t);
u=uniformity(p,t,fh,varargin{:});
disp(sprintf(' - Min quality %.2f',min(q)))
disp(sprintf(' - Uniformity %.1f%%',100*u))
disp(sprintf('   (press any key)'))
disp(' ')
pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function d=fd5(p)

d1=dcircle(p,0,0,1);
d2=dcircle(p,-.4,0,.55);
d=dintersect(-p(:,2),ddiff(d1,d2));

function h=fh5(p)

d1=dcircle(p,0,0,1);
d2=dcircle(p,-.4,0,.55);

h1=(0.15-0.2*d1);
h2=(0.06+0.2*d2);
h3=(d2-d1)/3;

h=min(min(h1,h2),h3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function d=fd6(p)

d=ddiff(dexpr(p,'(x^4+y^4)^(1/4)-1'),dexpr(p,'(x^4+y^4)^(1/4)-0.5'));

function h=fh6(p)

h=dexpr(p,'(x^4+y^4)^(1/4)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function d=fd7(p)

d1=dexpr(p,'y-cos(x)');
d2=dexpr(p,'-(y-(-5+5/(5/4*2*pi)^4*x^4))');
d=dintersect(d1,d2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function d=fd8(p)

g1=dcircle(p,0,0,1);
g2=drectangle(protate(p,pi/12),-1,1,0,1);
g3=drectangle(protate(p,-pi/12),-1,1,-1,0);
g4=drectangle(protate(pshift(p,-.9,0),-pi/4),0,.2,0,.2);
g5=dcircle(p,.6,0,.1);

d=ddiff(ddiff(ddiff(ddiff(g1,g2),g3),g4),g5);

function h=fh8(p)

h1=0.005+0.2*sqrt(sum(p.^2,2));
h2=0.02+0.2*(sqrt((p(:,1)-.6).^2+p(:,2).^2)-.1);
h3=0.005+0.2*sqrt((p(:,1)-.9).^2+p(:,2).^2);
h=min(min(min(h1,h2),h3),0.03);
