//
//  ChangeProfileViewController.m
//  2x2
//
//  Created by aDb on 3/11/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "ChangeProfileViewController.h"
#import "DataDownloader.h"
#import "SGPopSelectView.h"
#import "Settings.h"
#import "DBManager.h"

#define currentMonth [currentMonthString integerValue]

@interface ChangeProfileViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    Settings *st;
    NSString *province;
    NSInteger buttonId;
    NSString *birthdate;
    NSString *day;
    NSString *month;
    NSString *year;
}

@property (nonatomic, strong) NSString *cityId;;

@property (nonatomic, strong) NSNumber *buttonId;

@property (nonatomic, strong) NSMutableArray *selections;

@property (nonatomic, strong) NSMutableDictionary *provinceData;

@property (nonatomic, strong) NSMutableDictionary *cityData;

@property (nonatomic, strong) NSMutableArray *cityArray;

@property (nonatomic, strong) SGPopSelectView *popView;

@property (weak, nonatomic) IBOutlet UITextField *textFieldEnterDate;

@property (weak, nonatomic) IBOutlet UIView *toolbarCancelDone;

@property (weak, nonatomic) IBOutlet UIPickerView *customPicker;

@property (strong, nonatomic) DataDownloader *getData;

#pragma mark - IBActions

- (IBAction)actionCancel:(id)sender;

- (IBAction)actionDone:(id)sender;

@end

@implementation ChangeProfileViewController
{
    NSMutableArray *yearArray;
    NSArray *monthArray;
    NSArray *DaysArray;
    
    
    NSString *currentMonthString;
    
    int selectedYearRow;
    int selectedMonthRow;
    int selectedDayRow;
    
    BOOL firstTimeLoad;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=@"اطلاعات شخصی";
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont fontWithName:@"B Yekan" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    
    RequestCompleteBlock callback3 = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            
            nameTextField.text = [data valueForKey:@"name"] == [NSNull null] ? @"" : [data valueForKey:@"name"];
            lastNameTextField.text = [data valueForKey:@"lastname"] == [NSNull null] ? @"" : [data valueForKey:@"lastname"];
            self.cityTextField.text = [data valueForKey:@"city"]==[NSNull null]?@"":[NSString stringWithFormat:@"%@",[data valueForKey:@"city"]];
            self.provinceTextField.text = [data valueForKey:@"provience"]==[NSNull null]?@"":[NSString stringWithFormat:@"%@",[data valueForKey:@"provience"]];
            
            if ([data valueForKey:@"birthday"]!=[NSNull null]) {
                
                NSArray* myArray = [[data valueForKey:@"birthday"]  componentsSeparatedByString:@"/"];
                
                day =myArray[2];
                month =myArray[1];
                year = myArray[0];
                
            }
            
            
            NSDictionary *allCity = [data valueForKey:@"allProvience"];
            self.provinceData =[data valueForKey:@"allProvience"];
            
            for (NSString *item in [allCity valueForKey:@"name"]) {
                
                [self.selections addObject:item];
            }
            
            
            
            self.cityId = [data valueForKey:@"cityid"]==[NSNull null]?@"":[NSString stringWithFormat:@"%@",[data valueForKey:@"cityid"]];
            
            if ([[data valueForKey:@"Gender"]isEqualToString:@"مرد"]) {
                genderSegment.selected = 0;
            }
            else
            {
                genderSegment.selected = 1;
            }
            
            birthdate =[data valueForKey:@"birthday"]== [NSNull null]?@"":[NSString stringWithFormat:@"%@",[data valueForKey:@"birthday"]];
            self.textFieldEnterDate.text = birthdate;
            
     
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"👻"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    
    [self.getData GetSetting:st.accesstoken withCallback:callback3];
    
    
    NSCalendar *persCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSPersianCalendar];
    NSDateFormatter *monthFormater = [[NSDateFormatter alloc] init];
    NSLocale *IRLocal = [[NSLocale alloc] initWithLocaleIdentifier:@"fa_IR"];
    [monthFormater setLocale:IRLocal];
    [monthFormater setCalendar:persCalendar];
    NSDate *today = [NSDate date];
    [monthFormater setDateFormat:@"yyyy/MM/dd"];
    NSString *currDay = [monthFormater stringFromDate:today];
    
    
    NSLog(@"Date %@", [NSString stringWithFormat:@"%@",currDay]);
    
    today =[monthFormater dateFromString: [NSString stringWithFormat:@"%@",currDay]];
    
    firstTimeLoad = YES;
    self.customPicker.hidden = YES;
    self.toolbarCancelDone.hidden = YES;
    
    self.textFieldEnterDate.inputView = self.customPicker;
    self.textFieldEnterDate.inputAccessoryView = self.toolbarCancelDone;
    
    NSDate *date = [NSDate date];
    
    // Get Current Year
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    [formatter setCalendar:persCalendar];
    
    NSString *currentyearString = [NSString stringWithFormat:@"%@",
                                   [formatter stringFromDate:date]];
    
    
    // Get Current  Month
    
    [formatter setDateFormat:@"MM"];
    
    currentMonthString = [NSString stringWithFormat:@"%ld",(long)[[formatter stringFromDate:date]integerValue]];
    
    
    // Get Current  Date
    
    [formatter setDateFormat:@"dd"];
    NSString *currentDateString = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    
    
    yearArray = [[NSMutableArray alloc]init];
    
    
    for (int i = 1300; i <= 1400 ; i++)
    {
        [yearArray addObject:[NSString stringWithFormat:@"%d",i]];
        
    }
    
    
    // PickerView -  Months data
    
    
    monthArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    
    
    

    
    // PickerView -  days data
    
    DaysArray = [[NSArray alloc]init];
    
    DaysArray = @[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31"];
    
    
//    for (int i = 1; i <= 31; i++)
//    {
//        [DaysArray addObject:[NSString stringWithFormat:@"%d",i]];
//        
//    }
//    
    
    // PickerView - Default Selection as per current Date
    
    [self.customPicker selectRow:[yearArray indexOfObject:currentyearString] inComponent:0 animated:YES];
    
    [self.customPicker selectRow:[monthArray indexOfObject:currentMonthString] inComponent:1 animated:YES];
    
    [self.customPicker selectRow:[DaysArray indexOfObject:currentDateString] inComponent:2 animated:YES];
    
    self.provinceTextField.enabled = YES;
    
    
    self.selections = [[NSMutableArray alloc]init];
    self.cityArray = [[NSMutableArray alloc]init];
    self.provinceData = [[ NSMutableDictionary alloc]init];
    self.cityData = [[ NSMutableDictionary alloc]init];
    
    RequestCompleteBlock callback2 = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            self.cityData = data;
            [self.cityArray removeAllObjects];
            for (NSString *item in [data valueForKey:@"name"]) {
                
                [self.cityArray addObject:item];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cityActivity stopAnimating];
                
            });
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"👻"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    
    
    self.popView = [[SGPopSelectView alloc] init];
    
    
    __weak typeof(self) weakSelf = self;
    
    __weak typeof(Settings*) weaksetting = st;
    
    self.popView.selectedHandle = ^(NSInteger selectedIndex){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if ([weakSelf.buttonId integerValue] == 12) {
                
                weakSelf.provinceTextField.text = [NSString stringWithFormat:@"%@",weakSelf.selections[selectedIndex]];
                [weakSelf.cityActivity startAnimating];
                
                
                for (NSString *item in weakSelf.provinceData) {
                    
                    if ([[item valueForKey:@"name"] isEqualToString:[NSString stringWithFormat:@"%@",weakSelf.selections[selectedIndex]]]) {
                        weakSelf.cityId =[NSString stringWithFormat:@"%@",[item valueForKey:@"id"]];
                        [weakSelf.getData GetCity:weakSelf.cityId Token:weaksetting.accesstoken withCallback:callback2];
                    }
                }
            }
            else if ([weakSelf.buttonId integerValue]==13)
            {
                for (NSString *item in weakSelf.cityData) {
                    if ([[item valueForKey:@"name"] isEqualToString:[NSString stringWithFormat:@"%@",weakSelf.cityArray[selectedIndex]]]) {
                        weakSelf.cityId =[NSString stringWithFormat:@"%@",[item valueForKey:@"id"]];
                    }
                    weakSelf.cityTextField.text = [NSString stringWithFormat:@"%@",weakSelf.cityArray[selectedIndex]];
                }
            }
            
            
        });
        
        NSLog(@"selected index %ld, content is %@", selectedIndex, weakSelf.selections[selectedIndex]);
    };
    
}


//hide keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    
    if (component == 0)
    {
        selectedYearRow = row;
        [self.customPicker reloadAllComponents];
    }
    else if (component == 1)
    {
        selectedMonthRow = row;
        [self.customPicker reloadAllComponents];
    }
    else if (component == 2)
    {
        selectedDayRow = row;
        
        [self.customPicker reloadAllComponents];
        
    }
    
}


#pragma mark - UIPickerViewDatasource

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    
    // Custom View created for each component
    
    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil) {
        CGRect frame = CGRectMake(0.0, 0.0, 50, 60);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:15.0f]];
        pickerLabel.font = [UIFont fontWithName:@"B Yekan" size:20 ];
        pickerLabel.textColor = [UIColor whiteColor];
        
    }
    
    
    
    if (component == 0)
    {
        pickerLabel.text =  [yearArray objectAtIndex:row]; // Year
    }
    else if (component == 1)
    {
        pickerLabel.text =  [monthArray objectAtIndex:row];  // Month
    }
    else if (component == 2)
    {
        pickerLabel.text =  [DaysArray objectAtIndex:row]; // Date
        
    }
    
    
    return pickerLabel;
    
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 3;
    
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if (component == 0)
    {
        return [yearArray count];
        
    }
    else if (component == 1)
    {
        return [monthArray count];
    }
    else if (component == 2)
    { // day
        
        if (firstTimeLoad)
        {
            if (currentMonth == 1 || currentMonth == 3 || currentMonth == 5 || currentMonth == 7 || currentMonth == 8 || currentMonth == 10 || currentMonth == 12)
            {
                return 31;
            }
            else if (currentMonth == 2)
            {
                int yearint = [[yearArray objectAtIndex:selectedYearRow]intValue ];
                
                if(((yearint %4==0)&&(yearint %100!=0))||(yearint %400==0)){
                    
                    return 29;
                }
                else
                {
                    return 28; // or return 29
                }
                
            }
            else
            {
                return 30;
            }
            
        }
        else
        {
            
            if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 || selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11)
            {
                return 31;
            }
            else if (selectedMonthRow == 1)
            {
                int yearint = [[yearArray objectAtIndex:selectedYearRow]intValue ];
                
                if(((yearint %4==0)&&(yearint %100!=0))||(yearint %400==0)){
                    return 29;
                }
                else
                {
                    return 28; // or return 29
                }
                
                
                
            }
            else
            {
                return 30;
            }
            
        }
    }
    return 30;
}






- (IBAction)actionCancel:(id)sender
{
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.customPicker.hidden = YES;
                         self.toolbarCancelDone.hidden = YES;
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                          self.textFieldEnterDate.text = birthdate;
                         
                     }];
    
   
    
    
}

- (IBAction)actionDone:(id)sender
{
    day =[DaysArray objectAtIndex:[self.customPicker selectedRowInComponent:2]];
    month =[monthArray objectAtIndex:[self.customPicker selectedRowInComponent:1]];
    year =[yearArray objectAtIndex:[self.customPicker selectedRowInComponent:0]];
    
    self.textFieldEnterDate.text = [NSString stringWithFormat:@"%@/%@/%@",[yearArray objectAtIndex:[self.customPicker selectedRowInComponent:0]],[monthArray objectAtIndex:[self.customPicker selectedRowInComponent:1]],[DaysArray objectAtIndex:[self.customPicker selectedRowInComponent:2]]];
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.customPicker.hidden = YES;
                         self.toolbarCancelDone.hidden = YES;
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         
                     }];
    
    
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if (textField.tag == 12 || textField.tag == 13) {
        return NO;
    }
    
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.customPicker.hidden = NO;
                         self.toolbarCancelDone.hidden = NO;
                         self.textFieldEnterDate.text = @"";
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    
    self.customPicker.hidden = NO;
    self.toolbarCancelDone.hidden = NO;
    self.textFieldEnterDate.text = @"";
    
    
    
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return  YES;
    
}

- (IBAction)showAction:(id)sender {
    
    CGPoint p = [(UITextField *)sender center];
    if (((UITextField*)sender).tag == 12) {
        self.popView.selections = self.selections;
        self.buttonId = [NSNumber numberWithInt:12];
        
    }
    
    else if(((UITextField*)sender).tag == 13 && [self.cityArray count]>0)
    {
        self.buttonId = [NSNumber numberWithInt:13];
        self.popView.selections = self.cityArray;
    }
    
    [self.popView showFromView:self.view atPoint:p animated:YES];
    
}

- (IBAction)tapAction:(UIGestureRecognizer *)sender {
    [self.popView hide:YES];
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.view];
    if (self.popView.visible && CGRectContainsPoint(self.popView.frame, p)) {
        return NO;
    }
    return YES;
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}

-(void)ApplyChanges:(id)sender
{
    // applyChangeButton.enabled =NO;
    [activityView startAnimating];
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            
            //   [applyChangeButton setEnabled:YES];
            [activityView stopAnimating];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                            message:@"تغییر یافت!"
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileChanged"
                                                                object:nil
                                                              userInfo:nil];
            
            
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    
    [self.getData SetSetiing:st.accesstoken Name:[NSString stringWithFormat:@"%@",nameTextField.text] LastName:[NSString stringWithFormat:@"%@", lastNameTextField.text] Gender:genderSegment.selectedSegmentIndex==1?@"زن":@"مرد" city:self.cityId birthdayDay:day birhtdayMonth:month birhtdayYear:year  withCallback:callback];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
