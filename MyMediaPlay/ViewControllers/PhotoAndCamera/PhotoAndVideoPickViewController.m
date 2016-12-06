//
//  PhotoAndVideoPickViewController.m
//  MyMediaPlay
//
//  Created by Yinjw on 2016/10/10.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import "PhotoAndVideoPickViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ModifyPhotoViewController.h"
#import "Macros.h"

@interface PhotoAndVideoPickViewController ()

@property(nonatomic)BOOL                        isPickVideo;

@end

@implementation PhotoAndVideoPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

-(void)setupUI
{
    UIView* pickView = [[UIView alloc] init];
    pickView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:pickView];
    [pickView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIButton* pickPhotoButton = [[UIButton alloc] init];
    [pickPhotoButton.layer setBorderWidth:1];
    [pickPhotoButton.layer setCornerRadius:5];
    [pickPhotoButton setTitle:@"拍照" forState:UIControlStateNormal];
    [pickPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pickPhotoButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [pickPhotoButton addTarget:self action:@selector(onBtnPhotoPick:) forControlEvents:UIControlEventTouchUpInside];
    [pickView addSubview:pickPhotoButton];
    [pickPhotoButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(pickView);
        make.left.equalTo(pickView).offset(40);
        make.width.equalTo(100);
        make.height.equalTo(30);
    }];
    
    UIButton* pickVideoButton = [[UIButton alloc] init];
    [pickVideoButton.layer setBorderWidth:1];
    [pickVideoButton.layer setCornerRadius:5];
    [pickVideoButton setTitle:@"视频" forState:UIControlStateNormal];
    [pickVideoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pickVideoButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [pickVideoButton addTarget:self action:@selector(onBtnVideoPick:) forControlEvents:UIControlEventTouchUpInside];
    [pickView addSubview:pickVideoButton];
    [pickVideoButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(pickView);
        make.right.equalTo(pickView).offset(-40);
        make.width.equalTo(100);
        make.height.equalTo(30);
    }];
}

#pragma mark - button event

-(void)onBtnPhotoPick:(id)sender
{
    self.isPickVideo = NO;
    [self openPicker];
}

-(void)onBtnVideoPick:(id)sender
{
    self.isPickVideo = YES;
    [self openPicker];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (picker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        
        ModifyPhotoViewController* modifyView = [[ModifyPhotoViewController alloc] initWithImage:image];
        SWITCH_VIEW(self, modifyView, NO);
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        NSLog(@"video...");
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
//        NSURL *url=[NSURL fileURLWithPath:videoPath];
//        AVPlayer* avplayer = [AVPlayer playerWithURL:url];
//        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:avplayer];
//        playerLayer.frame=self.showPhoto.frame;
//        [self.showPhoto.layer addSublayer:playerLayer];
//        [avplayer play];
        
    }
}

#pragma mark - self method

-(void)openPicker
{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    if(self.isPickVideo)
    {
        imagePicker.mediaTypes = @[(NSString*)kUTTypeMovie];
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    }
    else
    {
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

@end
