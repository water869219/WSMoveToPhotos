//
//  ImagePickerTableViewCell.m
//  ImageCell
//
//  Created by water on 15/9/30.
//  Copyright © 2015年 water. All rights reserved.
//

#import "WSMoveToPhotosView.h"
#import "WSMoveToPhotosViewCell.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSData+YYAdd.h"
#import <MWPhotoBrowser/MWPhotoBrowserPrivate.h>
#import "LXReorderableCollectionViewFlowLayout.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_RUNS_IOS8_OR_LATER SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")

@interface WSMoveToPhotosView() <UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MWPhotoBrowserDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UICollectionView *imageCollectionView;
@property (nonatomic, strong) NSMutableArray   *imageList;
@property (nonatomic, strong) NSMutableArray   *photos;
@property (nonatomic, strong) NSMutableArray   *assets;
@property (nonatomic, strong) ALAssetsLibrary  *ALAssetsLibrary;
@property (nonatomic, strong) NSMutableArray   *thumbs;
@property (nonatomic, strong) NSMutableArray   *selections;
@property (nonatomic, strong) NSMutableArray   *indexPhotos;
@property (nonatomic, assign) BOOL             selectedImage;
@property (nonatomic, assign) BOOL             actionSignPhotoFlag;
@property (nonatomic, strong) LXReorderableCollectionViewFlowLayout *flowLayout;
@end

@implementation WSMoveToPhotosView

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configure];
    }
    return self;
}


- (void)configure {
    [self addSubview:self.imageCollectionView];
    self.imageCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageCollectionView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageCollectionView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0
                                                                  constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageCollectionView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageCollectionView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
    
    
    [_imageCollectionView registerClass:[WSMoveToPhotosViewCell class] forCellWithReuseIdentifier:@"imageCell"];
    self.disabled = NO;
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"AddGroupMemberBtnHL.png" ofType:nil];
    _imageList = [NSMutableArray arrayWithObject: [UIImage imageWithContentsOfFile:imagePath]];
    [self loadAssets];
    [self setupFlowLayout];
}


- (void)setupFlowLayout
{
    _flowLayout.minimumInteritemSpacing = 10.0f;
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width - 20;
    NSInteger row = 4;
    CGFloat itemWidth = (screenWidth - (row + 1) * _flowLayout.minimumInteritemSpacing) / row ;
     _flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
}



-(void)setDisabled:(BOOL)disabled{
    _disabled = disabled;
    if (self.disabled) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"AddGroupMemberBtnHL.png" ofType:nil];
        _imageList = [NSMutableArray arrayWithObject: [UIImage imageWithContentsOfFile:imagePath]];
    }
    [_imageCollectionView reloadData];
}


-(NSMutableArray *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

#pragma mark - <LXReorderableCollectionViewFlowLayout>

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    id object = [self.imageList objectAtIndex:fromIndexPath.item];
    [self.imageList removeObjectAtIndex:fromIndexPath.item];
    [self.imageList insertObject:object atIndex:toIndexPath.item];
    
    id index = [self.indexPhotos objectAtIndex:fromIndexPath.item];
    [self.indexPhotos removeObjectAtIndex:fromIndexPath.item];
    [self.indexPhotos insertObject:index atIndex:toIndexPath.item];
    
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return (self.imageList.count - 1) != indexPath.item;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {

    NSUInteger lastItem = self.imageList.count -1;
    BOOL isLast = (fromIndexPath.item == lastItem) || (toIndexPath.item == lastItem);
    
    return !isLast;
}

#pragma mark ------------- CollectionView Data Source -------------

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.imageList.count > self.imageMaxNum ? self.imageMaxNum: self.imageList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WSMoveToPhotosViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    [cell configureCell:self.imageList[indexPath.row] Success:^(UIImage *image) {
        [self.imageList replaceObjectAtIndex:indexPath.row withObject:image];
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row == [self.imageList count] - 1) && !self.disabled) {
        
        if (self.imageMaxNum < [[collectionView visibleCells] count]) {
            NSString *msg = [NSString stringWithFormat:@"最多只能添加%@张图片",@(self.imageMaxNum)];
            [[[UIAlertView alloc]initWithTitle:@"提示"
                                       message:msg
                                      delegate:nil
                             cancelButtonTitle:@"确定"
                             otherButtonTitles:nil,
              nil] show];
            return;
        }
        
        [self showPhotoSheet];
    } else {
        
        [self previewPhotosAtIndexPath:indexPath];
    }
}

- (void)previewPhotosAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *thumbs = [NSMutableArray array];
    NSMutableArray *photos = [NSMutableArray array];
    
    [self.imageList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != ([self.imageList count] - (self.disabled?0:1))) {
            MWPhoto *photo = [self configurePhoto:obj];
            
            if (photo) {
                [photos addObject:photo];
                [thumbs addObject:photo];
            }
        }
    }];
    
    self.thumbs = thumbs;
    self.photos = photos;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:indexPath.row];
    browser.zoomPhotosToFill = YES;
    browser.displayActionButton = !self.disabled;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.persentViewController presentViewController:nc animated:YES completion:^{
        self.actionSignPhotoFlag = YES;
    }];
}

- (MWPhoto *)configurePhoto:(id)image {
    if ([image isKindOfClass:[UIImage class]]) {
        MWPhoto *photo = [MWPhoto photoWithImage:image];
        return photo;
    }
    
    return nil;

}

- (void)showPhotoSheet {
    
    if(SYSTEM_RUNS_IOS8_OR_LATER){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
      
        
        UIAlertAction *pickerImageAction = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showPhotoLibrary];
            
        }];
        
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openCamera];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:takePhotoAction];
        [alertController addAction:pickerImageAction];
        [alertController addAction:cancelAction];
        
        if (self.persentViewController) {
            [self.persentViewController presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.persentViewController.title delegate:self
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"相机", @"从相册选择", nil];
        actionSheet.tag = self.tag;
        [actionSheet showInView:self.persentViewController.view];
       
    }
}

-(void)openCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.delegate = self;
        [self.persentViewController presentViewController:pickerController animated:YES completion:nil];
    } else {
        NSLog(@"模拟器不能打开照相机");
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        [self openCamera];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (buttonIndex) {
        case 0:
            [self openCamera];
          
            break;
            
        case 1:
             [self showPhotoLibrary];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        [self.imageList insertObject:image atIndex:0];
        [self.imageCollectionView reloadData];
        // 将图片保存到相册
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        for (int i = 0; i < self.indexPhotos.count; i ++) {
            NSInteger indexPhoto = [self.indexPhotos[i] integerValue] + 1;
            [self.indexPhotos replaceObjectAtIndex:i withObject:@(indexPhoto)];
        }
        // 纪录索引
        [self.indexPhotos insertObject:@(0) atIndex:0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performLoadAssets];
        });
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.imageCollectionView reloadData];
    }];
    

}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;

}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;

}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    
    return [[_selections objectAtIndex:index] boolValue];

}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
   
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSInteger selectCount = 0;
    for (NSNumber *number in _selections) {
        if(number.boolValue) {
            selectCount ++;
        }
        if (selectCount > self.imageMaxNum ) {
            [_selections replaceObjectAtIndex:index withObject:@NO];
            MWGridViewController *gridController = nil;
            if([photoBrowser.childViewControllers.firstObject isKindOfClass:[MWGridViewController class]]) {
                // 多张图片时的选择控制器
                gridController = photoBrowser.childViewControllers.firstObject;
                [gridController.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            }
            if(gridController == nil) {
                // 单张图片选择的view
                for (UIView *view in photoBrowser.view.subviews) {
                    if([view isKindOfClass:[UIScrollView class]]) {
                        for (UIView *btnView in view.subviews) {
                            if([btnView isKindOfClass:[UIButton class]]) {
                                UIButton *btn = (UIButton *)btnView;
                                btn.selected = NO;
                                 break;
                            }
                        }
                    }
                }
            }
            NSString *msg = [NSString stringWithFormat:@"最多只能添加%@张图片",@(self.imageMaxNum)];
            [[[UIAlertView alloc]initWithTitle:@"提示"
                                       message:msg
                                      delegate:nil
                             cancelButtonTitle:@"确定"
                             otherButtonTitles:nil,
              nil] show];
            return;
        }
        
    }
    

}

- (void)photoBrowserDidSelectedPhotos:(NSArray *)photots {
  
    NSRange range = NSMakeRange(0, [photots count]);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];

    if(photots.count > 0 ) {
        [_imageList removeAllObjects];
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"AddGroupMemberBtnHL.png" ofType:nil];
        _imageList = [NSMutableArray arrayWithObject: [UIImage imageWithContentsOfFile:imagePath]];
        [self.indexPhotos removeAllObjects];
        // 纪录索引
        for (int i = 0; i < self.selections.count; i ++) {
            NSNumber *number = self.selections[i];
            if([number boolValue]) {
                [self.indexPhotos addObject:@(i)];
                continue;
            }
        }
        
        [self.imageList insertObjects:photots atIndexes:indexSet];
        
    }else if(photots.count == 0 && !self.actionSignPhotoFlag){
        [_imageList removeAllObjects];
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"AddGroupMemberBtnHL.png" ofType:nil];
        _imageList = [NSMutableArray arrayWithObject: [UIImage imageWithContentsOfFile:imagePath]];
        
        [self.indexPhotos removeAllObjects];
    }
    
    [self.imageCollectionView reloadData];
    [self.persentViewController dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
    
    if(index < self.indexPhotos.count) {
        [self.indexPhotos removeObjectAtIndex:index];
    }
    
    [self.imageList removeObjectAtIndex:index];
    [self.imageCollectionView reloadData];
    [self.photos removeObjectAtIndex:index];
    [photoBrowser reloadData];
    [self.imageCollectionView reloadData];
}

#pragma mark - Load Assets

- (void)loadAssets {
    if (NSClassFromString(@"PHAsset")) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        }
        
    } else {
      	 [self performLoadAssets];
    }

}


- (void)performLoadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    // Load
    if (NSClassFromString(@"PHAsset")) {
        // Photos library iOS >= 8
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *fetchResults = [PHAsset fetchAssetsWithOptions:options];
            [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_assets addObject:obj];
            }];
            if (fetchResults.count > 0) {
                //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        });
        
    } else {
        
        // Assets Library iOS < 8
        _ALAssetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // Run in the background as it takes a while to get all assets from the library
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
            NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
            
            // Process assets
            void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                    if ([assetType isEqualToString:ALAssetTypePhoto] || [assetType isEqualToString:ALAssetTypeVideo]) {
                        [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                        NSURL *url = result.defaultRepresentation.url;
                        [_ALAssetsLibrary assetForURL:url
                                          resultBlock:^(ALAsset *asset) {
                                              if (asset) {
                                                  @synchronized(_assets) {
                                                      [_assets addObject:asset];
                                                      if (_assets.count == 1) {
    
                                                      }
                                                  }
                                              }
                                          }
                                         failureBlock:^(NSError *error){
                                             NSLog(@"operation was not successfull!");
                                         }];
                        
                    }
                }
            };
            
            // Process groups
            void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group != nil) {
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                    [assetGroups addObject:group];
                }
            };
            
            // Process!
            [_ALAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:assetGroupEnumerator
                                          failureBlock:^(NSError *error) {
                                              NSLog(@"There is an error");
                                          }];
        });
        
    }
    
}

- (void)showPhotoLibrary {
    
    self.photos = [NSMutableArray array];
    self.thumbs = [NSMutableArray array];
    @synchronized(_assets) {
        NSMutableArray *copy = [_assets copy];
        if (NSClassFromString(@"PHAsset")) {
            // Photos library
            UIScreen *screen = [UIScreen mainScreen];
            CGFloat scale = screen.scale;
            // Sizing is very rough... more thought required in a real implementation
            CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
            CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
            CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
            for (PHAsset *asset in copy) {
                [self.photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
                [self.thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
            }
        } else {
            // Assets library
            for (ALAsset *asset in copy) {
                if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto) {
                    MWPhoto *photo = [MWPhoto photoWithURL:asset.defaultRepresentation.url];
                    [self.photos addObject:photo];
                    MWPhoto *thumb = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
                    [self.thumbs addObject:thumb];
                }
            }
        }
    }
    
    if (!self.photos.count) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"对不起，在你的相册找不到照片。"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"拍照", nil];
        [alertView show];
        return;
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = YES;
    browser.alwaysShowControls = YES;
    browser.enableGrid = YES;
    browser.startOnGrid = YES;
    browser.enableSwipeToDismiss = NO;
    browser.imageMaxNum = self.imageMaxNum;
    [browser setCurrentPhotoIndex:0];
    
    _selections = [NSMutableArray array];
    for (int i = 0; i < self.photos.count; i++) {
        [_selections addObject:[NSNumber numberWithBool:NO]];
    }
 
    for (NSNumber *number in self.indexPhotos) {
         [_selections replaceObjectAtIndex:[number integerValue] withObject:[NSNumber numberWithBool:YES]];
    }
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.persentViewController presentViewController:nc animated:YES completion:^{
        self.actionSignPhotoFlag = NO;
        
    }];


}

- (void)setContactGuid:(NSString *)contactGuid {
    NSArray *contactGuids = [contactGuid componentsSeparatedByString:@";"];
    NSRange range = NSMakeRange(0, [contactGuids count]);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.imageList insertObjects:contactGuids atIndexes:indexSet];
    [self.imageCollectionView reloadData];
}


/**
 @return 图片以base64存储在attachList中的fileDataStr
 */
- (NSArray *)attachList {
    
    NSMutableArray *attachList = [NSMutableArray array];
    NSInteger idx = 0;
    
    for (id obj in self.imageList) {
        
        if ((idx != [self.imageList count] - 1) && !self.disabled) {
            if ([obj isKindOfClass:[UIImage class]]) {
                UIImage *image = obj;
                NSData *photoData         = UIImageJPEGRepresentation(image, 0.1);
                NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:photoData.length countStyle:NSByteCountFormatterCountStyleBinary]);
                
                NSString *photo = [photoData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
                
                NSString *imageName       =  [NSString stringWithFormat:@"%@.jpg",[photo substringWithRange:NSMakeRange(1, 10)]];
                NSDictionary *pictureVo   = @{@"fileDataStr":photo,
                                              @"fileName":imageName,
                                              @"type":@"1"
                                              };
                
                [attachList addObject:pictureVo];
            } else {
                [attachList addObject:obj];
            }
        }
        
        idx++;
    }
    
    return attachList;
}

- (NSString *)AFBase64EncodedStringFromString:(NSString *)string {
    
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

#pragma mark - <setting & getting>
- (NSMutableArray *)indexPhotos {
    if(_indexPhotos) return _indexPhotos;
    _indexPhotos = [NSMutableArray array];
    return _indexPhotos;
}


- (UICollectionView *)imageCollectionView
{
    if(_imageCollectionView) return _imageCollectionView;
    _flowLayout = [[LXReorderableCollectionViewFlowLayout alloc] init];

    _imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    _imageCollectionView.backgroundColor = [UIColor whiteColor];
    _imageCollectionView.scrollEnabled = NO;
    _imageCollectionView.dataSource = self;
    _imageCollectionView.delegate = self;


    return _imageCollectionView;
}


- (NSInteger)imageMaxNum {
    if(_imageMaxNum > 0) return _imageMaxNum;
    _imageMaxNum = 5;
    return  _imageMaxNum;
}

@end
