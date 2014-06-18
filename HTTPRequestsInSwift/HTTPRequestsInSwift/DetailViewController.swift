//
//  DetailViewController.swift
//  HTTPRequestsInSwift
//
//  Created by Shephertz on 17/06/14.
//  Copyright (c) 2014 Shephertz. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UISplitViewControllerDelegate, UIWebViewDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate {

    @IBOutlet var detailDescriptionLabel: UILabel
    var masterPopoverController: UIPopoverController? = nil
    var data = NSMutableData()
    var selectedIndex = -1
    var activityIndicator:UIActivityIndicatorView? = nil


    var detailItem: Int? {
        didSet {
            // Update the view.
            //self.configureView()
            if self.masterPopoverController != nil {
                self.masterPopoverController!.dismissPopoverAnimated(true)
            }
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.configureView()
        self.showActivityIndicator()
        if detailItem==0
        {
            self.callSynchronous("http://api.shephertz.com")
        }
        else if detailItem == 1
        {
            self.callAsynchronous("http://api.shephertz.com")
        }
        else
        {
            self.callAsyncWithCompletionHandler("http://api.shephertz.com")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     * Synchronous Call
     */
    
    func callSynchronous(urlString:String)
    {
        var urlString = "Your_URL_Here"
        var url = NSURL.URLWithString(urlString)// Creating URL
        var request = NSURLRequest(URL: url) // Creating Http Request

        var response:AutoreleasingUnsafePointer<NSURLResponse?> = nil;
        var error: AutoreleasingUnsafePointer<NSErrorPointer?> = nil;

        // Sending Synchronous request using NSURLConnection
        var responseData = NSURLConnection.sendSynchronousRequest(request,returningResponse: response, error:nil) as NSData

        if error != nil
        {
            self.removeActivityIndicator()
        }
        else
        {
            //Converting data to String
            var responseStr:NSString = NSString(data:responseData, encoding:NSUTF8StringEncoding)
            var responseDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(responseData,options: NSJSONReadingOptions.MutableContainers, error:nil) as NSDictionary
            self.createWebViewLoadHTMLString(responseStr);
        }
    }
    
    /**
     * Asynchronous Call with completion handler
     */
    
    func callAsyncWithCompletionHandler(urlString:String)
    {
        println("callAsyncWithCompletionHandler")
        
var url = NSURL.URLWithString(urlString)// Creating URL
var request = NSURLRequest(URL: url)// Creating Http Request

// Creating NSOperationQueue to which the handler block is dispatched when the request completes or failed
var queue: NSOperationQueue = NSOperationQueue()

// Sending Asynchronous request using NSURLConnection
NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{(response:NSURLResponse!, responseData:NSData!, error: NSError!) ->Void in
    
        if error != nil
        {
            println(error.description)
            self.removeActivityIndicator()
        }
        else
        {
            var responseStr:NSString = NSString(data:responseData, encoding:NSUTF8StringEncoding)
            //var responseDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(responseData,options: NSJSONReadingOptions.MutableContainers, error:nil) as NSDictionary
            self.createWebViewLoadHTMLString(responseStr);
        }
    })
    }
    
    /**
     * Asynchronous Call
     */
    func callAsynchronous(urlString:String)
    {
        
        NSLog("connectWithUrl")
        var url = NSURL.URLWithString(urlString)// Creating URL
        var request = NSURLRequest(URL: url)// Creating Http Request
        //Making request
        var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!)
    {
        //Will be called when
        NSLog("didReceiveResponse")
    }

    func connection(connection: NSURLConnection!, didReceiveData _data: NSData!)
    {
        NSLog("didReceiveData")
        self.data.appendData(_data)
    }

    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        NSLog("connectionDidFinishLoading")
        
        var responseStr:NSString = NSString(data:self.data, encoding:NSUTF8StringEncoding)
        //var responseDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(responseData,options: NSJSONReadingOptions.MutableContainers, error:nil) as NSDictionary
        self.createWebViewLoadHTMLString(responseStr);
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!)
    {
        NSLog("didFailWithError=%@",error)
        self.removeActivityIndicator()
    }

    
    /**
     * ------------------ Create WebView and load HTML contents ----------------------------
     */
    
    func createWebViewLoadHTMLString(htmlString:NSString)
    {
        var applicationFrame:CGRect = UIScreen.mainScreen().applicationFrame
        
        var webViewFrame = CGRectMake(applicationFrame.origin.x, applicationFrame.origin.y+80, applicationFrame.size.width, applicationFrame.size.height)
        
        var webView:UIWebView = UIWebView(frame: applicationFrame)
        webView.delegate = self
        self.view.addSubview(webView)
        
        if activityIndicator != nil
        {
            self.view.bringSubviewToFront(activityIndicator)
        }
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
   /**
    * ---------------------------- UIWebViewDelegate Methods ----------------------------
    */
    func webViewDidStartLoad(webView: UIWebView!)
    {
        println("WebViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(webView: UIWebView!)
    {
        println("WebViewDidFinishLoad")
        self.removeActivityIndicator()
    }
    
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!)
    {
        println("WebView didFailLoadWithError")
        self.removeActivityIndicator()
    }
    
    /**
     * ---------------------------- Showing Alerts ----------------------------
     */
    
    func showActivityIndicator()
    {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.Gray)
        activityIndicator!.center = self.view.center
        //activityIndicator!.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator!.startAnimating()
        
    }
    
    func removeActivityIndicator()
    {
        if activityIndicator
        {
            activityIndicator!.stopAnimating()
        }
    }
    
    // #pragma mark - Split view

    func splitViewController(splitController: UISplitViewController, willHideViewController viewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController popoverController: UIPopoverController) {
        barButtonItem.title = "Master" // NSLocalizedString(@"Master", @"Master")
        self.navigationItem.setLeftBarButtonItem(barButtonItem, animated: true)
        self.masterPopoverController = popoverController
    }

    func splitViewController(splitController: UISplitViewController, willShowViewController viewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem) {
        // Called when the view is shown again in the split view, invalidating the button and popover controller.
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        self.masterPopoverController = nil
    }
    func splitViewController(splitController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return true
    }

}

