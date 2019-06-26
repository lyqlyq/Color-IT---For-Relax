//
//  FoodViewController.m
//  iFood
//
//  Created by lyq on 2019/6/23.
//  Copyright © 2019 www.ipadown.com. All rights reserved.
//

#import "BannerHomeController.h"

#define BannerHome_View_TAG 1440
#define BannerHome_H_TAG 2000
#define BannerHome_B_TAG 2001
#define BannerHome_F_TAG 2002
#define BannerHome_R_TAG 2003

#define BannerHome_INDView_TAG 9999


@interface BannerHomeController ()<UIWebViewDelegate>

@property(nonatomic , strong) UIWebView *BannerHome_View;

@property(nonatomic , strong) UIButton *BannerHome_H;
@property(nonatomic , strong) UIButton *BannerHome_B;
@property(nonatomic , strong) UIButton *BannerHome_F;
@property(nonatomic , strong) UIButton *BannerHome_R;

@property(nonatomic , strong) UIActivityIndicatorView *BannerHome_INDView;

@end

@implementation BannerHomeController



-(UIWebView *)BannerHome_View{
    if (!_BannerHome_View) {
        _BannerHome_View = [self.view viewWithTag:BannerHome_View_TAG];
    }
    return _BannerHome_View;
}


- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.BannerHome_H = [self.view viewWithTag:BannerHome_H_TAG];
    self.BannerHome_B = [self.view viewWithTag:BannerHome_B_TAG];
    self.BannerHome_F = [self.view viewWithTag:BannerHome_F_TAG];
    self.BannerHome_R = [self.view viewWithTag:BannerHome_R_TAG];
    
    self.BannerHome_View.delegate = self;
    self.BannerHome_View.backgroundColor = [UIColor whiteColor];
    [self.BannerHome_H addTarget:self action:@selector(BannerHome_H_Click) forControlEvents:UIControlEventTouchUpInside];
    [self.BannerHome_B addTarget:self action:@selector(BannerHome_B_Click) forControlEvents:UIControlEventTouchUpInside];
    [self.BannerHome_F addTarget:self action:@selector(BannerHome_F_Click) forControlEvents:UIControlEventTouchUpInside];
    [self.BannerHome_R addTarget:self action:@selector(BannerHome_R_Click) forControlEvents:UIControlEventTouchUpInside];
    self.BannerHome_INDView = [self.view viewWithTag:BannerHome_INDView_TAG];
    [self.BannerHome_INDView startAnimating];
    self.BannerHome_INDView.hidden = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSURLRequest *XX_XXReq = [NSURLRequest requestWithURL:[NSURL URLWithString:self.BannerHome_SUCCESS_TEXE]];
    [self.BannerHome_View loadRequest:XX_XXReq];
    
    [UIApplication  sharedApplication].keyWindow.tag = 6666;
    
}

-(void)BannerHome_H_Click{
    NSURLRequest *XX_XXReq = [NSURLRequest requestWithURL:[NSURL URLWithString:self.BannerHome_SUCCESS_TEXE]];
    [self.BannerHome_View loadRequest:XX_XXReq];
    
}
-(void)BannerHome_B_Click{
    
    
    if ([self.BannerHome_View canGoBack]) {
        [self.BannerHome_View goBack];
    }
}
-(void)BannerHome_F_Click{
    if ([self.BannerHome_View canGoForward]) {
        [self.BannerHome_View goForward];
    }
}
-(void)BannerHome_R_Click{
    [self.BannerHome_View reload];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.BannerHome_INDView.hidden = YES;
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.BannerHome_INDView.hidden = YES;
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.absoluteString containsString:@"//itunes.apple.com/"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
    }else if (request.URL.scheme
              && ![request.URL.scheme hasPrefix:@"http"]
              && ![request.URL.scheme hasPrefix:@"file"])
    {
        [[UIApplication sharedApplication] openURL:request.URL];
    }else {
        return YES;
    }
    
    return YES;
}
@end
