function [fl re]=lines(im_text) 
im_text=clip(im_text); 
num_files=size(im_text,1);
for s=1:num_files
    if sum(im_text(s,:))==0
        nm=im_text(1:s-1, :); % ÝLK SATIR
        rm=im_text(s:end, :); % GERÝYE KALAN SATIRLAR
        fl = clip(nm);
        re=clip(rm);
        break
    else
        fl=im_text; % TEK SATIRDAN OLUÞUYOR
        re=[ ]; % GERÝYE KALAN SATIR YOK
    end
end
% CLÝP FONKSÝYONUNU TANITMA
function img_out=clip(img_in)
[f c]=find(img_in);
img_out=img_in(min(f):max(f),min(c):max(c));