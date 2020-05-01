function aug_img()
addpath(genpath(pwd));
fprintf('cvpr16-deepbit startup\n');

Set = 'eurosatSmall';
txtfile1 = sprintf('./data/euroSatSmall/%s_train_a.txt',Set);
fid1 = fopen(txtfile1, 'wt');
txtfile2 = sprintf('./data/euroSatSmall/%s_train_b.txt',Set);
fid2 = fopen(txtfile2, 'wt');

augmentation('/data/euroSatSmall/train-file-list.txt',fid1,fid2);

fclose(fid1);
fclose(fid2);


end

function augmentation(list_im,fid1,fid2)


if ischar(list_im)
    %Assume it is a file contaning the list of images
    %filename = list_im;
    fullDirectory = strcat(pwd,list_im);
    list_im = read_cell(fullDirectory);
end


current_path = pwd;
DataDir = '/rotations/';
PatchDir2 = sprintf('%s%s/', DataDir);

[data_num x] = size(list_im);

parfor i = 1:data_num
    fprintf('[augmentation] rotating image %d\n',i);
    img_path = list_im{i};
    img_pathFull = strcat(current_path,'/data/euroSatSmall/',img_path);
    fprintf('Image Path: %s' , img_pathFull);
    img_dirs = strsplit(img_pathFull,'/');
    img = imread(img_pathFull);
    for aug = 1:5
        PatchDir = sprintf('%s/data/euroSatSmall/rotations/%s_%d', pwd, img_dirs{13}, aug);
        if exist(PatchDir, 'dir') == 0
            mkdir(PatchDir);
        end
        f = sprintf('%s/%s',PatchDir,img_dirs{14});
        rotate_angle = 5*(aug-3);
        img2 = imrotate(img,rotate_angle);
        [x,y] = size(img2);
        img3 = imcrop(img2,[(x-32)/2 (x-32)/2 31 31]);
        fprintf('Written file name %s',f);
        imwrite(img3,f);
    end
end



for i = 1:data_num
    fprintf('[train-file-list] preparing image %d/%d\n',i,data_num);
    img_path = list_im{i};
    img_pathFull = strcat(current_path,'/data/euroSatSmall/',img_path);
    img_dirs = strsplit(img_pathFull,'/');
    for aug = 1:5
        PatchDir = sprintf('%s/data/euroSatSmall/rotations/%s_%d', pwd, img_dirs{13}, aug);
        f = sprintf('%s/%s',PatchDir,img_dirs{14});
        rotate_angle = 5*(aug-3);
        fprintf(fid1, '%s%s 1\n',pwd,img_path);
        weight = exp(1)^(-(aug-3)*(aug-3)/2);
        fprintf(fid2, '%s %f\n',f, weight);
     end
end


end

