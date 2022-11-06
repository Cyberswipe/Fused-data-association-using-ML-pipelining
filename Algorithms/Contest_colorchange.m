function out = Contest_colorchange(CMap)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

out=zeros(size(CMap,1),size(CMap,2),3);

[x0,y0]=find(CMap==0);
for i=1:length(x0)
    out(x0(i),y0(i),1)=128;
    out(x0(i),y0(i),2)=128;
    out(x0(i),y0(i),3)=128;
end

[x1,y1]=find(CMap==1);
for i=1:length(x1)
    out(x1(i),y1(i),1)=0;
    out(x1(i),y1(i),2)=205;
    out(x1(i),y1(i),3)=0;
end

[x2,y2]=find(CMap==2);
for i=1:length(x2)
    out(x2(i),y2(i),1)=127;
    out(x2(i),y2(i),2)=255;
    out(x2(i),y2(i),3)=0;
end

[x3,y3]=find(CMap==3);
for i=1:length(x3)
    out(x3(i),y3(i),1)=46;
    out(x3(i),y3(i),2)=139;
    out(x3(i),y3(i),3)=87;
end


[x4,y4]=find(CMap==4);
for i=1:length(x4)
    out(x4(i),y4(i),1)=0;
    out(x4(i),y4(i),2)=139;
    out(x4(i),y4(i),3)=0;
end

[x5,y5]=find(CMap==5);
for i=1:length(x5)
    out(x5(i),y5(i),1)=160;
    out(x5(i),y5(i),2)=82;
    out(x5(i),y5(i),3)=45;
end

[x6,y6]=find(CMap==6);
for i=1:length(x6)
    out(x6(i),y6(i),1)=0;
    out(x6(i),y6(i),2)=255;
    out(x6(i),y6(i),3)=255;
end

[x7,y7]=find(CMap==7);
for i=1:length(x7)
    out(x7(i),y7(i),1)=255;
    out(x7(i),y7(i),2)=255;
    out(x7(i),y7(i),3)=255;
end

[x8,y8]=find(CMap==8);
for i=1:length(x8)
    out(x8(i),y8(i),1)=216;
    out(x8(i),y8(i),2)=191;
    out(x8(i),y8(i),3)=216;
end

[x9,y9]=find(CMap==9);
for i=1:length(x9)
    out(x9(i),y9(i),1)=255;
    out(x9(i),y9(i),2)=0;
    out(x9(i),y9(i),3)=0;
end

[x10,y10]=find(CMap==10);
for i=1:length(x10)
    out(x10(i),y10(i),1)=139;
    out(x10(i),y10(i),2)=0;
    out(x10(i),y10(i),3)=0;
end

[x11,y11]=find(CMap==11);
for i=1:length(x11)
    out(x11(i),y11(i),1)=0;
    out(x11(i),y11(i),2)=0;
    out(x11(i),y11(i),3)=0;
end

[x12,y12]=find(CMap==12);
for i=1:length(x12)
    out(x12(i),y12(i),1)=255;
    out(x12(i),y12(i),2)=255;
    out(x12(i),y12(i),3)=0;
end

[x13,y13]=find(CMap==13);
for i=1:length(x13)
    out(x13(i),y13(i),1)=238;
    out(x13(i),y13(i),2)=154;
    out(x13(i),y13(i),3)=0;
end


[x14,y14]=find(CMap==14);
for i=1:length(x14)
    out(x14(i),y14(i),1)=85;
    out(x14(i),y14(i),2)=26;
    out(x14(i),y14(i),3)=139;
end

[x15,y15]=find(CMap==15);
for i=1:length(x15)
    out(x15(i),y15(i),1)=255;
    out(x15(i),y15(i),2)=127;
    out(x15(i),y15(i),3)=80;
end
