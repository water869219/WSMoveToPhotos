//
//  ViewController.m
//  WSMoveToPhotos
//
//  Created by water on 2017/6/6.
//  Copyright © 2017年 AnJuBao. All rights reserved.
//

#import "ViewController.h"
#import "WSMoveToPhotosView.h"

@interface ViewController ()
/// 上传图片控制器
@property (nonatomic, strong) WSMoveToPhotosView  *moveToPhotosView;
@property (nonatomic, strong) UIButton *btn;
@end

@implementation ViewController

#pragma mark - viewController life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交 " style:UIBarButtonItemStylePlain target:self action:@selector(sumbitDidClick)];
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - custom method
- (void)prepareUI {
    self.moveToPhotosView = [[WSMoveToPhotosView alloc] init];
    self.moveToPhotosView.persentViewController = self;
    
    [self.view addSubview:self.moveToPhotosView];
    
    _moveToPhotosView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_moveToPhotosView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:100.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_moveToPhotosView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_moveToPhotosView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_moveToPhotosView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.btn.highlighted = !self.btn.highlighted;
}

#pragma mark - <提交>
- (void)sumbitDidClick {
    
    NSArray *attachList = [self.moveToPhotosView attachList];
    /*
     图片以base64存储在attachList中的fileDataStr 详见AJBImagePickerTableViewCell.m
     */
    if(attachList != nil) {
        NSLog(@"%@", attachList);
    }
    
}
#pragma mark - delegate & dataSource



#pragma mark - setting & getting





@end
