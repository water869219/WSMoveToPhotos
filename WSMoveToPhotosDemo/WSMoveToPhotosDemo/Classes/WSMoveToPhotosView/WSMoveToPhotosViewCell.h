//
//  ImageCollectionViewCell.h
//  ImageCell
//
//  Created by water on 15/9/30.
//  Copyright © 2015年 water. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSMoveToPhotosViewCell : UICollectionViewCell

- (void)configureCell:(id)image;
- (void)configureCell:(id)image Success:(void (^) (UIImage *))success;


@end
