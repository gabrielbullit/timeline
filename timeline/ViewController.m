//
//  ViewController.m
//  timeline
//
//  Created by Gabriel on 03/05/16.
//  Copyright © 2016 PigTaz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _name=@"New";
    [self addTimeline];
    [self addMainImage];
    
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - image
-(void) addMainImage
{
    _currentPhoto=0;
    float size=WIN_WIDTH-50;
    
    self.ivMain =[[UIImageView alloc] initWithFrame:CGRectMake(25,50,size,size)];
    self.ivMain.image=[UIImage imageNamed:@"camera-icon.jpg"];
    [self.ivMain setContentMode:UIViewContentModeScaleAspectFit];
    
    UIButton *btChangePhoto = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btChangePhoto.frame = CGRectMake(25,50,BUTTON_SIZE/2,BUTTON_SIZE/2);
    UIImage *btnImage = [UIImage imageNamed:@"camera-icon.jpg"];
    [btChangePhoto setBackgroundImage:btnImage forState:UIControlStateNormal];
    [btChangePhoto addTarget:self action:@selector(openOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.ivMain];
    [self.view addSubview:btChangePhoto];

}
-(void) addTimeline
{
    NSMutableArray *savedImages = [[NSUserDefaults standardUserDefaults] objectForKey:_name];
    if (savedImages ==nil) {
        self.photos = [[NSMutableArray alloc] init];
        [self addButtonPhoto:nil position:0];
    }
    else {
        for (int i=0;i<4; i++) {
            if ([savedImages count] <i)
                break;
            [self addButtonPhoto:savedImages[i] position:i];
        }
    }
}

#pragma mark - buttons
-(void) addButtonPhoto:(UIImage *)btnImage position:(int)pos
{
    UIButton *btPhoto = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btPhoto.frame = CGRectMake(25+10*pos+BUTTON_SIZE*pos, WIN_HEIGHT - BUTTON_SIZE - 40, BUTTON_SIZE, BUTTON_SIZE);
    if (btnImage==nil) {
        UIImage *btnImage = [UIImage imageNamed:@"camera-icon.jpg"];
        [btPhoto setBackgroundImage:btnImage forState:UIControlStateNormal];
        [btPhoto addTarget:self action:@selector(newPhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [btPhoto setBackgroundImage:btnImage forState:UIControlStateNormal];
        [btPhoto addTarget:self action:@selector(changePhoto:) forControlEvents:UIControlEventTouchUpInside];
        if ([self.photos count] > pos) {
            [self.photos replaceObjectAtIndex:pos withObject:btPhoto];
        }
        else {
            //[self.photos insertObject:btPhoto atIndex:pos];
            [self.photos addObject:btPhoto];
        }
    }
    [self.view addSubview:btPhoto];

}
-(void) addButtonNewPhoto
{
    self.btNewPhoto = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.btNewPhoto.frame = CGRectMake(25, WIN_HEIGHT - BUTTON_SIZE - 40, BUTTON_SIZE, BUTTON_SIZE);
    UIImage *btnImage = [UIImage imageNamed:@"camera-icon.jpg"];
    [self.btNewPhoto setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.btNewPhoto addTarget:self action:@selector(newPhoto:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.btNewPhoto];
    
}

-(void) changePhoto:(UIButton*)sender
{
    self.ivMain.image = sender.currentBackgroundImage;
    [self.ivMain setContentMode:UIViewContentModeScaleAspectFit];
    int pos = (int)[self.photos indexOfObject:sender];
    _currentPhoto=pos;

}

-(void) newPhoto:(UIButton*)sender
{
    _currentPhoto=-1;
    [self openOptions:sender];
}
-(void) openOptions:(UIButton*)sender
{
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"Add or change a photo!"
                                 message:@"Select your origin:"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* optCamera = [UIAlertAction
                         actionWithTitle:@"Take Photo"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self selectPhoto:FROM_CAMERA];
                             [view dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* optLibrary = [UIAlertAction
                             actionWithTitle:@"Photo Library"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self selectPhoto:FROM_LIBRARY];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    UIAlertAction* optCancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:nil ];
    
    [view addAction:optCamera];
    [view addAction:optLibrary];
    [view addAction:optCancel];
    [self presentViewController:view animated:YES completion:nil];
}


#pragma mark - Open camera/Album
- (void)selectPhoto:(int)type {

    if (type == FROM_CAMERA && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:@"Device has no camera"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else {
        self.picker.allowsEditing=YES;

        switch (type) {
            case FROM_LIBRARY:
                self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case FROM_CAMERA:
            default:
                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                self.ivWatermark = [[UIImageView alloc] initWithImage:self.ivMain.image];
                self.ivWatermark.contentMode = UIViewContentModeScaleAspectFit;
                self.ivWatermark.frame = self.view.frame;
                self.ivWatermark.frame = CGRectMake(0, -65, self.view.frame.size.width, self.view.frame.size.height); //65 = iphone5S
                //self.ivWatermark.frame = CGRectMake(0, -75, self.view.frame.size.width, self.view.frame.size.height); //75 = iphone6
                
                self.ivWatermark.alpha = WATERMARK_ALPHA;

                
                self.picker.cameraOverlayView = self.ivWatermark;
        }
        
        [self presentViewController:self.picker animated:YES completion:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.ivMain.image = chosenImage;
    [self.ivMain setContentMode:UIViewContentModeScaleAspectFit];

    if (_currentPhoto<0)
        _currentPhoto=(int)[self.photos count]+1;
    if (_currentPhoto>3) _currentPhoto=3;
    [self addButtonPhoto:chosenImage position:_currentPhoto];

    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //TODO: Saving...
    //[[NSUserDefaults standardUserDefaults] setObject:self.photos forKey:_name];
}

#pragma mark - handles
-(void)handleNotification:(NSNotification *)message {
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidCaptureItem"]) {
        // Remove overlay, so that it is not available on the preview view;
        self.picker.cameraOverlayView = nil;
    }
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidRejectItem"]) {
        // Retake button pressed on preview. Add overlay, so that is available on the camera again
        self.picker.cameraOverlayView = self.ivWatermark;
    }
}
@end
