# BeaconTag-iOS-SDK project
-----------------------------

Welcome to BeaconTag-iOS-SDK project for iPhone, designed to help you test the BeaconTag SDK.
BeaconTag-iOS-SDK is an iOS library with a sample app to set, configure and interact with the connected devices 'Orange Beacon Tag' by Orange.

Please start with the sample associated and modify the different characteristics according to your use cases and your Orange Beacon Tag: #warning in ViewController.m. 
The Orange Beacon Tag can be bought on store.orange.beacon.fr. 
The sample allows you to display messages on your phone in your beacon's vicinity. Other use cases might be to trigger different phone actions, such as sending an SMS or automatically opening a mobile application. To discover more possible beacon's interactions with your phone, do not hesitate to test our mobile app: "Beacon Connect".

We'd love to hear your feedback/comments.
Thank you in advance for your time.

Beacon Tag SDK:
---------------
Document revision 4 (SDK v 1.1.2)

-----------------------------------------------------------------------------------------
Legal notice:

ORANGE OFFERS NO WARRANTY EITHER EXPRESS OR IMPLIED INCLUDING THOSE OF MERCHANTABILITY,
NONINFRINGEMENT OF THIRD-PARTY INTELLECTUAL PROPERTY OR FITNESS FOR A PARTICULAR PURPOSE.
ORANGE SHALL NOT BE LIABLE FOR ANY DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION,
DAMAGES FOR LOSS OF BUSINESS PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION,
OR OTHER LOSS) ARISING OUT OF THE USE OF OR INABILITY TO USE THE SAMPLE CODE, 
EVEN IF ORANGE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

-----------------------------------------------------------------------------------------

Notes re: Xcode project:

This project is compatible with iOS 7, 8 and 9 versions.


Sample app: beaconTagSDK_DemoApp
--------------------
This sample app offers you to configure your Orange Beacon Tag. 
To quickly be back on track you can just edit the code of '' 
with the UUID, major and minor of your Orange Beacon Tag (OBT). 
You can also configure the service you want to test (entering or leaving the Orange Beacon Tag area for example)
and edit its parameters (typically, the transmission power or the accelerometer value).

To have the configuration of your Orange Beacon Tag updated, you need to build and open the app
on a compatible smartphone. Then, press down the small button located at the back 
of your Orange Beacon Tag, putting it into configuration mode. During this configuration mode, 
a blue light will flash during a few moments and you should see the UUID of your OBT displayed on your phone screen preceded by the word 'configured'. 
Then, you can test the service by moving it (if you chose the accelerometer mode), leaving or entering 
the OBT interaction zone or even changing the OBT triggering temperature threshold. The according OBT's UUID will then be displayed preceded by the word 'triggered'.


Library integration:
--------------------
BeaconTag framework requires iOS 7.0 or later as a target platform. For proper functioning of this library you must follow the following steps:

1. In the host app target build settings turn on linking with CoreLocation and CoreBluetooth frameworks.

2. In the host app target build settings add custom linker flag `-ObjC`.

3. In the host app target Info.plist file add appropriate value for the `NSLocationAlwaysUsageDescription` key.

Using the library:
------------------
BeaconTag library has a default instance with access method `+sharedInstance`, but you are welcome to create your own instance manually using `[[BeaconTagSDK alloc] init]`. The default/shared instance is automatically initialized on the first use. 

After an instance is created, you are expected to set a delegate (`@property delegate`), which will receive callbacks on successful BeaconTag configuration and when an action is triggered.

Before starting the library, you must set BeaconTag UUID/major/minor. Library instance will react only for this device, and will configure only device with matching identifiers.  

By default the library is not started. To start/stop listening for Orange Beacon Tags you call the `-start`/`-stop` methods. If you want to change the UUID/major/minor of the Beacon Tag to which the library instance is bounded, you should restart the library.

You must call `-start`/`-stop` methods from the main thread. All the callbacks are fired on main thread too. 

On iOS8 devices, you must enable localisation services.


BeaconTag configuration:
------------------------
To trigger actions as you wish, the Orange Beacon Tag must be properly configured. After the device is configured, you can use it until the configuration is updated. In case you want to configure a device, you should proceed with the following steps:

1. Set all the necessary configuration values.

2. Enable configuration mode for the library instance.

3. Turn on configuration mode of the device by pressing a button.

4. Wait until configuration is finished.

Configuration mode is turned on by setting the `configurationModeEnabled` property to YES. Regardless of this flag, while library instance is not started, it will not connect to a Beacon Tag. You can change `configurationModeEnabled` value before or after starting the library instance.

After the configuration is successfully finished, configuration mode is toggled to NO automatically. If you want to upload a configuration once again, or update the existing configuration, you set all the necessary configuration values and after that re-enable the configuration mode. After the configuration is successfully finished, delegate method `-beaconTagConfiguredInBeaconTag:` is called. This callback is optional and can be left unimplemented.  


Configuration parameters:
-------------------------
#### `beaconTagUUID`

* **Required**: YES

* **Valid values**: [RFC 4122](https://www.ietf.org/rfc/rfc4122.txt) 32-character hex UUID. Use `[[NSUUID alloc] initWithUUIDString:uuidString]`.

* **Default value**: NA

#### `beaconTagMajor`

* **Required**: YES

* **Valid values**: 0..65536 integer

* **Default value**: NA

#### `beaconTagMinor`

* **Required**: YES

* **Valid values**: 0..65536 integer

* **Default value**: NA

[Major and minors can be found written behind your Orange Beacon Tag. Do be careful of converting Major and Minor to decimal values.]

#### `txPower`

* **Required**: YES

* **Description**: Orange Beacon Tag transmitting power in dBm.

* **Valid values**:  
`beaconTagTxPower_minus_62`,  
`beaconTagTxPower_minus_52`,  
`beaconTagTxPower_minus_48`,  
`beaconTagTxPower_minus_44`,  
`beaconTagTxPower_minus_40`,  
`beaconTagTxPower_minus_36`,  
`beaconTagTxPower_minus_32`,  
`beaconTagTxPower_minus_30`,  
`beaconTagTxPower_minus_20`,  
`beaconTagTxPower_minus_16`,  
`beaconTagTxPower_minus_12`,  
`beaconTagTxPower_minus_8`,  
`beaconTagTxPower_minus_4`,  
`beaconTagTxPower_0`,  
`beaconTagTxPower_plus_4`  
(discrete values in dBm)

* **Default value**: `beaconTagTxPower_0` 

#### `advertisingInterval`

* **Required**: YES

* **Description**: Orange Beacon Tag advertising interval, the higher the less precise.

* **Valid values**: 160..16000 integer (in units of 625 µs)

* **Default value**: 160<br/>(160 x 625 µs = 100 ms)

#### `workflowConditionType`

* **Required**: YES

* **Description**: Orange Beacon Tag event condition types: when phone is entering/leaving the Orange Beacon Tag area, when approaching phone of an object, if the Orange Beacon Tag is moved or if a given temperature threshold has been crossed.

* **Valid values**:  
`workflowConditionTypeEnterRegion`,      
`workflowConditionTypeLeaveRegion`,  
`workflowConditionTypeEnterAndLeaveRegion`,  
`workflowConditionTypeTouchAnObject`,  
`workflowConditionTypeMovement`,       
`workflowConditionTypeTemperature`  
(enum value)

* **Default value**: `workflowConditionTypeEnterRegion`

#### `sleepDelay`

* **Required**: Only for conditional workflows (`workflowConditionTypeMovement`, `workflowConditionTypeTemperature`)

* **Description**: After Orange Beacon Tag activation because of acceleration or temperature events, the device will 'advertise' for a given period of time, then it will be deactivated. If sleep delay not within the provided range it will be set to 0.

* **Valid values**: 0 (disabled); 1..65535 integer (in seconds)

* **Default value**: 0 (disabled)

#### `temperatureLowerBoundary`

* **Required**: Only for temperature workflow condition (`workflowConditionTypeTemperature`)

* **Valid values**: -128..127 integer (in ºC) (we highly recommend values from -20 to +50ºC to ensure a smooth functionning of BLE chip)

* **Default value**: 15

#### `temperatureUpperBoundary`

* **Required**: Only for temperature workflow condition (`workflowConditionTypeTemperature`)

* **Valid values**: -128..127 integer (in ºC), value must be greater than or equal to lower boundary (we highly recommend values from -20 to +50ºC to ensure a smooth functionning of BLE chip)

* **Default value**: 25

#### `accelerationWakeLevel`

* **Required**: Only for movement workflow condition (`workflowConditionTypeMovement`)

* **Required**: The Orange Beacon Tag is activated when its acceleration reaches a given value.

* **Valid values**: 0.1569064 .. 156.9064 float (in m/s²)

* **Default value**: 0.980665 m/s²


Triggering actions
--------------------
When configured condition is met, the action is triggered. To react for triggered actions you implement `-triggeredActionForConfiguration:` method. You can show an alert or apply any other custom logic in this method.
