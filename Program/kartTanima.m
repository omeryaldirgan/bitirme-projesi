clc, close all, clear all 
gR=imread('resim3.png'); 
figure, imshow(gR), title('INPUT RESMÝ');

%gR = imnoise(gR,'salt & pepper',0.08);
%imshow(gR), title('Salt & Pepper');
gR=imresize(gR,[342 NaN]);
figure, imshow(gR);
g = imcrop(gR, [0 140 828 140]);
figure, imshow(g), title('KIRPILMIS HALI');
f=g;
if size(f,3)==3 % GRÝYE DÖNÜÞTÜRME
    imagen=rgb2gray(f);
end
%imagen = imadjust(imagen,[0 1],[1 0]); %KARAKTERLERÝ BEYAZ YAPMAK ÝÇÝN NEGATÝFÝNÝ ALDIK
imagen=medfilt2(imagen,[3 3]); % MEDYAN FÝLTRE ÝLE GÜRÜLTÜLERÝ TEMÝZLEME
figure, imshow(imagen), title('FÝLTRELEMEDEN SONRA');

[~, threshold] = edge(imagen, 'sobel');
fudgeFactor = .70;
KB = edge(imagen,'sobel', threshold * fudgeFactor);
figure, imshow(KB), title('KENARLARI BULMAK ÝÇÝN');

df=strel('disk',3); % MORFOLOJÝK ÝSLEMLER ÝCÝN DISK FÝLTRELEME YARICAPI 3
ra=imdilate(KB,df); % GRÝ RESMÝ STREL ÝSLEMÝNE GÖRE AÇMA ÝSLEMÝ
ras=imerode(KB,df); % RESMÝ STRELE GÖRE AÞINDIRMA ÝÞLEMÝ
gdiff=imsubtract(ra,ras); % KENARLARI ÝYÝLEÞTÝRMEK ÝÇÝN GRÝ TONLARI AYIRMA ÝÞLEMÝ
KBks = imclearborder(gdiff, 26);
figure, imshow(KBks), title('KENARLARI TEMÝZLENMÝS HALÝ');
imagen = imadjust(KBks,[0 1],[1 0]);%NEGATÝFÝ
figure, imshow(imagen);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gdiff=mat2gray(imagen);
% gdiff=conv2(gdiff,[1 1;1 1]);
% gdiff=imadjust(gdiff,[0.5 0.7],[0 1],0.1);
% figure, imshow(gdiff), title('convoluted');

% B=logical(gdiff);
% er=imerode(B,strel('line',50,0));
% out1=imsubtract(B,er);
% 
% F=imfill(out1,'holes');
% F=imclearborder(F, 6);
% figure, imshow(F), title('after filling and elimination of horizantal lines');
% F = imadjust(KBks,[0 1],[1 0]);
% H=bwmorph(F,'thin',3);
% H=imerode(H,strel('line',2,90));
% final=bwareaopen(H,150);
% figure,imshow(final);
% figure, imshow(final), title('final');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

threshold = graythresh(imagen); % TÜM RESMÝ BAZ ALARAK(ORTALAMA) MATLAB OTOMATÝK OLARAK THRESHOLD DEÐERÝ ATIYOR.
imagen =~im2bw(imagen,threshold); % ÝNPUT RESMÝMÝZE UYGULUYORUZ. FAKAT NOT EQUAL OPERATORUNU KULLANIYORUZ CUNKU BÝZÝM TEMPLATESLERÝMÝZ SÝYAH ÜZERÝNE BEYAZ KARAKTERLER.
imagen = bwareaopen(imagen,30); % 30-CONNECTED NEÝGHBORHOOD OLMAYANLARI RESÝMDEN ELÝYORUZ. SÝYAH(SIFIR) YAPIYORUZ.
word=[ ]; % text DOSYASINA YAZACAÐIMIZ KARAKTERLERÝ WORD STRÝNGÝNDE DEPOLAYACAÐIZ.
re=imagen; % KOLAY YAZMAK ÝÇÝN KISALTIYORUZ.
fid = fopen('text.txt', 'wt');
load templates % BELÝNEN TEPMLATESLERÝ YÜKLEME.
global templates % TEMPLATESLERÝ PROGRAM ÝÇERÝSÝNDE GLOBAL YAPMA.
num_letras=size(templates,2); % 36 TANE KARAKTERÝMÝZ VAR(HARFLER VE RAKAMLAR OLMAK ÜZERE)
while 1
    [fl re]=lines(re); % LÝNES FONKSÝYONU
    imgn=fl;
    [L Ne] = bwlabel(imgn); % BURADA RESMÝN ÝÇÝNDEKÝ COMPONENTLERÝ(FARKLI KARAKTERLERÝ) TANIMLIYORUZ. "NE" KAÇ TANE KARAKTER OLDUÐUNU GÖSTERÝYOR.
    for n=1:Ne
        [r,c] = find(L==n); % MESELA n=2 ÝÇÝN BULDUÐU COMPONENT(KARAKTER) RC MATRÝXÝNÝ OLUÞTURUYOR. RC MATRÝSÝ ONUN YERÝNÝ BELÝRLÝYOR(LOCATÝON). 
        n1=imgn(min(r):max(r),min(c):max(c)); % N1 COMPONENTÝ(KARAKTER) ÝÇÝN SOL ÜSTEN SAÐ ALTA KADAR SINIRLIYORUZ ONU, O COMPONENTÝ OLUÞTURAN YERLERÝ BELÝRTÝYOR. 
        img_r=imresize(n1,[42 24]); % TEMPLATESLERÝMÝZ 42X24 PÝXEL OLDUKLARI ÝÇÝN, BULUNAN KARAKTERÝ YENÝDEN BOYUTLANDIRIYORUZ.
        letter=sayilari_oku(img_r,num_letras); % SAYILARI_OKU FONKSÝYONU ÇAÐIRILIYOR.
        word=[word letter]; % WORD MATRÝXÝ ÝÇERÝSÝNE BULUNAN KARAKTER YAZILIYOR. HER SEFERÝNDE BULUNAN KARAKTER SÝLÝNMEMESÝ ÝÇÝN BU FORMATTA TANIMLIYORUZ.
    end
    fprintf(fid,'%s\n',lower(word)); 
    word=[ ]; % ÝKÝNCÝ SATIR ÝÇÝN , MATRÝSÝ BOÞALTIYORUZ.
    if isempty(re) % EÐER RE BOÞSA LOOPTAN ÇIKIYORUZ.
        break
    end    
end
fclose(fid); % TEXT DOSYASINI KAPATIYORUZ.
winopen('text.txt');
clear all