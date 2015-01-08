
//  UARTViewController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Collin Cunningham on 9/30/14.
//  Copyright (c) 2014 Adafruit Industries. All rights reserved.
//

import Foundation
import UIKit
import dispatch


protocol UARTViewControllerDelegate: HelpViewControllerDelegate {
    
    func sendData(newData:NSData)
    
}


class UARTViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate{

    enum ConsoleDataType {
        case Log
        case RX
        case TX
    }
    
    enum ConsoleMode {
        case ASCII
        case HEX
    }
    
    var delegate:UARTViewControllerDelegate?
    @IBOutlet var helpViewController:HelpViewController!
    @IBOutlet var msgInputYContraint:NSLayoutConstraint?    //iPad
    @IBOutlet  var offButton: UIButton!
    @IBOutlet  var mode1Button: UIButton!
    @IBOutlet  var mode2Button: UIButton!
    @IBOutlet  var mode3Button: UIButton!
    @IBOutlet  var mode4Button: UIButton!
    @IBOutlet  var mode5Button: UIButton!
    @IBOutlet  var mode6Button: UIButton!
    @IBOutlet  var mode7Button: UIButton!
    @IBOutlet  var mode8button: UIButton!
    @IBOutlet weak var sliderIntensity: UISlider!
    @IBOutlet weak var intensityBtn: UIButton!
    @IBOutlet weak var unicornLogo: UIImageView!
    
    private var echoLocal:Bool = false
    private var keyboardIsShown:Bool = false
    private var consoleAsciiText:NSAttributedString? = NSAttributedString(string: "")
    private var consoleHexText: NSAttributedString? = NSAttributedString(string: "")
    private let backgroundQueue : dispatch_queue_t = dispatch_queue_create("com.adafruit.bluefruitconnect.bgqueue", nil)
    private var lastScroll:CFTimeInterval = 0.0
    private let scrollIntvl:CFTimeInterval = 1.0
    private var lastScrolledLength = 0
    private var scrollTimer:NSTimer?
    private var blueFontDict:NSDictionary!
    private var redFontDict:NSDictionary!
    private let unkownCharString:NSString = "�"
    private let kKeyboardAnimationDuration = 0.3
    private let notificationCommandString = "N!"
    
    convenience init(aDelegate:UARTViewControllerDelegate){
        
        //Separate NIBs for iPhone 3.5", iPhone 4", & iPad
        
        var nibName:NSString
        
        if IS_IPHONE {
            nibName = "UARTViewController_iPhone"
        }
        else{   //IPAD
            nibName = "UARTViewController_iPad"
        }
        
        self.init(nibName: nibName, bundle: NSBundle.mainBundle())
        
        self.delegate = aDelegate
        self.title = "Horn"
    }
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad(){
        //setup help view
        self.helpViewController.title = "UART Help"
        self.helpViewController.delegate = delegate
        self.offButton.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        self.mode1Button.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        self.mode2Button.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        self.mode3Button.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        self.mode4Button.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        self.mode5Button.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        self.mode6Button.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        self.mode7Button.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        self.mode8button.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        
        self.offButton.selected = true;
    }
    
    
    override func didReceiveMemoryWarning(){
        
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollTimer?.invalidate()
        
        scrollTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("scrollConsoleToBottom:"), userInfo: nil, repeats: true)
        scrollTimer?.tolerance = 0.75
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        scrollTimer?.invalidate()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        //unregister for keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        super.viewWillDisappear(animated)
        
    }
    
    
    func updateConsoleWithIncomingData(newData:NSData) {
        
        //Write new received data to the console text view
        dispatch_async(backgroundQueue, { () -> Void in
            //convert data to string & replace characters we can't display
            let dataLength:Int = newData.length
            var data = [UInt8](count: dataLength, repeatedValue: 0)
            
            newData.getBytes(&data, length: dataLength)
            
            for index in 0...dataLength-1 {
                if (data[index] <= 0x1f) || (data[index] >= 0x80) { //null characters
                    if (data[index] != 0x9)       //0x9 == TAB
                        && (data[index] != 0xa)   //0xA == NL
                        && (data[index] != 0xd) { //0xD == CR
                            data[index] = 0xA9
                    }
                    
                }
            }
            
            
            let newString = NSString(bytes: &data, length: dataLength, encoding: NSUTF8StringEncoding)
            printLog(self, "updateConsoleWithIncomingData", newString!)
            
            //Update ASCII text on background thread A
            let appendString = "" // or "\n"
            let attrAString = NSAttributedString(string: (newString!+appendString), attributes: self.redFontDict)
            let newAsciiText = NSMutableAttributedString(attributedString: self.consoleAsciiText!)
            newAsciiText.appendAttributedString(attrAString)
            
            let newHexString = newData.hexRepresentationWithSpaces(true)
            let attrHString = NSAttributedString(string: newHexString, attributes: self.redFontDict)
            let newHexText = NSMutableAttributedString(attributedString: self.consoleHexText!)
            newHexText.appendAttributedString(attrHString)
            
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateConsole(newAsciiText, hexText: newHexText)
//                self.insertConsoleText(attrAString.string, hexText: attrHString.string)
            })
        })
        
    }
    
    
    func updateConsole(asciiText: NSAttributedString, hexText: NSAttributedString){
    }
    
    
    func scrollConsoleToBottom(timer:NSTimer) {
    }
    
    
    func updateConsoleWithOutgoingString(newString:NSString){
        
    }
    
    
    func resetUI() {

    }

    func receiveData(newData : NSData){
        
        if (isViewLoaded() && view.window != nil) {
            
            updateConsoleWithIncomingData(newData)
        }
        
    }
    
    //MARK: UITextViewDelegate methods
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) ->Bool {
        
        //Keyboard's Done button was tapped
        
//        sendMessage(self)
//        inputField.resignFirstResponder()

        
        return true
    }
    
    
    @IBAction func consoleModeControlDidChange(sender : UISegmentedControl){
        
    }
    
    
    func didConnect(){
        
        resetUI()
        
    }
    
    
    func sendNotification(msgString:String) {
        
        let note = UILocalNotification()
//        note.fireDate = NSDate().dateByAddingTimeInterval(2.0)
//        note.fireDate = NSDate()
        note.alertBody = msgString
        note.soundName =  UILocalNotificationDefaultSoundName
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIApplication.sharedApplication().presentLocalNotificationNow(note)
        })
        
        
    }
    
    @IBAction func offBtn(sender: UIButton) {
        sender.selected = true;
        
        let subviews = self.view.subviews as [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if(button != sender){
                    button.selected = false;
                }
            }
        }
        
        var newString = NSInteger(0)
        let data = NSData(bytes: &newString, length: 1)
        delegate?.sendData(data)
    }
    @IBAction func OneBtn(sender: UIButton) {
        sender.selected = true;
        
        let subviews = self.view.subviews as [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if(button != sender){
                    button.selected = false;
                }
            }
        }
        
        var newString = NSInteger(1)
        let data = NSData(bytes: &newString, length: 1)
        delegate?.sendData(data)
    }
    @IBAction func TwoBtn(sender: UIButton) {
        sender.selected = true;
        
        let subviews = self.view.subviews as [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if(button != sender){
                    button.selected = false;
                }
            }
        }
        
        var newString = NSInteger(2)
        let data = NSData(bytes: &newString, length: 1)
        delegate?.sendData(data)
    }
    @IBAction func ThreeBtn(sender: UIButton) {
        sender.selected = true;
        
        let subviews = self.view.subviews as [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if(button != sender){
                    button.selected = false;
                }
            }
        }
        
        var newString = NSInteger(3)
        let data = NSData(bytes: &newString, length: 1)
        delegate?.sendData(data)
    }
    @IBAction func FourBtn(sender: UIButton) {
        sender.selected = true;
        
        let subviews = self.view.subviews as [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if(button != sender){
                    button.selected = false;
                }
            }
        }
        
        var newString = NSInteger(4)
        let data = NSData(bytes: &newString, length: 1)
        delegate?.sendData(data)
    }
    @IBAction func FiveBtn(sender: UIButton) {
        sender.selected = true;
        
        let subviews = self.view.subviews as [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if(button != sender){
                    button.selected = false;
                }
            }
        }
        
        var newString = NSInteger(5)
        let data = NSData(bytes: &newString, length: 1)
        delegate?.sendData(data)
    }
    @IBAction func SixBtn(sender: UIButton) {
        sender.selected = true;
        
        let subviews = self.view.subviews as [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if(button != sender){
                    button.selected = false;
                }
            }
        }
        
        var newString = NSInteger(6)
        let data = NSData(bytes: &newString, length: 1)
        delegate?.sendData(data)
    }
    @IBAction func SevenBtn(sender: UIButton) {
        sender.selected = true;
        
        let subviews = self.view.subviews as [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if(button != sender){
                    button.selected = false;
                }
            }
        }
        
        var newString = NSInteger(7)
        let data = NSData(bytes: &newString, length: 1)
        delegate?.sendData(data)
    }
    @IBAction func EightBtn(sender: UIButton) {
        sender.selected = true;
        
        
        let subviews = self.view.subviews as [UIView]
        for v in subviews {
            if let button = v as? UIButton {
                if(button != sender){
                    button.selected = false;
                }
            }
        }
        
        var newString = NSInteger(8)
        let data = NSData(bytes: &newString, length: 1)
        delegate?.sendData(data)
    }
    
    @IBAction func setIntensity(sender: UIButton) {
        var valueSlider:Float = Float(sliderIntensity.value)
        var roundedValue:Float = round(valueSlider)
        var valueInt:Int = Int(roundedValue)
        let data = NSData(bytes: &valueInt, length: 3)
        delegate?.sendData(data)
        println(data)
    }

    @IBAction func changeValue(sender: UISlider) {
        var sliderValue:Float = Float(sliderIntensity.value)
        var valueRounded:Float = round(sliderValue)
        sliderIntensity.setValue(valueRounded, animated: true)
        //unicornLogo.alpha = CGFloat((valueRounded - 240.0) / 10)
    }
}
