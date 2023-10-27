# Halyk Epay iOS SDK

#### Step 1
Import EpaySDK.framework to your project as follows:
1. Do one of the two:
    - Drag and drop EpaySDK.framework to your xCode project
    - Put tick on "Copy items if needed" box  
OR
    - Select "Add Files To #your_project_name#"
    - Select EpaySDK.framework
    - Put tick on "Copy items if needed" box
2. Go to your project target and select tab "General".
3. In the "Framework, Libraries, Embedded Content" section under "Embed" column select "Embed & Sign".

### Step 2
Add the observer to handle response from SDK. 
```bash
NotificationCenter.default.addObserver(self, selector: #selector(handleSdkResponse), name: Notification.Name("sdk_response"), object: nil)
```
Note: the notification name must be "sdk_response", but you can rename the function


#### Step 3
Create function to handle notification (in the step 2 it is given as handleSdkResponse)
The response will be in the form of dictionary as follows:
```bash
[
    isSuccessful: Bool,
    paymentReference: String,
    cardID: String,
    errorCode: Int,
    errorMessage: String
]
```
Example:
```bash
@objc func handleSdkResponse(_ notification: Notification) {
        navigationController?.popToViewController(self, animated: true) // 1
        let isSuccessful = notification.userInfo?["isSuccessful"] as? Bool // 2
        if isSuccessful == true { // 3
            let reference = notification.userInfo?["paymentReference"] as? String
            let cardID = notification.userInfo?["cardID"] as? String
        } else { // 4
            let errorCode = notification.userInfo?["errorCode"] as? Int
            let errorMessage = notification.userInfo?["errorMessage"] as? String
        }
    }
```
1 - quits from SDK  
2 - shows is payment was succesfull or not  
3 - if succesful, gets reference number  
4 - if failed, gets error code and error message  

#### Step 4
Create authorization config instance
```bash
let config = AuthConfig(
                merchantId: {your merchant ID},
                merchantName: {your merchant name},
                clientId: {your client ID,
                clientSecret: {your client secret}
            )
```

#### Step 5
Create invoice instance
```bash
let invoice = Invoice(
                id: {your generated invoice id},
                amount: {payment amount},
                currency: {payment currency}),
                accountId: {user account ID}, 
                description: {payment description}, 
                postLink: {payment success post url}, 
                failurePostLink: {payment failure post url},
                isRecurrent = {boolean for recurrent payment},
                autoPaymentFrequency = {recurrent payment frequency - weeky/monthly/quarterly}
            )
```

Enum AutoPaymentFrequency object for your reference:
```bash
public enum AutoPaymentFrequency: String {
    case weekly = "WEEKLY"
    case monthly = "MONTHLY"
    case quarterly = "QUARTERLY"
}
```
#### Step 6
Create payment model instance and pass your auth config and invoice to it
```bash
let paymentModel = PaymentModel(
                    authConfig: {your auth config from step 4},
                    invoice: {your invoice from step 5}
                )
```

#### Step 7
Create instance of LaunchViewController by passing payment model to its constructor and push the instance created to navigation controller
```bash
let launchScreenVC = LaunchScreenViewController(paymentModel: {your payment model from step 4})
navigationController?.pushViewController(launchScreenVC, animated: true)
```

### Step 8
Await for response. 
When SDK finishes the respond will be handled by the function from step 2
