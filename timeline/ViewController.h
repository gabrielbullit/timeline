//
//  ViewController.h
//  timeline
//
//  Created by Gabriel on 03/05/16.
//  Copyright © 2016 PigTaz. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WIN_HEIGHT self.view.bounds.size.height
#define WIN_WIDTH  self.view.bounds.size.width
#define BUTTON_SIZE 60

#define WATERMARK_ALPHA 0.7

#define FROM_LIBRARY 1
#define FROM_CAMERA  2

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    int _currentPhoto;
    NSString *_name;
}
@property(nonatomic,retain) UIImageView *ivMain;
@property(nonatomic,retain) UIImageView *ivWatermark;
@property(nonatomic,retain) UIButton *btNewPhoto;
@property(nonatomic,retain) UITextField *txtName;
@property(nonatomic,retain) NSMutableArray *photos;
@property(nonatomic,retain) UIImagePickerController *picker;



@end


