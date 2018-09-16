clc, close all, clear all 
gR=imread('resim3.png'); 
figure, imshow(gR), title('INPUT RESM�');

%gR = imnoise(gR,'salt & pepper',0.08);
%imshow(gR), title('Salt & Pepper');
gR=imresize(gR,[342 NaN]);
figure, imshow(gR);
g = imcrop(gR, [0 140 828 140]);
figure, imshow(g), title('KIRPILMIS HALI');
f=g;
if size(f,3)==3 % GR�YE D�N��T�RME
    imagen=rgb2gray(f);
end
%imagen = imadjust(imagen,[0 1],[1 0]); %KARAKTERLER� BEYAZ YAPMAK ���N NEGAT�F�N� ALDIK
imagen=medfilt2(imagen,[3 3]); % MEDYAN F�LTRE �LE G�R�LT�LER� TEM�ZLEME
figure, imshow(imagen), title('F�LTRELEMEDEN SONRA');

[~, threshold] = edge(imagen, 'sobel');
fudgeFactor = .70;
KB = edge(imagen,'sobel', threshold * fudgeFactor);
figure, imshow(KB), title('KENARLARI BULMAK ���N');

df=strel('disk',3); % MORFOLOJ�K �SLEMLER �C�N DISK F�LTRELEME YARICAPI 3
ra=imdilate(KB,df); % GR� RESM� STREL �SLEM�NE G�RE A�MA �SLEM�
ras=imerode(KB,df); % RESM� STRELE G�RE A�INDIRMA ��LEM�
gdiff=imsubtract(ra,ras); % KENARLARI �Y�LE�T�RMEK ���N GR� TONLARI AYIRMA ��LEM�
KBks = imclearborder(gdiff, 26);
figure, imshow(KBks), title('KENARLARI TEM�ZLENM�S HAL�');
imagen = imadjust(KBks,[0 1],[1 0]);%NEGAT�F�
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

threshold = graythresh(imagen); % T�M RESM� BAZ ALARAK(ORTALAMA) MATLAB OTOMAT�K OLARAK THRESHOLD DE�ER� ATIYOR.
imagen =~im2bw(imagen,threshold); % �NPUT RESM�M�ZE UYGULUYORUZ. FAKAT NOT EQUAL OPERATORUNU KULLANIYORUZ CUNKU B�Z�M TEMPLATESLER�M�Z S�YAH �ZER�NE BEYAZ KARAKTERLER.
imagen = bwareaopen(imagen,30); % 30-CONNECTED NE�GHBORHOOD OLMAYANLARI RES�MDEN EL�YORUZ. S�YAH(SIFIR) YAPIYORUZ.
word=[ ]; % text DOSYASINA YAZACA�IMIZ KARAKTERLER� WORD STR�NG�NDE DEPOLAYACA�IZ.
re=imagen; % KOLAY YAZMAK ���N KISALTIYORUZ.
fid = fopen('text.txt', 'wt');
load templates % BEL�NEN TEPMLATESLER� Y�KLEME.
global templates % TEMPLATESLER� PROGRAM ��ER�S�NDE GLOBAL YAPMA.
num_letras=size(templates,2); % 36 TANE KARAKTER�M�Z VAR(HARFLER VE RAKAMLAR OLMAK �ZERE)
while 1
    [fl re]=lines(re); % L�NES FONKS�YONU
    imgn=fl;
    [L Ne] = bwlabel(imgn); % BURADA RESM�N ���NDEK� COMPONENTLER�(FARKLI KARAKTERLER�) TANIMLIYORUZ. "NE" KA� TANE KARAKTER OLDU�UNU G�STER�YOR.
    for n=1:Ne
        [r,c] = find(L==n); % MESELA n=2 ���N BULDU�U COMPONENT(KARAKTER) RC MATR�X�N� OLU�TURUYOR. RC MATR�S� ONUN YER�N� BEL�RL�YOR(LOCAT�ON). 
        n1=imgn(min(r):max(r),min(c):max(c)); % N1 COMPONENT�(KARAKTER) ���N SOL �STEN SA� ALTA KADAR SINIRLIYORUZ ONU, O COMPONENT� OLU�TURAN YERLER� BEL�RT�YOR. 
        img_r=imresize(n1,[42 24]); % TEMPLATESLER�M�Z 42X24 P�XEL OLDUKLARI ���N, BULUNAN KARAKTER� YEN�DEN BOYUTLANDIRIYORUZ.
        letter=sayilari_oku(img_r,num_letras); % SAYILARI_OKU FONKS�YONU �A�IRILIYOR.
        word=[word letter]; % WORD MATR�X� ��ER�S�NE BULUNAN KARAKTER YAZILIYOR. HER SEFER�NDE BULUNAN KARAKTER S�L�NMEMES� ���N BU FORMATTA TANIMLIYORUZ.
    end
    fprintf(fid,'%s\n',lower(word)); 
    word=[ ]; % �K�NC� SATIR ���N , MATR�S� BO�ALTIYORUZ.
    if isempty(re) % E�ER RE BO�SA LOOPTAN �IKIYORUZ.
        break
    end    
end
fclose(fid); % TEXT DOSYASINI KAPATIYORUZ.
winopen('text.txt');
clear all