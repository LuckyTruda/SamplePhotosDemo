//
//  AssetGridVC.h
//  SamplePhotosDemo
//
//  Created by iTruda on 2018/6/18.
//  Copyright © 2018年 iTruda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface AssetGridVC : UICollectionViewController

@property (nonatomic, strong) PHFetchResult<PHAsset *> *fetchResult;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end
