//
//  ITPSliderCell.h
//  iTunesPicker
//
//  Created by Denis Berton on 02/06/14.
//  Copyright (c) 2014 appcorner.it. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASValueTrackingSlider.h"
#import "TOMSMorphingLabel.h"

@interface ITPSliderCell : UITableViewCell <ASValueTrackingSliderDelegate>

@property (weak, nonatomic) IBOutlet TOMSMorphingLabel *labelResults;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *slider;

@end
