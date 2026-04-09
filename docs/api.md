# Roku
Configuration guide for the Recurly Engage Roku SDK, which enables native prompt display and usage tracking in your Roku applications.

## Overview
The Recurly Engage Roku SDK provides the ability to monitor consumption and show configured prompts within your native Roku app. The SDK automatically handles prompt display and user-triggered events.

### Key benefits
Seamless integration: Easily add prompt functionality to your Roku apps via the Roku SceneGraph SDK.
Automatic event handling: Built-in support for prompt display, button clicks, and lifecycle events without extra UI code.
Flexible triggers: Activate prompts by screen name or button click to fit your application flow.

## Install the SDK
Download the latest Roku SDK (v1.0.36) with Roku Pay support here and without Roku Pay support here. A demo app featuring an example integration can be provided by request.

To build a project using the RedFast SDK for Roku, your project must have been built with the Scenegraph SDK. Unzip the SDK into the app components directory.

## Initialize SDK
1. Initialize the SDK within the main scene XML (initial screen) file.

```xml
 < PromotionManager id="promoMgr" />
```

2. Within the main scene BrightScript (.brs) file, add the following lines into the sub init() function and specify the values for the appId and userId. The userId may be changed later on.

```brightscript
sub init()
  ' other app initialization code here

  ' optionally specify cta-button and timer countdown fonts
  ctaF = CreateObject("roSGNode", "Font")
  ctaF.uri = "pkg:/fonts/Roboto-Regular.ttf"
  ctaF.size = 16
  timeoutF = CreateObject("roSGNode", "Font")
  timeoutF.uri = "pkg:/fonts/Roboto-Regular.ttf"
  timeoutF.size = 16

  m.promoMgr = m.top.GetScene().findNode("promoMgr") ' or m.top.findNode("promoMgr")
  print m.promoMgr.callFunc("getVersion") ' lookup current SDK version
  m.promoMgr.observeField("result", "onInitialized")
  ' appId argument is required, all others are optional
  m.promoMgr.callFunc("initPromotion", {appId: "[YOUR APP ID]", userId: "[USER ID]", annonymousUserId: "[ANON USER ID]", ctaFont: ctaF, timeoutFont: timeoutF})
end sub

sub onInitialized()
  m.promoMgr.unobserveField("result")
  m.sceneStack = m.top.findNode("sceneStack")
  scene = createObject("RoSGNode", "[YOUR FIRST SCREEN OF THE APP]")
  m.sceneStack.appendChild(scene)
end sub
```

Note that it may take a few seconds after app start for the SDK initialization to complete, after which prompts will be available to present to the user.

## Set UserId
You may change the userId after the SDK has been initialized. The function will return instantly, however all prompts relevant to the updated userId may take a few seconds to be ready.

```brightscript
m.promoMgr.callFunc("setUserId", {userId: "[new user id]"})
```

## Set AnonymousUserId
The anonymousUserId may be updated after the SDK has been initialized. If not set, a randomly generated UUID will be assigned to the user.

```brightscript
m.promoMgr.callFunc("setAnonymousUserId", {userId: "[new anon user id]"})
```

## Supported prompt types

| Prompt type | Enum value |
| --- | --- |
| Modal | 2 |
| Horizontal | 5 |
| Video | 6 |
| Interstitial | 10 |
| Bottom banner | 13 |

## Trigger modal via screen name
You may utilize the Redfast SDK to display a modal on a specified screen. If the prompt also requires a button click, the trigger will not occur until the associated onButtonClicked function is called.

Add the following line in the screen init function:

```brightscript
sub init()
  ...
  m.promoMgr = m.top.GetScene().findNode("promoMgr")
  // Make sure a callback function is registed (and registed for only once) here to receive any status from m.promoMgr
  // A sample onPromotionEvent is provided in the next section
  m.promoMgr.observeField("result", "onPromotionEvent")
  m.promoMgr.callFunc("onScreenChanged", {root: m.viewRoot, screenName: "ViewController" })
  ...
end sub
```

Ensure that you add an event listener before calling any function on m.promoMgr so that you can observe the result from a screen change, button click, popup and inline item:

```brightscript
  m.promoMgr.observeField("result", "onPromotionEvent")
```

## Trigger modal via button click
The sample code below demonstrates:

1. Tracking a button click event
2. Displaying a modal if applicable to the button.

Note that a previous onScreenChanged call is required if the prompt trigger is configured to be invoked only when the button click occurs on a specified screen name.

```brightscript
sub onButtonClicked()
  m.promoMgr.callFunc("onButtonClicked", {root: m.viewRoot 'the root component of the screen, id: "[Optional button ID]"}) 
end sub
                                          
'Note: If the prompt is displayed and dismissed, the result will be passed back to:
sub onModalDismissed()
  if m.promoMgr.result.value = 101 'button1
    dialog = createObject("roSGNode", "Dialog")
    dialog.title = "Thank you"
    dialog.optionsDialog = true
    dialog.message = "Thanks for accepting"
    m.top.dialog = dialog
  end if
end sub

' Note: The full set of status codes can be found in the SDK `const.brs` file:
' Success codes
m.ok = 1

' Error codes
m.error = -100
m.notApplicable = -101
m.disabled = -102
m.suppressed = -103

' Interactions
m.impression = 100
m.button1 = 101
m.button2 = 102
m.button3 = 103
m.dismissed = 110
m.timerExpired = 111
m.holdout = 120
```

## Show modal via manual trigger
A prompt may triggered manually if triggering via Screen Name or Button Click is not desired.

```brightscript 
prompt = m.promoMgr.callFunc("getPrompt", {pathId: "myPathId"})
m.promoMgr.callFunc("showPrompt", {root: m.viewRoot, prompt: prompt})
```

## Show inline prompt
An eligible inline prompt can be rendered within a Scenegraph node. We recommend defining a Rectangle or Poster node as a container for the inline prompt. The scale argument determines how the inline prompt will scale to fit within the allocated space of the specified node.

```brightscript
' -- Scenegraph component file (.xml) --
<Rectangle id="myBanner" width="1920" height="420" />
  
' -- Brightscript file (.brs) --

' showInline Args:
'   root: parent node
'   type: Zone ID
'   scale: "scaleToFit", "scaleToFill", "scaleToZoom", "noScale"
m.inline = m.promoMgr.callFunc("showInline", {root: m.myBanner, type: "myZoneId", scale: "scaleToFill"
})
' Observe Prompt Interactions
if m.inline <> invalid
  m.inline.observeField("result", "onInlineResult")
end if
```

## Retrieve inline prompts
For custom rendering, the SDK provides a method to retrieve inline prompts within the specified Zone ID that are eligible for the current userId. You may access the properties of the inline prompts to render in the appropriate locations within the app.

```brightscript
inlineItems = m.promoMgr.callFunc("getInlines", {type: "myZoneId"})
```

The following is example code demonstrating accessing attributes of the prompt for rendering within a new child node. A full list of attributes can be found here.

```brightscript
featured = createObject("RoSGNode", "ContentNode")
di = CreateObject("roDeviceInfo")
displaySize = di.GetDisplaySize()
for ii = 0 To inlineItems.count() - 1
    item = featured.createChild("ContentNode")
    inlineItem = inlineItems[ii]
    heightSuffix = ""
    if displaySize.h = 480
        heightSuffix = "&screen_size=480"
    else if displaySize.h = 720
        heightSuffix = "&screen_size=720"
    end if
    item.HDPOSTERURL = inlineItem.actions.rf_settings_bg_image_roku_os_tv_composite + heightSuffix
end for
featured.title = "Featured"
contentNode.insertChild(featured, 2)
```

Note: prompt interactions for inline prompts must be reported within your application code.

```brightscript
' Report impression when inline prompt is viewed
promoMgr.onInlineViewed(inlineItem)

' Report click
promoMgr.onInlineClicked(inlineItem)

' Report dismiss
promoMgr.onInlineDismissed(inlineItem)
```

## Respond to prompt interactions
A PromptResult object is returned upon any prompt interaction performed by the user.

The PromptResult schema includes the following properties:

- code: Interaction code (ex: 100 for impression, 101 for button1 click)
- meta: Device Metadata specified within the prompt
- promptMeta
    - promptName
    - promptID
    - promptType
    - promptVariationName
    - promptVariationID
    - promptExperimentName
    - promptExperimentID
    - buttonLabel

```brightscript
' Observe Prompt Interactions
m.promoMgr.observeField("result", "onPromptResult")

' Perform actions on resulting interaction
sub onPromptResult()
		' Call custom sendAnalytics() function
    sendAnalytics(m.promoMgr.result)

		' Kick off Roku Pay flow for specified SKU if specified
    if  m.promoMgr.result.roku <> invalid and m.promoMgr.result.roku <> ""
        m.promoMgr.callFunc("purchaseIap", {sku: m.promoMgr.result.roku, qty: 1})
    else
        if m.modal.visible
            m.detail.setFocus(true)
        else
            m.home.setFocus(true)
        end if
    end if
end sub
```

## Send usage tracking event
Your app can report custom tracker events through the SDK. If configured as a tracker within Pulse, these custom events can be used to target prompts at specific sets of users. The custom tracker must first be created within the Redfast console so that the customFieldId value may be retrieved.

```brightscript
m.promoMgr.callFunc("customTrack", {customFieldId: "my-usage-event"})
```

## Deep link to a media asset
Invoke the Roku app deep linking functionality by specifying the mediaType and contentId for the prompt in the Redfast console. When the user invokes the CTA on the prompt, you may utilize these parameters to send the user to a specific media asset within the app. The following is an example on how to invoke deep linking after the user invokes the call to action.

```brightscript
sub onPromotionEvent()
  if m.promoMgr.result.value = 0 // m.accepted from `const.brs` file
    deeplink = m.promoMgr.result.extra.deeplink
    [your deeplink handler function](deeplink)
  end if
end sub
```

## Access device metadata
Device key-value pair metadata can be added to an Prompt via the Redfast console. The app will receive these values per the examples below. These values may be used to perform an action that is not the typical media asset deep link, like sending the user to a registration screen.

## Popup
When a popup is dismissed by either an Accept, Decline, or Timeout action by the user, the custom metadata will be saved in the extra.meta field.

```brightscript
sub onPromotionEvent()
  metadata = m.promoMgr.result.extra.meta
end sub
```

## Inline item
When the onInlineClicked API is invoked with the current selected inline item:

```brightscript
sub onPromotionEvent()
  metadata = m.promoMgr.result.extra.meta
end sub
```

## Disable SDK
There may be cases in which the Redfast SDK should be temporarily disabled for the current session. When disabled, popups are not triggered, and API communication between the SDK and Redfast servers are paused.

```brightscript 
// To disable
m.promoMgr.callFunc("enablePromotion", {enabled: false})

// To re-enable
m.promoMgr.callFunc("enablePromotion", {enabled: true})
```

## Debug view
The SDK provides a debug view modal in which you can use the onscreen keyboard to either reset all prompts for the current user or set a new userId.

To trigger the debug view for a specific screen, add the DebugView component and connect it to a local variable on the screen,

```xml
<DebugView id="debugView" />
```

```brightscript
m.debugView = m.top.findNode("debugView")
```

In the screen's onKeyEvent function:

```brightscript
m.debugView.callFunc("onKeyDetection", {key: key, screen: m.top})
```

When the * key on the remote control is pressed, the debug view will be displayed.

