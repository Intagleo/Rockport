//
//  FootDescription.h
//  FittedSolution
//
//  Created by Waqar Ali on 01/08/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FootDescription : NSObject

@property (strong, nonatomic) NSString * resultID           ;
@property (strong, nonatomic) NSString * sideID             ;
@property (strong, nonatomic) NSString * footWidh           ;
@property (strong, nonatomic) NSString * footLength         ;
@property (strong, nonatomic) NSString * archHeight         ;
@property (strong, nonatomic) NSString * archDistance       ;
@property (strong, nonatomic) NSString * talusHeight        ;
@property (strong, nonatomic) NSString * toeBoxHeight       ;
@property (strong, nonatomic) NSString * talusSlope         ;
@property (strong, nonatomic) NSString * DL                 ;
@property (strong, nonatomic) NSString * frontFootImage     ;
@property (strong, nonatomic) NSString * sideFootImage      ;
@property (strong, nonatomic) NSString * men_US             ;
@property (strong, nonatomic) NSString * men_Euro           ;
@property (strong, nonatomic) NSString * men_UK             ;
@property (strong, nonatomic) NSString * women_US           ;
@property (strong, nonatomic) NSString * women_Euro         ;
@property (strong, nonatomic) NSString * women_UK           ;
@property (nonatomic, strong) NSString * menWidthCode       ;
@property (nonatomic, strong) NSString * womenWidthCode     ;

@property (nonatomic, strong) NSString * sideFootCutOutImageUrl  ;
@property (nonatomic, strong) NSString * frontFootCutOutImageUrl ;


@end
