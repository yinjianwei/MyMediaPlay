//
//  ModifyPhotoViewController.m
//  MyMediaPlay
//
//  Created by Yinjw on 2016/12/6.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import "ModifyPhotoViewController.h"
#import "GPUImage.h"

@interface ModifyPhotoViewController ()

@property(nonatomic, strong)GPUImageView*   gpuimageView;
@property(nonatomic, strong)UIImageView*    showPhoto;
@property(nonatomic, strong)UIImage*        originImage;
@property(nonatomic, strong)UIView*         adjustView;

@property(nonatomic, strong)UIButton*       lastSelectBtn;
@property(nonatomic)NSInteger               currentFliterIndex;
@property(nonatomic, strong)NSMutableDictionary*   paramDict;

@property(nonatomic, strong)GPUImagePicture*        currentPicture;
@property(nonatomic, strong)GPUImageOutput<GPUImageInput>* filter;

@end

@implementation ModifyPhotoViewController

-(instancetype)initWithImage:(UIImage *)photoImage
{
    self = [super init];
    if(self)
    {
        self.originImage = photoImage;
    }
    return self;
}

-(void)didReceiveMemoryWarning
{
    NSLog(@"memory warning!");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(onBtnSave:)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.currentFliterIndex = 0;
    self.paramDict = [NSMutableDictionary dictionary];
    
    [self setupUI];
}

-(void)setupUI
{
    self.gpuimageView = [[GPUImageView alloc] init];
    [self.gpuimageView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.gpuimageView.layer setBorderWidth:0.5f];
    [self.gpuimageView.layer setCornerRadius:5];
    self.gpuimageView.clipsToBounds = YES;
    [self.view addSubview:self.gpuimageView];
    [self.gpuimageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(self.view.frame.size.width/6);
        make.right.equalTo(self.view).offset(-self.view.frame.size.width/6);
        make.height.equalTo(self.gpuimageView.width).multipliedBy(4.0/3);
    }];
    
    self.showPhoto = [[UIImageView alloc] initWithImage:self.originImage];
    [self.gpuimageView addSubview:self.showPhoto];
    [self.showPhoto makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.gpuimageView);
    }];
    
    UIScrollView* btnScrollView = [[UIScrollView alloc] init];
    [btnScrollView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [btnScrollView.layer setBorderWidth:0.5];
    [self.view addSubview:btnScrollView];
    [btnScrollView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showPhoto.mas_bottom).offset(25);
        make.left.right.equalTo(self.view);
        make.height.equalTo(50);
    }];
    
    UIView* btnView = [[UIView alloc] init];
    [btnScrollView addSubview:btnView];
    [btnView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(btnScrollView);
        make.height.equalTo(btnScrollView);
    }];
    
    NSArray* btnTitles = @[@"原照", @"怀旧", @"锐化", @"高斯模糊", @"像素化", @"噪点", @"浮雕", @"素描", @"油画"];
    UIButton* lastBtn = nil;
    for(int i = 0;i < btnTitles.count;++i)
    {
        UIButton* btn = [[UIButton alloc] init];
        [btn.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [btn.layer setBorderWidth:0.5f];
        [btn.layer setCornerRadius:2];
        [btn setTitle:[btnTitles objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(onBtnEdit:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [btnView addSubview:btn];
        [btn makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(btnView);
            if(lastBtn)
            {
                make.left.equalTo(lastBtn.mas_right).offset(5);
            }
            else
            {
                make.left.equalTo(btnView).offset(15);
            }
            if(i == btnTitles.count-1)
            {
                make.right.equalTo(btnView).offset(-15);
            }
            make.height.equalTo(30);
            make.width.equalTo(60);
        }];
        
        lastBtn = btn;
    }
    
    UIScrollView* adjustScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:adjustScrollView];
    [adjustScrollView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnScrollView.mas_bottom).offset(5);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    self.adjustView = [[UIView alloc] init];
    [adjustScrollView addSubview:self.adjustView];
    [self.adjustView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(adjustScrollView);
        make.width.equalTo(adjustScrollView);
    }];
}

#pragma mark - button event

-(void)onBtnSave:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(self.showPhoto.image, nil, nil, nil);//保存到相簿
}

-(void)onBtnEdit:(id)sender
{
    if(!self.showPhoto)
        return;
    
    if(self.lastSelectBtn)
    {
        [self.lastSelectBtn.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    }
    UIButton* btn = (UIButton*)sender;
    [btn.layer setBorderColor:[UIColor redColor].CGColor];
    self.lastSelectBtn = btn;
    
    self.currentFliterIndex = btn.tag;
    switch (btn.tag) {
        case 0:
            [self editPhotoToOrigin];
            [self createSliders:nil];
            break;
        case 1:
            [self editPhtotWithSepiaFilter];
            [self createSliders:nil];
            break;
        case 2:
            self.paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(0), @"sharpness", nil];
            [self editPhotoWithSharpenFilter];
            [self createSliders:@[@[@"sharpness", @(50), @(0), @(100)]]];
            break;
        case 3:
            self.paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(0.5), @"texelSpacingMultiplier", @(5), @"blurRadiusInPixels", @(5), @"blurPasses", nil];
            [self editPhotoWithGaussianBlurFilter];
            [self createSliders:@[@[@"texelSpacingMultiplier", @(5), @(0.0), @(100.0)],
                                  @[@"blurRadiusInPixels", @(5), @(0.0), @(24.0)],
                                  @[@"blurPasses", @(5), @(0), @(100)]]];
            break;
        case 4:
            self.paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(5), @"fractionalWidthOfAPixel", nil];
            [self editPhotoWithPixellate];
            [self createSliders:@[@[@"fractionalWidthOfAPixel", @(5), @(0), @(100)]]];
            break;
        case 5:
            self.paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(5), @"colorLevels", nil];
            [self editPhotoWithPosterize];
            [self createSliders:@[@[@"colorLevels", @(5), @(1), @(20)]]];
            break;
        case 6:
            self.paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(5), @"intensity", nil];
            [self editPhotoWithEmboss];
            [self createSliders:@[@[@"intensity", @(5), @(0), @(10)]]];
            break;
        case 7:
            self.paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(1), @"edgeStrength", nil];
            [self editPhotoWithSketch];
            [self createSliders:@[@[@"edgeStrength", @(1), @(0), @(10)]]];
            break;
        case 8:
            self.paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(1), @"radius", nil];
            [self editPhotoWithOilPaint];
            [self createSliders:@[@[@"radius", @(1), @(0), @(10)]]];
            break;
            
        default:
            break;
    }
}

#pragma mark - ValueSliderViewDelegate

-(void)updateSliderValue:(CGFloat)value valueKey:(NSString *)valueKey
{
    [self.paramDict setObject:@(value) forKey:valueKey];
    NSArray* ary = @[NSStringFromSelector(@selector(editPhotoToOrigin)),
                     NSStringFromSelector(@selector(editPhtotWithSepiaFilter)),
                     NSStringFromSelector(@selector(editPhotoWithSharpenFilter)),
                     NSStringFromSelector(@selector(editPhotoWithGaussianBlurFilter)),
                     NSStringFromSelector(@selector(editPhotoWithPixellate)),
                     NSStringFromSelector(@selector(editPhotoWithPosterize)),
                     NSStringFromSelector(@selector(editPhotoWithEmboss)),
                     NSStringFromSelector(@selector(editPhotoWithSketch)),
                     NSStringFromSelector(@selector(editPhotoWithOilPaint))];
    SEL selector = NSSelectorFromString([ary objectAtIndex:self.currentFliterIndex]);
    
    //使用performSelector在arc模式下会产生warning，解决方法有3种
    //method1
    //#pragma clang diagnostic push
    //#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    //        [self performSelector:selector];
    //#pragma clang diagnostic pop
    
    //method2
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(self, selector);
    
    //method3
    //        [self performSelector:selector withObject:nil afterDelay:0.0];
}

#pragma mark - self method

-(void)createSliders:(NSArray*)sliderInfos
{
    [self.adjustView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    if(!sliderInfos || sliderInfos.count == 0)
    {
        return;
    }
    
    ValueSliderView* lastSlider = nil;
    
    for(int i = 0;i < sliderInfos.count;++i)
    {
        NSArray* info = [sliderInfos objectAtIndex:i];
        NSNumber* value = (NSNumber*)[info objectAtIndex:1];
        NSNumber* minValue = (NSNumber*)[info objectAtIndex:2];
        NSNumber* maxValue = (NSNumber*)[info objectAtIndex:3];
        ValueSliderView* slider = [[ValueSliderView alloc] initWithTitle:[info objectAtIndex:0] value:value.floatValue minValue:minValue.floatValue maxValue:maxValue.floatValue];
        slider.delegate = self;
        slider.valueKey = [info objectAtIndex:0];
        [self.adjustView addSubview:slider];
        [slider makeConstraints:^(MASConstraintMaker *make) {
            if(lastSlider)
            {
                make.top.equalTo(lastSlider.mas_bottom).offset(10);
            }
            else
            {
                make.top.equalTo(self.adjustView).offset(10);
            }
            make.left.right.equalTo(self.adjustView);
            if(i == sliderInfos.count-1)
            {
                make.bottom.equalTo(self.adjustView).offset(-10);
            }
        }];
        
        lastSlider = slider;
    }
}

-(void)editPhotoToOrigin
{
    self.showPhoto.image = self.originImage;
}

-(void)editPhtotWithSepiaFilter
{
    if(self.filter && [self.filter isKindOfClass:[GPUImageSepiaFilter class]])
    {
        return;
    }
    
    GPUImagePicture* imageSource = [[GPUImagePicture alloc] initWithImage:self.originImage];
    self.filter = [[GPUImageSepiaFilter alloc] init];
    [self.filter forceProcessingAtSize:self.originImage.size];
    [imageSource addTarget:self.filter];
    [self.filter useNextFrameForImageCapture];
    [imageSource processImage];
    UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
    self.showPhoto.image = editImage;
    self.currentPicture = imageSource;
    
    [self createSliders:nil];
}

-(void)editPhotoWithSharpenFilter
{
    if(self.filter && [self.filter isKindOfClass:[GPUImageSharpenFilter class]])
    {
        NSNumber* value = [self.paramDict objectForKey:@"sharpness"];
        [(GPUImageSharpenFilter*)self.filter setSharpness:value ? value.floatValue/25.0f : 0];
        [self.filter useNextFrameForImageCapture];
        [self.currentPicture processImage];
        UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
        self.showPhoto.image = editImage;
        return;
    }
    
    GPUImagePicture* imageSource = [[GPUImagePicture alloc] initWithImage:self.originImage];
    GPUImageSharpenFilter* sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    NSNumber* value = [self.paramDict objectForKey:@"sharpness"];
    sharpenFilter.sharpness = value ? value.floatValue/25.0f : 0;
    self.filter = sharpenFilter;
    [imageSource addTarget:self.filter];
    [self.filter useNextFrameForImageCapture];
    [imageSource processImage];
    UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
    self.showPhoto.image = editImage;
    self.currentPicture = imageSource;
}

-(void)editPhotoWithGaussianBlurFilter
{
    if(self.filter && [self.filter isKindOfClass:[GPUImageGaussianBlurFilter class]])
    {
        GPUImageGaussianBlurFilter* gaussianBlurFilter = (GPUImageGaussianBlurFilter*)self.filter;
//        NSNumber* value1 = [self.paramDict objectForKey:@"texelSpacingMultiplier"];
//        gaussianBlurFilter.texelSpacingMultiplier = value1 ? value1.floatValue : 5;
        NSNumber* value2 = [self.paramDict objectForKey:@"blurRadiusInPixels"];
        gaussianBlurFilter.blurRadiusInPixels = value2 ? value2.floatValue : 5;
//        NSNumber* value3 = [self.paramDict objectForKey:@"blurPasses"];
//        gaussianBlurFilter.blurPasses = value3 ? value3.floatValue : 5;
//        [self.filter useNextFrameForImageCapture];
//        [self.currentPicture processImage];
//        UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
//        self.showPhoto.image = editImage;
        return;
    }
    
    GPUImagePicture* imageSource = [[GPUImagePicture alloc] initWithImage:self.originImage];
    GPUImageGaussianBlurFilter* gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    NSNumber* value1 = [self.paramDict objectForKey:@"texelSpacingMultiplier"];
    gaussianBlurFilter.texelSpacingMultiplier = value1 ? value1.floatValue : 5;
    NSNumber* value2 = [self.paramDict objectForKey:@"blurRadiusInPixels"];
    gaussianBlurFilter.blurRadiusInPixels = value2 ? value2.floatValue : 5;
    NSNumber* value3 = [self.paramDict objectForKey:@"blurPasses"];
    gaussianBlurFilter.blurPasses = value3 ? value3.floatValue : 5;
    self.filter = gaussianBlurFilter;
    [imageSource addTarget:self.filter];
    [self.filter addTarget:self.gpuimageView];
    [self.filter useNextFrameForImageCapture];
    [imageSource processImage];
    UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
    self.showPhoto.image = editImage;
    self.currentPicture = imageSource;
}

-(void)editPhotoWithPixellate
{
    if(self.filter && [self.filter isKindOfClass:[GPUImagePixellateFilter class]])
    {
        NSNumber* value = [self.paramDict objectForKey:@"fractionalWidthOfAPixel"];
        [(GPUImagePixellateFilter*)self.filter setFractionalWidthOfAPixel:value ? value.floatValue/1000.0 : 0];
        [self.filter useNextFrameForImageCapture];
        [self.currentPicture processImage];
        UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
        self.showPhoto.image = editImage;
        return;
    }
    
    GPUImagePicture* imageSource = [[GPUImagePicture alloc] initWithImage:self.originImage];
    GPUImagePixellateFilter* pixellateFilter = [[GPUImagePixellateFilter alloc] init];
    NSNumber* value1 = [self.paramDict objectForKey:@"fractionalWidthOfAPixel"];
    pixellateFilter.fractionalWidthOfAPixel = value1 ? value1.floatValue/1000.0 : 0;
    self.filter = pixellateFilter;
    [imageSource addTarget:self.filter];
    [self.filter useNextFrameForImageCapture];
    [imageSource processImage];
    UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
    self.showPhoto.image = editImage;
    self.currentPicture = imageSource;
}

-(void)editPhotoWithPosterize
{
    if(self.filter && [self.filter isKindOfClass:[GPUImagePosterizeFilter class]])
    {
        NSNumber* value = [self.paramDict objectForKey:@"colorLevels"];
        [(GPUImagePosterizeFilter*)self.filter setColorLevels:value ? value.floatValue : 1];
        [self.filter useNextFrameForImageCapture];
        [self.currentPicture processImage];
        UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
        self.showPhoto.image = editImage;
        return;
    }
    
    GPUImagePicture* imageSource = [[GPUImagePicture alloc] initWithImage:self.originImage];
    GPUImagePosterizeFilter* posterizeFilter = [[GPUImagePosterizeFilter alloc] init];
    NSNumber* value1 = [self.paramDict objectForKey:@"colorLevels"];
    posterizeFilter.colorLevels = value1 ? value1.floatValue : 1;
    self.filter = posterizeFilter;
    [imageSource addTarget:self.filter];
    [self.filter useNextFrameForImageCapture];
    [imageSource processImage];
    UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
    self.showPhoto.image = editImage;
    self.currentPicture = imageSource;
}

-(void)editPhotoWithEmboss
{
    if(self.filter && [self.filter isKindOfClass:[GPUImageEmbossFilter class]])
    {
        NSNumber* value = [self.paramDict objectForKey:@"intensity"];
        [(GPUImageEmbossFilter*)self.filter setIntensity:value ? 4 * value.floatValue/10.0 : 1];
        [self.filter useNextFrameForImageCapture];
        [self.currentPicture processImage];
        UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
        self.showPhoto.image = editImage;
        return;
    }
    
    GPUImagePicture* imageSource = [[GPUImagePicture alloc] initWithImage:self.originImage];
    GPUImageEmbossFilter* embossFilter = [[GPUImageEmbossFilter alloc] init];
    NSNumber* value1 = [self.paramDict objectForKey:@"intensity"];
    embossFilter.intensity = value1 ? 4 * value1.floatValue/10.0 : 1;
    self.filter = embossFilter;
    [imageSource addTarget:self.filter];
    [self.filter useNextFrameForImageCapture];
    [imageSource processImage];
    UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
    self.showPhoto.image = editImage;
    self.currentPicture = imageSource;
}

-(void)editPhotoWithSketch
{
    if(self.filter && [self.filter isKindOfClass:[GPUImageSketchFilter class]])
    {
        NSNumber* value = [self.paramDict objectForKey:@"edgeStrength"];
        [(GPUImageSketchFilter*)self.filter setEdgeStrength:value ? value.floatValue/10.0 : 1];
        [self.filter useNextFrameForImageCapture];
        [self.currentPicture processImage];
        UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
        self.showPhoto.image = editImage;
        return;
    }
    
    GPUImagePicture* imageSource = [[GPUImagePicture alloc] initWithImage:self.originImage];
    GPUImageSketchFilter* sketchFilter = [[GPUImageSketchFilter alloc] init];
    NSNumber* value1 = [self.paramDict objectForKey:@"edgeStrength"];
    sketchFilter.edgeStrength = value1 ? value1.floatValue/10.0 : 1;
    self.filter = sketchFilter;
    [imageSource addTarget:self.filter];
    [self.filter useNextFrameForImageCapture];
    [imageSource processImage];
    UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
    self.showPhoto.image = editImage;
    self.currentPicture = imageSource;
}

-(void)editPhotoWithOilPaint
{
    if(self.filter && [self.filter isKindOfClass:[GPUImageKuwaharaFilter class]])
    {
        NSNumber* value = [self.paramDict objectForKey:@"radius"];
        [(GPUImageKuwaharaFilter*)self.filter setRadius:value ? value.floatValue : 1];
        [self.filter useNextFrameForImageCapture];
        [self.currentPicture processImage];
        UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
        self.showPhoto.image = editImage;
        return;
    }
    
    GPUImagePicture* imageSource = [[GPUImagePicture alloc] initWithImage:self.originImage];
    GPUImageKuwaharaFilter* oilPaintFilter = [[GPUImageKuwaharaFilter alloc] init];
    NSNumber* value1 = [self.paramDict objectForKey:@"radius"];
    oilPaintFilter.radius = value1 ? value1.floatValue : 1;
    self.filter = oilPaintFilter;
    [imageSource addTarget:self.filter];
    [self.filter useNextFrameForImageCapture];
    [imageSource processImage];
    UIImage* editImage = [self.filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
    self.showPhoto.image = editImage;
    self.currentPicture = imageSource;
}

@end
