//
//  ImagePickerTableViewCell.h
//  ImageCell
//
//  Created by water on 15/9/30.
//  Copyright © 2015年 water. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface WSMoveToPhotosView : UIView

@property (nonatomic, weak) UIViewController *persentViewController;
@property (nonatomic, assign) NSInteger imageMaxNum;
@property (nonatomic, strong) NSArray   *attachList;
@property (nonatomic, assign) BOOL      disabled;
@property (nonatomic, strong) NSString  *contactGuid;

@end
