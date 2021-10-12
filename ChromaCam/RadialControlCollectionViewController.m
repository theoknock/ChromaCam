//
//  RadialControlCollectionViewController.m
//  ChromaCam
//
//  Created by Xcode Developer on 10/10/21.
//

#import "RadialControlCollectionViewController.h"
#import "PropertyCollectionViewCell.h"
#import "RadialLayout.h"

@interface RadialControlCollectionViewController ()

@property (nonatomic, assign) NSInteger cellCount;
@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) RadialLayout *radialLayout;

@property (nonatomic, assign) BOOL firstTime;

@end

@implementation RadialControlCollectionViewController

@synthesize collectionView;

static NSString * const radialControlCollectionViewCellReuseID = @"RadialControlCollectionViewCellReuseID";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    
    _radialLayout = [[RadialLayout alloc] init];
    
    [self.collectionView setCollectionViewLayout:_radialLayout animated:YES];
    [self.collectionView setContentOffset:CGPointZero];
    
    // set background color
    [self.collectionView setBackgroundColor:[UIColor blackColor]];
    
    self.cellCount = 5;
    
    // register the cell class(s)
    [self.collectionView registerClass:[PropertyCollectionViewCell class] forCellWithReuseIdentifier:radialControlCollectionViewCellReuseID];
    
    _firstTime = YES;
    
    [self.collectionView.collectionViewLayout performSelector:@selector(invalidateLayout) withObject:nil afterDelay:0.4f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    

    [self.collectionView performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.cellCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PropertyCollectionViewCell * cell;
    [cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PropertyCollectionViewCellReuseID" forIndexPath:indexPath] setTag:indexPath.item];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;

    if (_selectedIndexPath &&
        _selectedIndexPath.row == indexPath.row &&
        _selectedIndexPath.section == indexPath.section)
    {
        size.height = size.width * 0.7f;
    }

    return size;
}

@end
