//
//  SASGalleryViewController.m
//  Save a Selfie
//
//  Created by Stephen Fox on 11/07/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import "SASGalleryCollectionViewController.h"
#import "SASGalleryCell.h"
#import "SASMapAnnotationRetriever.h"
#import "SASImageViewController.h"
#import "SASUtilities.h"
#import <SDWebImageDownloader.h>

#define CELL_LIMIT 10

@interface SASGalleryCollectionViewController() <SASMapAnnotationRetrieverDelegate, SASGalleryCellDelegate>

@property(strong, nonatomic) SASMapAnnotationRetriever *sasAnnotationRetriever;
@property(strong, nonatomic) NSMutableArray *dataForCells;
@property(strong, atomic) __block NSMutableArray *cellImages;
@property (strong, nonatomic) SDWebImageDownloader *imageDownloader;

@property (assign, nonatomic) BOOL readyToLoad;

@end


@implementation SASGalleryCollectionViewController

@synthesize sasAnnotationRetriever;
@synthesize dataForCells;
@synthesize cellImages;
@synthesize imageDownloader;
@synthesize readyToLoad;


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = @"Gallery";
    
    self.collectionView.backgroundColor = [UIColor whiteColor];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.cellImages = [[NSMutableArray alloc] init];
    
    
    if (self.sasAnnotationRetriever == nil) {
        self.sasAnnotationRetriever = [[SASMapAnnotationRetriever alloc] init];
        self.sasAnnotationRetriever.delegate = self;
    }
    
    [self.sasAnnotationRetriever fetchSASAnnotationsFromServer];
    
}


- (void)sasAnnotationsRetrieved:(NSMutableArray *)devices {
    self.dataForCells = devices;

    
    for (int i; i < CELL_LIMIT; i++) {
        
        
        // Get the image for the cell.
        SASDevice *deviceAtIndex = [self.dataForCells objectAtIndex:i];
        
        NSString *imageURL = deviceAtIndex.imageURL;
        
        NSURL *url = [NSURL URLWithString:imageURL];
        
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        }
                                                          completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
         {
             if (image && finished) {
                 [self.cellImages addObject:image];
                 NSLog(@"%@", image);
                 NSLog(@"Cell image count: %lu", (unsigned long)self.cellImages.count);
                 
                 if (self.cellImages.count == CELL_LIMIT ) {
                     self.readyToLoad = YES;
                     printf("READY TO LOAD ******");
                     [self.collectionView reloadData];
                 }
             }
         }];
        
       
    }
    
}



#pragma mark CollectionView Data source
- (SASGalleryCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    SASGalleryCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    
    if (self.readyToLoad) {
        if (self.cellImages[indexPath.row] != nil) {
            cell.imageView.image = self.cellImages[indexPath.row];
        }
    }

    return cell;
    
}


- (void) setCells {
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return CELL_LIMIT;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}


#pragma SASGalleryCellDelegate
- (void)sasGalleryCellDelegate:(SASGalleryCell *)cell wasTappedWithObject:(SASAnnotation *)object {

    SASImageViewController *sasImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SASImageViewController"];
    sasImageViewController.annotation = object;
    [self.navigationController pushViewController:sasImageViewController animated:YES];
}


- (void) calculatePriorityForCell:(SASGalleryCell*) cell withDevice:(SASDevice *) device {
    
}




@end