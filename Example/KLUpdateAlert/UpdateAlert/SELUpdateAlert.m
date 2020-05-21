//
//  SELUpdateAlert.m
//  SelUpdateAlert
//
//  Created by zhuku on 2018/2/7.
//  Copyright © 2018年 selwyn. All rights reserved.
//

#import "SELUpdateAlert.h"
#import "SELUpdateAlertConst.h"

#define DEFAULT_MAX_HEIGHT SCREEN_HEIGHT / 3 * 2

@interface SELUpdateAlert()

/** 版本号 */
@property (nonatomic, copy) NSString *version;
/** 版本更新内容 */
@property (nonatomic, copy) NSString *desc;
/** 跳转链接 */
@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) UIView *alphaView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *cancleBtn;

@end

@implementation SELUpdateAlert

/**
 添加版本更新提示

 @param version 版本号
 @param description 版本更新内容（字符串）
 
description 格式如 @"1.xxxxxx\n2.xxxxxx"
 */
+ (void)showUpdateAlertWithVersion:(NSString *)version description:(id)description toURL:(NSString *)url required:(BOOL)required {
    SELUpdateAlert *updateAlert = nil;
    if ([description isKindOfClass:NSArray.class]) {
        NSArray *descriptions = description;
        if (!descriptions || descriptions.count == 0) {
            return;
        }
        
        // 数组转换字符串，动态添加换行符\n
        NSString *descriptionstring = @"";
        for (NSInteger i = 0;  i < descriptions.count; ++i) {
            id desc = descriptions[i];
            if (![desc isKindOfClass:[NSString class]]) {
                return;
            }
            descriptionstring = [descriptionstring stringByAppendingString:desc];
            if (i != descriptions.count-1) {
                descriptionstring = [descriptionstring stringByAppendingString:@"\n"];
            }
        }
        updateAlert = [[SELUpdateAlert alloc] initVersion:version description:descriptionstring];
    } else {
        updateAlert = [[SELUpdateAlert alloc] initVersion:version description:description];
    }
    
    updateAlert.cancleBtn.hidden = required;
    updateAlert.url = url;
    [[UIApplication sharedApplication].delegate.window addSubview:updateAlert];
}

- (instancetype)initVersion:(NSString *)version description:(NSString *)description {
    self = [super init];
    if (self) {
        self.version = version;
        self.desc = description;
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.frame = [UIScreen mainScreen].bounds;
    
    //获取更新内容高度
    CGFloat descHeight = [self sizeofString:self.desc font:[UIFont systemFontOfSize:SELDescriptionFont] maxSize:CGSizeMake(self.frame.size.width - Ratio(80) - Ratio(56), 1000)].height;
    
    //bgView实际高度
    CGFloat realHeight = descHeight + Ratio(314);
    
    //bgView最大高度
    CGFloat maxHeight = DEFAULT_MAX_HEIGHT;
    //更新内容可否滑动显示
    BOOL scrollEnabled = NO;
    
    //重置bgView最大高度 设置更新内容可否滑动显示
    if (realHeight > DEFAULT_MAX_HEIGHT) {
        scrollEnabled = YES;
        descHeight = DEFAULT_MAX_HEIGHT - Ratio(314);
    } else {
        maxHeight = realHeight;
    }
    
    self.alphaView = [[UIView alloc]init];
    self.alphaView.center = self.center;
    self.alphaView.bounds = self.bounds;
    self.alphaView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3/1.0];
    [self addSubview:self.alphaView];
    
    //backgroundView
    UIView *bgView = [[UIView alloc]init];
    bgView.center = self.center;
    bgView.bounds = CGRectMake(0, 0, self.frame.size.width - Ratio(40), maxHeight+Ratio(18));
    [self addSubview:bgView];
    self.contentView = bgView;
    
    //添加更新提示
    UIView *updateView = [[UIView alloc]initWithFrame:CGRectMake(Ratio(20), Ratio(18), bgView.frame.size.width - Ratio(40), maxHeight)];
    updateView.backgroundColor = [UIColor whiteColor];
    updateView.layer.masksToBounds = YES;
    updateView.layer.cornerRadius = 4.0f;
    [bgView addSubview:updateView];
    
    // 20+166+10+28+10+descHeight+20+40+20 = 314+descHeight 内部元素高度计算bgView高度
    UIImageView *updateIcon = [[UIImageView alloc]initWithFrame:CGRectMake((updateView.frame.size.width - Ratio(178))/2, Ratio(20), Ratio(178), Ratio(166))];
    updateIcon.image = [UIImage imageNamed:@"VersionUpdate_Icon"];
    [updateView addSubview:updateIcon];
    
    //版本号
    UILabel *versionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, Ratio(10) + CGRectGetMaxY(updateIcon.frame), updateView.frame.size.width, Ratio(28))];
    versionLabel.font = [UIFont boldSystemFontOfSize:18];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.text = [NSString stringWithFormat:@"发现新版本 V%@",self.version];
    [updateView addSubview:versionLabel];
    
    //更新内容
    UITextView *descTextView = [[UITextView alloc]initWithFrame:CGRectMake(Ratio(28), Ratio(10) + CGRectGetMaxY(versionLabel.frame), updateView.frame.size.width - Ratio(56), descHeight)];
    descTextView.textContainer.lineFragmentPadding = 0;
    descTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = SELLineSpace;
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:SELDescriptionFont],
                                  NSParagraphStyleAttributeName:paragraphStyle };
    descTextView.attributedText = [[NSAttributedString alloc] initWithString:self.desc attributes:attributes];
    
    descTextView.editable = NO;
    descTextView.selectable = NO;
    descTextView.scrollEnabled = scrollEnabled;
    descTextView.showsVerticalScrollIndicator = scrollEnabled;
    descTextView.showsHorizontalScrollIndicator = NO;
    [updateView addSubview:descTextView];
    
    if (scrollEnabled) {
        //若显示滑动条，提示可以有滑动条
        [descTextView flashScrollIndicators];
    }
    
    //更新按钮
    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    updateButton.backgroundColor = SELColor(34, 153, 238);
    updateButton.frame = CGRectMake(Ratio(25), CGRectGetMaxY(descTextView.frame) + Ratio(20), updateView.frame.size.width - Ratio(50), Ratio(40));
    updateButton.clipsToBounds = YES;
    updateButton.layer.cornerRadius = 2.0f;
    [updateButton addTarget:self action:@selector(updateVersion) forControlEvents:UIControlEventTouchUpInside];
    [updateButton setTitle:@"立即更新" forState:UIControlStateNormal];
    [updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [updateView addSubview:updateButton];
    
    //取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.center = CGPointMake(CGRectGetMaxX(updateView.frame), CGRectGetMinY(updateView.frame));
    cancelButton.bounds = CGRectMake(0, 0, Ratio(36), Ratio(36));
    [cancelButton setImage:[[UIImage imageNamed:@"VersionUpdate_Cancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:cancelButton];
    self.cancleBtn = cancelButton;
    
    //显示更新
    [self showWithAlert:bgView];
}

/** 更新按钮点击事件 跳转AppStore更新 */
- (void)updateVersion {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
}

/** 取消按钮点击事件 */
- (void)cancelAction {
    [self dismissAlert];
}

/**
 添加Alert入场动画
 @param alert 添加动画的View
 */
- (void)showWithAlert:(UIView*)alert {
    self.alphaView.alpha = 0;
    self.contentView.alpha = 1;
    self.contentView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView animateWithDuration:SELAnimationTimeInterval animations:^{
        self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        self.alphaView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}


/** 添加Alert出场动画 */
- (void)dismissAlert {
    [UIView animateWithDuration:SELAnimationTimeInterval animations:^{
        self.contentView.transform = (CGAffineTransformMakeScale(0.8, 0.8));
        self.contentView.alpha = 0;
        self.alphaView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/**
 计算字符串高度
 @param string 字符串
 @param font 字体大小
 @param maxSize 最大Size
 @return 计算得到的Size
 */
- (CGSize)sizeofString:(NSString *)string font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = SELLineSpace;
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:SELDescriptionFont],
                                  NSParagraphStyleAttributeName:paragraphStyle };
    return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
}




@end
