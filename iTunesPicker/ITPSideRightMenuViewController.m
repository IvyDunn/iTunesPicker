//
//  ITPLeftMenuViewController.m
//  iTunesPicker
//
//  Created by Denis Berton on 23/04/14.
//  Copyright (c) 2014 appcorner.it. All rights reserved.
//

#import "ITPSideRightMenuViewController.h"
//#import "JASidePanelController.h"
//#import "UIViewController+JASidePanel.h"
#import "ITPSliderCell.h"
#import "ITPMorphingTableViewCell.h"
#import "ITPGraphic.h"

static NSString *CellIdentifierSlider = @"ITPSliderCell";
static NSString *CellIdentifierMenu = @"ITPMorphingTableViewCell";

@interface ITPSideRightMenuViewController ()

@end

@implementation ITPSideRightMenuViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifierSlider bundle:nil] forCellReuseIdentifier:CellIdentifierSlider];
    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifierMenu bundle:nil] forCellReuseIdentifier:CellIdentifierMenu];
    self.tableView.showsVerticalScrollIndicator = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingChange:) name:NOTIFICATION_LOADING_CHANGE object:nil];    
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadingChange:(NSNotification*) notification
{
    _pickerLoading = [notification.userInfo[ @"loading"]boolValue];
    [self.tableView reloadData];
}

-(NSArray*)getAvailableTypes
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults arrayForKey:DEFAULT_ACK_TYPES_KEY];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    switch (section) {
        case 0:
        {
            NSInteger count = [self getAvailableTypes].count;
            if([[self getAvailableTypes] containsObject:@(kITunesEntityTypeSoftware)])
            {
                count += 2; //add iPad and Mac apps
            }
            return count;
        }
        default:
            return 3;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [NSLocalizedString(@"menu.section.types", nil) uppercaseString];
        default:
            return [NSLocalizedString(@"menu.section.settings", nil) uppercaseString];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.font = [UIFont systemFontOfSize:20];
        tableViewHeaderFooterView.textLabel.textAlignment = NSTextAlignmentCenter;
        tableViewHeaderFooterView.backgroundView.backgroundColor = [UIColor clearColor]; //[[ITPGraphic sharedInstance] commonColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(indexPath.section == 1 && indexPath.row == 2)
    {
//        NSString *CellIdentifier = @"SliderCell";
        cell = (ITPSliderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierSlider];
        if (!cell)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifierSlider owner:self options:nil]objectAtIndex:0];
        }
    }
    else
    {
//        NSString *CellIdentifier = @"SideMenuItemCell";
        cell = (ITPMorphingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierMenu];
        if (!cell)
        {
            cell = [[ITPMorphingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierMenu];
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    if([cell isKindOfClass:[ITPMorphingTableViewCell class]])
    {
        ((ITPMorphingTableViewCell*)cell).morphLabel.textAlignment = NSTextAlignmentRight;
        ((ITPMorphingTableViewCell*)cell).typeView.backgroundColor = [UIColor clearColor];
        ((ITPMorphingTableViewCell*)cell).morphLabel.textColor = [UIColor whiteColor];
    }
    cell.imageView.image = nil;
    NSString* textForCell = @"";
    
    switch (indexPath.section) {
        case 0:
        {
            NSInteger index = indexPath.row;
            tITunesMediaEntityType selectedMediaType = kITunesMediaEntityTypeDefaultForEntity;
            
            //add iPad and Mac apps
            if([[self getAvailableTypes] containsObject:@(kITunesEntityTypeSoftware)])
            {
                index = [[self getAvailableTypes] indexOfObject:@(kITunesEntityTypeSoftware)];
                if(indexPath.row >= index && indexPath.row <= index+2)
                {
                    NSInteger mediaTypeIndex = indexPath.row - index;
                    switch (mediaTypeIndex) {
                        case 0:
                            selectedMediaType = kITunesMediaEntityTypeSoftware;
                            break;
                        case 1:
                            selectedMediaType = kITunesMediaEntityTypeSoftwareiPad;
                            break;
                        case 2:
                            selectedMediaType = kITunesMediaEntityTypeSoftwareMac;
                            break;
                    }
                }
                else if(indexPath.row > index+2)
                {
                    index = indexPath.row - 2;
                }
                else
                {
                    index = indexPath.row;
                }
            }
            
            NSString* key = [NSString stringWithFormat:@"type_%d_%d",[[self getAvailableTypes][index] intValue],selectedMediaType];
            textForCell = NSLocalizedString(key, nil);
            ((ITPMorphingTableViewCell*)cell).typeView.backgroundColor = [[ITPGraphic sharedInstance] commonColorForEntity:[[self getAvailableTypes][index]intValue]];
            break;
        }
        case 1:
            switch (indexPath.row) {
                case 0:
                    if(_pickerLoading)
                    {
                        ((ITPMorphingTableViewCell*)cell).morphLabel.textColor = [UIColor grayColor];
                    }
                    textForCell = NSLocalizedString(@"menu.selectcountries", nil);
                    break;
                case 1:
                {
                    if(_pickerLoading)
                    {
                        ((ITPMorphingTableViewCell*)cell).morphLabel.textColor = [UIColor grayColor];
                    }
                    textForCell = NSLocalizedString(@"menu.changeusercountry", nil);
                    ((ITPMorphingTableViewCell*)cell).countryImage.image = [UIImage imageNamed:[self.delegate getUserCountry]];
                    CAShapeLayer *circle = [CAShapeLayer layer];
                    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(4, 4, 28,28) cornerRadius:14.0]; //image 36*36
                    circle.path = circularPath.CGPath;
                    ((ITPMorphingTableViewCell*)cell).countryImage.layer.mask=circle;
                    break;
                }
                case 2:
                    break;
            }
            break;
    }
    
    if([cell isKindOfClass:[ITPMorphingTableViewCell class]])
    {
        ((ITPMorphingTableViewCell*)cell).morphLabel.text = textForCell;
    }
    
//    else
//    {
//        ((ITPSliderCell*)cell).labelResults.textColor = [UIColor whiteColor];
//        ((ITPSliderCell*)cell).labelResults.text = textForCell;
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    tITunesEntityType selectedType;
    tITunesMediaEntityType selectedMediaType = kITunesMediaEntityTypeDefaultForEntity;
    
    switch (indexPath.section) {
        case 0:
        {
            NSInteger index = indexPath.row;
            
            //add iPad and Mac apps
            if([[self getAvailableTypes] containsObject:@(kITunesEntityTypeSoftware)])
            {
                index = [[self getAvailableTypes] indexOfObject:@(kITunesEntityTypeSoftware)];
                if(indexPath.row >= index && indexPath.row <= index+2)
                {
                    NSInteger mediaTypeIndex = indexPath.row - index;
                    switch (mediaTypeIndex) {
                        case 0:
                            selectedMediaType = kITunesMediaEntityTypeSoftware;
                            break;
                        case 1:
                            selectedMediaType = kITunesMediaEntityTypeSoftwareiPad;
                            break;
                        case 2:
                            selectedMediaType = kITunesMediaEntityTypeSoftwareMac;
                            break;
                    }
                }
                else if(indexPath.row > index+2)
                {
                    index = indexPath.row - 2;
                }
                else
                {
                    index = indexPath.row;
                }
            }
            
            selectedType = [[self getAvailableTypes][index] intValue];
            break;
        }
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self.delegate openCountriesPicker];
                    break;
                case 1:
                    [self.delegate openUserCountrySetting];
                    break;
                case 2:
                    break;
            }
            return;
            break;
    }

    [self.delegate iTunesEntityTypeDidSelected:selectedType withMediaType:selectedMediaType];
}

//Eliminate Extra separators below UITableView
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

@end
