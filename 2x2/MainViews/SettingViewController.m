//
//  SettingViewController.m
//  2x2
//
//  Created by aDb on 3/10/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "SettingViewController.h"
#import "MMCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "RSKImageCropViewController.h"
#import "AFNetworking.h"
#import "DBManager.h"
#import "Settings.h"
#import "DataDownloader.h"
#import "DXAlertView.h"
#define URLaddress "http://www.app.chargoosh.ir/api/ProfileManager/ChangePicture"
#define URLaddressPic "http://www.app.chargoosh.ir/"
#import "UIImageView+WebCache.h"

@interface SettingViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate,RSKImageCropViewControllerDelegate>
{
  Settings *st ;
    NSString *name;
    NSURL *imageURL;
}
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ChangeProfileInfo)
                                                 name:@"ProfileChanged"
                                               object:nil];
    
    st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    [self GetProfileInfo];
    
    [self setTitle:@"تنظیمات"];
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=self.navigationItem.title;
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont fontWithName:@"B Yekan+" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    self.tableView.estimatedRowHeight = 60;
   // self.tableView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.
   
}

- (void)GetProfileInfo {
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            name =[NSString stringWithFormat:@"%@ %@",[data valueForKey:@"name"],[data valueForKey:@"lastname"]];
            imageURL =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddressPic,[data valueForKey:@"picture"]]];
            [self.tableView reloadData];
            
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
    
    
    
    [self.getData GetProfilePicInfo:st.settingId Password:st.password
                       withCallback:callback];
}

-(void)ChangeProfileInfo
{
    [self GetProfileInfo];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView.estimatedRowHeight = 35;
    
    // self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    switch (indexPath.row) {
        case 0:
        {
            
            static NSString *cellIdentifier = @"ProfileCellIdentifier";
            
            MMCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if (cell==nil) {
                cell = [[MMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
            }
            
            cell.mmimageView.layer.cornerRadius = cell.mmimageView.frame.size.width / 2;
            cell.mmimageView.layer.masksToBounds = YES;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            [cell.activityView startAnimating];
            cell.startTimeLabel.text = st.settingId;
            
            cell.mmlabel.text =name;
            
            [self downloadImageWithURL:imageURL completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    // change the image in the cell
                    cell.mmimageView.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [cell.activityView stopAnimating];
                        
                    });
                }
            }];
            
            return cell;
        }
            break;
            
        case 1:
        {
            static NSString *cellIdentifier = @"ChangePicCellIdentifier";
            MMCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if (cell==nil) {
                
                cell = [[MMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
              
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.coinButton addTarget:self action:@selector(ChangePic:)forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        case 2:
        {
            static NSString *cellIdentifier = @"EmptyCellIdentifier1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if (cell==nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            return cell;
        }
        case 3:
        {
            static NSString *cellIdentifier = @"PersonalCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if (cell==nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
            }
            return cell;
        }
        case 4:
        {
            static NSString *cellIdentifier = @"InviteCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if (cell==nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
            }
            return cell;
        }
        case 5:
        {
            static NSString *cellIdentifier = @"AboutCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if (cell==nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
            }
            return cell;
        }
        case 6:
        {
            static NSString *cellIdentifier = @"EmptyCellIdentifier2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if (cell==nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            return cell;
        }
        case 7:
        {
            static NSString *cellIdentifier = @"ClearImageCacheCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if (cell==nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
            }
            return cell;
        }
        case 8:
        {
            static NSString *cellIdentifier = @"DestroyCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if (cell==nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
            }
            return cell;
        }
        case 9:
        {
            
            static NSString *cellIdentifier = @"LogoutCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if (cell==nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
            }
            
            return cell;
        }
            
        default:
            return nil;
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            
        case 7:
        {
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"پاک کردن" contentText:@"آیا مطمئن هستید؟" leftButtonTitle:@"خیر" rightButtonTitle:@"بله"];
            [alert show];
            alert.leftBlock = ^() {
                NSLog(@"left button clicked");
            };
            alert.rightBlock = ^() {
                NSLog(@"right button clicked");
                [SDWebImageManager.sharedManager.imageCache clearMemory];
                 [SDWebImageManager.sharedManager.imageCache clearDisk];
            };
            alert.dismissBlock = ^() {
                NSLog(@"Do something interesting after dismiss block");
                NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
                [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
            };
         
        }
            break;
        case 9:
        {
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"خروج" contentText:@"آیا مطمئن هستید؟" leftButtonTitle:@"خیر" rightButtonTitle:@"بله"];
            [alert show];
            alert.leftBlock = ^() {
                NSLog(@"left button clicked");
            };
            alert.rightBlock = ^() {
                NSLog(@"right button clicked");
                [DBManager deleteRow:st.settingId];
                [self performSegueWithIdentifier:@"logout" sender:self];
            };
            alert.dismissBlock = ^() {
                NSLog(@"Do something interesting after dismiss block");
                NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
                [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
            };
        }
            break;
            
            case 8:
        {
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"حذف اطلاعات" contentText:@"آیا مطمئن هستید؟ تمامی اطلاعات پاک شده و غیر قابل برگشت است!" leftButtonTitle:@"خیر" rightButtonTitle:@"بله"];
            [alert show];
            alert.leftBlock = ^() {
                NSLog(@"left button clicked");
            };
            alert.rightBlock = ^() {
                NSLog(@"right button clicked");
                [self ClearME];
           
            };
            alert.dismissBlock = ^() {
                NSLog(@"Do something interesting after dismiss block");
                NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
                [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
            };
            
          
        
        }
            
            
        default:
            break;
    }
    
 
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            return 92;
        }
            break;
            
        case 1:
        {     return 40;
        }
        case 2:
        {
            
            return 35;
        }
        case 3:
        {
            return 60;
        }
        case 4:
        {   return 60;
        }
        case 5:
        {   return 60;
        }
        case 6:
        {   return 35;
        }
        case 7:
        {
            return 47;
        }
        case 8:
        {
            return 47;
        }
        case 9:
        {
            
            
            return 47;
        }
            
        default:
            return 50;
            break;
    }
    
}

-(void)ClearME
{
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            [DBManager deleteRow:st.settingId];
            [self performSegueWithIdentifier:@"logout" sender:self];
            
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
    
    
    
    [self.getData ClearME:st.settingId Password:st.password
                       withCallback:callback];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // this UIViewController is about to re-appear, make sure we remove the current selection in our table view
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}


-(void)ChangePic:(id)sender
{

    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"لغو"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"انتخاب",@"عکس بگیر" ,nil];
    [choiceSheet showInView:self.view];
  
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
            RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:portraitImg];
        
            imageCropVC.delegate = self;
        
            [self.navigationController pushViewController:imageCropVC animated:YES];
       
    
        }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
   
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 0) {

        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
 
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    MMCell *cell = (MMCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.mmimageView.image = croppedImage;
    cell.mmimageView.alpha = .3;
    [cell.activityView startAnimating];
    
    [self PostPicture:croppedImage];
    
   // [self.addPhotoButton setImage:croppedImage forState:UIControlStateNormal];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)PostPicture:(UIImage*)imageToSend
{
    NSString *fileName = [NSString stringWithFormat:@"%ld%c%c.jpg", (long)[[NSDate date] timeIntervalSince1970], arc4random_uniform(26) + 'a', arc4random_uniform(26) + 'a'];
    
    NSDictionary *parameters = @{@"phoneNumber": st.settingId,
                                 @"pass": st.password,
                                 @"Wimg":fileName};
    
    NSString *URLString = @URLaddress;
    
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer]
                             multipartFormRequestWithMethod:
                             @"POST" URLString:URLString
                             parameters:parameters
                             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                 [formData
                                  appendPartWithFileData:UIImageJPEGRepresentation(imageToSend, .6)
                                  name:@"Wimg"
                                  fileName:fileName
                                  mimeType:@"jpg"];
                             } error:(NULL)];
    
    AFHTTPRequestOperation *operation =
    [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                               id responseObject) {
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        MMCell *cell = (MMCell *)[self.tableView cellForRowAtIndexPath:indexPath];
         cell.mmimageView.alpha = 1;
        cell.mmimageView.image = imageToSend;
        [cell.activityView stopAnimating];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfilePicIsChanged"
                                                            object:nil
                                                          userInfo:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failure %@, %@", error, operation.responseString);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                        message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                       delegate:self
                                              cancelButtonTitle:@"خب"
                                              otherButtonTitles:nil];
        [alert show];
        

      
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    
    [operation start];


}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
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
