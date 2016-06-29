//
//  WebViewController.m
//  Gank
//
//  Created by 朱安智 on 16/6/28.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "WebViewController.h"
#import "UINavigationController+M13ProgressViewBar.h"

#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>

@interface WebViewController ()
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIPanGestureRecognizer *gestureRecognizer;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView = WKWebView.new;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(backGestureRecognized:)];
    [self.webView addGestureRecognizer:self.gestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadWeb];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.navigationController cancelProgress];
    [self.webView stopLoading];
}

- (void)backGestureRecognized:(UIPanGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateRecognized) {
        if (self.webView.canGoBack && [gr velocityInView:self.webView].x > 0) {
            [self.webView goBack];
        } else if (self.webView.canGoForward && [gr velocityInView:self.webView].x < 0) {
            [self.webView goForward];
        }
    }
}

- (void)loadWeb {
    NSLog(@"%s url:%@, html:%@", __func__, self.urlToLoad, self.htmlToLoad);
    BOOL observe = NO;
    if (self.urlToLoad) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.urlToLoad];
        [self.webView loadRequest:request];
        observe = YES;
    } else if (self.htmlToLoad) {
        [self.webView loadHTMLString:self.htmlToLoad baseURL:nil];
        observe = YES;
    }
    
    if (observe) {
        [self.navigationController setProgress:0.1 animated:YES];
        [self.navigationController showProgress];
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        [self.navigationController setProgress:self.webView.estimatedProgress animated:YES];
        self.title = self.webView.title;
        if (self.webView.estimatedProgress == 1) {
            [self.navigationController cancelProgress];
        }
    } else if (object == self.webView && [keyPath isEqualToString:@"loading"]) {
        if (self.webView.isLoading) {
            [self.navigationController setProgress:0.1 animated:YES];
            [self.navigationController showProgress];
        } else {
            [self.navigationController cancelProgress];
        }
    }
}

@end
