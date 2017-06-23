//
//  ImageCollectionViewCell.m
//  ImageCell
//
//  Created by water on 15/9/30.
//  Copyright © 2015年 water. All rights reserved.
//

#import "WSMoveToPhotosViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>

typedef void(^SDWebImageCompletionBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL);

@interface WSMoveToPhotosViewCell()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WSMoveToPhotosViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self prepareUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.imageView];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
    
    
}

- (void)configureCell:(id)image {
    if ([image isKindOfClass:[UIImage class]]) {
        self.imageView.image = image;
    } else if ([image isKindOfClass:[NSString class]]) {
      
    }
}

- (void)configureCell:(id)image Success:(void (^) (UIImage *))success {
    if ([image isKindOfClass:[UIImage class]]) {
        self.imageView.image = image;
    } else if ([image isKindOfClass:[NSString class]]) {
        
    }
}

#pragma mark - <setting & getting>
- (UIImageView *)imageView
{
    if(_imageView) return _imageView;
    _imageView = [[UIImageView alloc] init];
    return _imageView;
}

@end
