//
//  SignatureVC.h
//  UVL
//
//  Created by Osama on 28/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UpdateSignatureView <NSObject>
-(void)sendSignatureBack:(UIImage *)signatureImage;
@end

@interface SignatureVC : UIViewController
@property id<UpdateSignatureView> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end
