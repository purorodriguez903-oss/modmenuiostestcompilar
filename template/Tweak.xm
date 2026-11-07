#import "Macros.h"

/***********************************************************
  INSIDE THE FUNCTION BELOW YOU'LL HAVE TO ADD YOUR SWITCHES!
***********************************************************/
void setup() {

  // Direct offset patches (comentados por defecto para evitar crasheos si los offsets no coinciden)
  // patchOffset(ENCRYPTOFFSET("0x1002DB3C8"), ENCRYPTHEX("0xC0035FD6"));
  // patchOffset(ENCRYPTOFFSET("0x10020D2D4"), ENCRYPTHEX("0x00008052C0035FD6"));


  // Empty switch - usefull with hooking
  [switches addSwitch:NSSENCRYPT("Masskill")
    description:NSSENCRYPT("Teleport all enemies to you without them knowing")
  ];

  // Offset Switch with one patch
  [switches addOffsetSwitch:NSSENCRYPT("God Mode")
    description:NSSENCRYPT("You can't die")
    offsets: {
      ENCRYPTOFFSET("0x1005AB148")
    }
    bytes: {
      ENCRYPTHEX("0x00E0BF12C0035FD6")
    }
  ];

  // Offset switch with multiple patches
  [switches addOffsetSwitch:NSSENCRYPT("One Hit Kill")
    description:NSSENCRYPT("Enemy will die instantly")
    offsets: {
      ENCRYPTOFFSET("0x1001BB2C0"),
      ENCRYPTOFFSET("0x1002CB3B0"),
      ENCRYPTOFFSET("0x1002CB3B8")
    }
    bytes: {
      ENCRYPTHEX("0x00E0BF12C0035FD6"),
      ENCRYPTHEX("0xC0035FD6"),
      ENCRYPTHEX("0x00F0271E0008201EC0035FD6")
    }
  ];

  // Textfield Switch - used in hooking
  [switches addTextfieldSwitch:NSSENCRYPT("Custom Gold")
    description:NSSENCRYPT("Here you can enter your own gold amount")
    inputBorderColor:UIColorFromHex(0xBD0000)
  ];

  // Slider Switch - used in hooking
  [switches addSliderSwitch:NSSENCRYPT("Custom Move Speed")
    description:NSSENCRYPT("Set your custom move speed")
    minimumValue:0
    maximumValue:10
    sliderColor:UIColorFromHex(0xBD0000)
  ];
}


/**********************************************************************************************************
     You can customize the menu here
     For colors, you can use hex color codes or UIColor itself
      - For the hex color #BD0000 you'd use: UIColorFromHex(0xBD0000)
      - For UIColor you can visit this site: https://www.uicolor.xyz/#/rgb-to-ui
        NOTE: remove the ";" when you copy your UIColor from there!
     
     Site to find your perfect font for the menu: http://iosfonts.com/  --> view on mac or ios device
     See comment next to maxVisibleSwitches!!!!

     menuIcon & menuButton is base64 data, upload a image to: https://www.browserling.com/tools/image-to-base64 \
     then replace that string with mine.
************************************************************************************************************/
void setupMenu() {

  // Free Fire usa UnityFramework.framework como ejecutable base
  [menu setFrameworkName:"UnityFramework"];

  menu = [[Menu alloc]  
            initWithTitle:NSSENCRYPT("RAFA IOS")
            titleColor:[UIColor whiteColor]
            titleFont:NSSENCRYPT("Copperplate-Bold")
            credits:NSSENCRYPT("RafaModzYT Is back\n\nDisfrutalo!")
            headerColor:UIColorFromHex(0xBD0000)
            switchOffColor:[UIColor darkGrayColor]
            switchOnColor:UIColorFromHex(0x00ADF2)
            switchTitleFont:NSSENCRYPT("Copperplate-Bold")
            switchTitleColor:[UIColor whiteColor]
            infoButtonColor:UIColorFromHex(0xBD0000)
            maxVisibleSwitches:4 // Less than max -> blank space, more than max -> you can scroll!
            menuWidth:250
            menuIcon:@"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"
            menuButton:@"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"];    

    /********************************************************************
        Once menu has been initialized, it will run the setup functions. 
        All of your switches should be entered in the setup() function!
    *********************************************************************/
    setup();
}

// If the menu button doesn't show up; Change the timer to a bigger amount.
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
  timer(5) {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];

    SCLTextView *keyField = [alert addTextField:NSSENCRYPT("Key")];
    keyField.text = @"1";
    keyField.textAlignment = NSTextAlignmentCenter;

    [alert addButton: NSSENCRYPT("Entrar") validationBlock:^BOOL {
      if ([keyField.text isEqualToString:@"1"]) {
        return YES;
      }
      keyField.layer.borderColor = [UIColor redColor].CGColor;
      keyField.layer.borderWidth = 1.0f;
      return NO;
    } actionBlock: ^(void) {
      timer(1) {
        setupMenu();
      });
    }];    

    alert.shouldDismissOnTapOutside = NO;
    alert.customViewColor = [UIColor purpleColor];  
    alert.showAnimationType = SCLAlertViewShowAnimationSlideInFromCenter;   
    
    [alert showSuccess: NSSENCRYPT("RAFA PRO")
            subTitle:NSSENCRYPT("RafaModzYT Is back\n\nIngresa tu Key de acceso:") 
              closeButtonTitle:nil
                duration:99999999.0f];
  });
}


%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}