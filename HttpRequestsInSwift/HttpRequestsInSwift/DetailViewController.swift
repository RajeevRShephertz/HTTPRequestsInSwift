//
//  DetailViewController.swift
//  HttpRequestsInSwift
//
//  Created by Rajeev Ranjan on 09/04/16.
//  Copyright © 2016 Rajeev Ranjan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var data = NSMutableData()
    var selectedIndex = -1
    var activityIndicator:UIActivityIndicatorView? = nil

    var detailItem: Int? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        //self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /**
     * Asynchronous Call with completion handler
     */
    
    func callAsyncWithCompletionHandler(urlString:String)
    {
        print("callAsyncWithCompletionHandler")
        
        let url = NSURL(string: urlString)// Creating URL
        let request = NSURLRequest(URL:url!)// Creating Http Request
        
        // Creating NSOperationQueue to which the handler block is dispatched when the request completes or failed
        let queue: NSOperationQueue = NSOperationQueue()
        
        // Sending Asynchronous request using NSURLConnection
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{(response:NSURLResponse?, responseData:NSData?, error: NSError?) ->Void in
            
            if error != nil
            {
                print(error!.description)
                dispatch_async(dispatch_get_main_queue(),{
                    
                    self.removeActivityIndicator()
                })
            }
            else
            {
                let responseStr:NSString = NSString(data:responseData!, encoding:NSUTF8StringEncoding)!
                dispatch_async(dispatch_get_main_queue(),{
                    
                    self.createWebViewLoadHTMLString(responseStr);
                })
            }
        })
    }
    
    /**
     * Synchronous Call
     */
    
    func callSynchronous(urlString:String)
    {
        //let urlString = "Your_URL_Here"
        let url = NSURL(string: urlString)// Creating URL
        let request = NSURLRequest(URL: url!) // Creating Http Request
        
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil

        // Sending Synchronous request using NSURLConnection
        do {
            let responseData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
            //Converting data to String
            let responseStr:NSString = NSString(data:responseData, encoding:NSUTF8StringEncoding)!
            self.createWebViewLoadHTMLString(responseStr);
        } catch (let e) {
            print(e)
            self.removeActivityIndicator()
        }
    }
    
    
    /**
     * Asynchronous Call
     */
    func callAsynchronous(urlString:String)
    {
        
        NSLog("connectWithUrl")
        let url = NSURL(string: urlString)// Creating URL
        let request = NSURLRequest(URL: url!)// Creating Http Request
        //Making request
        NSURLConnection(request: request, delegate: self, startImmediately: true)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse)
    {
        //Will be called when
        NSLog("didReceiveResponse")
    }
    
    func connection(connection: NSURLConnection, didReceiveData _data: NSData)
    {
        NSLog("didReceiveData")
        self.data.appendData(_data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection)
    {
        NSLog("connectionDidFinishLoading")
        
        let responseStr:NSString = NSString(data:self.data, encoding:NSUTF8StringEncoding)!
        self.createWebViewLoadHTMLString(responseStr);
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError)
    {
        NSLog("didFailWithError=%@",error)
        self.removeActivityIndicator()
    }
    
    
    /**
     * ------------------ Create WebView and load HTML contents ----------------------------
     */
    
    func createWebViewLoadHTMLString(htmlString:NSString)
    {
        let applicationFrame:CGRect = UIScreen.mainScreen().bounds
        
        
        let webView:UIWebView = UIWebView(frame: applicationFrame)
        webView.delegate = self
        self.view.addSubview(webView)
        
        if activityIndicator != nil
        {
            self.view.bringSubviewToFront(activityIndicator!)
        }
        
        webView.loadHTMLString(htmlString as String, baseURL: nil)
    }
    
    /**
     * ---------------------------- UIWebViewDelegate Methods ----------------------------
     */
    func webViewDidStartLoad(webView: UIWebView)
    {
        print("WebViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        print("WebViewDidFinishLoad")
        self.removeActivityIndicator()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?)
    {
        print("WebView didFailLoadWithError")
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
        self.view.addSubview(activityIndicator!)
        
        activityIndicator!.startAnimating()
        
    }
    
    func removeActivityIndicator()
    {
        if (activityIndicator != nil)
        {
            activityIndicator!.stopAnimating()
        }
    }

}

