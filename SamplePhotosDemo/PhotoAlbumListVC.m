//
//  PhotoAlbumListVC.m
//  SamplePhotosDemo
//
//  Created by iTruda on 2018/6/18.
//  Copyright © 2018年 iTruda. All rights reserved.
//

#import "PhotoAlbumListVC.h"
#import <Photos/Photos.h>
#import "AssetGridVC.h"

typedef NS_ENUM(NSUInteger, RowsInSection) {
    allPhotos = 0,
    smartAlbums,
    userCollections,
};

static NSString * const CellID = @"CellID";

@interface PhotoAlbumListVC () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHFetchResult<PHAsset *> *allPhotos;
@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *smartAlbums;
@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *userCollections;
@property (nonatomic, strong) NSArray *sectionLocalizedTitles;

@end

@implementation PhotoAlbumListVC

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self initData];
}

- (void)initData
{
    [self fetchAssetCollection];
    
    _sectionLocalizedTitles = @[@"", @"Smart Albums", @"Albums"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)fetchAssetCollection
{
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    // 按创建时间升序
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    // 获取所有照片（按创建时间升序）
    _allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    // 获取所有智能相册
    _smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 获取所有用户创建相册
    _userCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    //_userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case allPhotos:
            return 1;
            break;
        case smartAlbums:
            return _smartAlbums.count;
            break;
        case userCollections:
            return _userCollections.count;
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case allPhotos:
        {
            cell.textLabel.text = @"All Photos";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%zd", _allPhotos.count];
            break;
        }
        case smartAlbums:
        {
            PHAssetCollection *collection = [_smartAlbums objectAtIndex:indexPath.row];
            cell.textLabel.text = collection.localizedTitle;
            break;
        }
        case userCollections:
        {
            PHAssetCollection *collection = [_userCollections objectAtIndex:indexPath.row];
            cell.textLabel.text = collection.localizedTitle;
            break;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sectionLocalizedTitles[section];
}

#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    AssetGridVC *vc = [[AssetGridVC alloc] initWithCollectionViewLayout:layout];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    vc.title = cell.textLabel.text;
    PHAssetCollection *collection = nil;
    if (indexPath.section == allPhotos) {
        vc.fetchResult = _allPhotos;
    }
    else if (indexPath.section == smartAlbums) {
        collection = [_smartAlbums objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == userCollections) {
        collection = [_userCollections objectAtIndex:indexPath.row];
    }
    vc.assetCollection = collection;
    vc.fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver -
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    //第一次安装，点击允许访问后刷新 tableView
    //必须在主线程
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self fetchAssetCollection];
        [self.tableView reloadData];
    });
    
    /*
    __weak typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        // Check each of the three top-level fetches for changes.
        PHFetchResultChangeDetails *changeDetails_allPhotos = [changeInstance changeDetailsForFetchResult:weakSelf.allPhotos];
        if (changeDetails_allPhotos) {
            // Update the cached fetch result.
            weakSelf.allPhotos = changeDetails_allPhotos.fetchResultAfterChanges;
            // (The table row for this one doesn't need updating, it always says "All Photos".)
        }
        [weakSelf fetchAssetCollection];
        // Update the cached fetch results, and reload the table sections to match.
        PHFetchResultChangeDetails *changeDetails_smartAlbums = [changeInstance changeDetailsForFetchResult:weakSelf.smartAlbums];
        if (changeDetails_smartAlbums) {
            weakSelf.smartAlbums = changeDetails_allPhotos.fetchResultAfterChanges;
            //[weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        PHFetchResultChangeDetails *changeDetails_userCollections = [changeInstance changeDetailsForFetchResult:weakSelf.userCollections];
        if (changeDetails_userCollections) {
            // Update the cached fetch result.
            weakSelf.userCollections = changeDetails_allPhotos.fetchResultAfterChanges;
            //[weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [weakSelf.tableView reloadData];
    });
    */
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
