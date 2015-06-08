//
//  SASImageView.m
//  Save a Selfie
//
//  Created by Stephen Fox on 06/06/2015.
//  Copyright (c) 2015 Stephen Fox. All rights reserved.
//

#import "SASImageView.h"
#include "SASImageInspectorView.h"


@interface SASImageView() {
    BOOL imageInspectorInViewHierarchy;
}

@property(strong, nonatomic) SASImageInspectorView *sasImageInspectorView;

@end


@implementation SASImageView

@synthesize sasImageInspectorView;


- (instancetype)initWithCoder:(NSCoder *)coder {
    
    if (self = [super initWithCoder:coder]) {
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}


- (void) handleTapGesture: (UIGestureRecognizer*) gesture {
    
    sasImageInspectorView = [[SASImageInspectorView alloc] initWithImage:self.image];
    
    [UIView animateWithDuration:3.0
                          delay:0.2
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self addSubview:self.sasImageInspectorView];
                     }
                     completion:nil];
}



@end