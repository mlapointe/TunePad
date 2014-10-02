//
//  RecordView.m
//  TunePad Pro
//
//  Created by Mike Lapointe on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordView.h"

@implementation RecordView

@synthesize recordButton = _recordButton;
@synthesize playButton = _playButton;
@synthesize recordLabel = _recordLabel;
@synthesize timer = _timer;
@synthesize progressView = _progressView;

- (id) initWithFrame:(CGRect)frame {

    
    if (self = [super initWithFrame:frame]) {
//        
//        //[[NSBundle mainBundle] loadNibNamed:@"RecordView" owner:self options:nil];
//        //[self addSubview:self]; //self.view?
//        

        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"RecordView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
//        
    }
    
    return self;
}

- (void) awakeFromNib {
    
    [super awakeFromNib];
    
    //[[NSBundle mainBundle] loadNibNamed:@"RecordView" owner:self options:nil];
    //[self addSubview:self];
    
    
}



@end
