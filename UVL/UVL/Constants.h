//
//  UVLAppglobals.m
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#pragma mark Screen Sizes
#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPAD ([[UIScreen mainScreen] bounds].size.height == 1024)
#define IS_IPHONE_6Plus ([[UIScreen mainScreen] bounds].size.height == 736)

#define DriverBreakTimeSlot @"DriverBreakTimeSlot"
#define ROOT_VIEW_CONTROLLER [[[UIApplication sharedApplication] keyWindow] rootViewController]

#pragma mark SERVER CONSTANTS 
#define DriverID @"DriverID"
#define APiKEY @"ApiKey"
#define BASE_URL @"https://api-webservices.urbanvehiclelogistics.co.uk"
#define BASE_URL_PHOTOS @"https://api-webservices.urbanvehiclelogistics.co.uk/media_upload"
#define CHECK_SHIF_STATUS @"check-shift-status"
#define GET_NOTIFICATIONS @"notifications-list"
#define ACCEPT_NOTICATION @"accept-notification"
#define READ_NOTIFICATIONS @"read-notification"
#define EXPENSE_REQUEST @"shift-expenses"
#define SHIFT_START @"dev-start-shift"
#define END_SHIFT @"end-shift"
#define MOVEMENT_DETAIL @"movement-detail"
#define CHANGE_JOB_STATUS @"change-job-status"
#define GET_VEHICLE_DETAILS @"get-vehicle-detail"
#define ADD_VEHICLE_DETAILS @"add-vehicle-detail"
#define PANIC @"panic"
#define ON_BREAK @"on-break-or-available"
#define ADD_PHOTO @"upload-vehicle-photo"
#define GET_PHOTO @"get-vehicle-photo"
#define GET_MORE_STATUS @"get-more-screen-status"
#define DELETE_VEHICLE_PHOTO @"delete-vehicle-photo"
#define GET_DAILY_DEFECT @"get-daily-defect-check"
#define CREATE_DEFECT @"create-defect-report"
#define UPDATE_DEFECT @"update-defect-report"

#endif /* Constants_h */
