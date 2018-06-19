//
//  GridViewCell.h
//  SamplePhotosDemo
//
//  Created by iTruda on 2018/6/18.
//  Copyright © 2018年 iTruda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *representedAssetIdentifier;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *livePhotoBadgeImage;

@end
