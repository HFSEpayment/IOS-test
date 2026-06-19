//
//  InputViewController.swift
//  EpaySDK
//
//  Created by a1pamys on 2/24/20.
//  Copyright © 2020 Алпамыс. All rights reserved.
//

import UIKit
import EpaySDK

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String?
    let expires_in: String?
    let scope: String?
}

class ViewController: UIViewController {

    var environmentType: EnvironmentType! = .prod
    var isRecurrent = true
    var autoPaymentFrequency: AutoPaymentFrequency = .weekly
    private var transferType: TransferType?
    private let transfers = TransferType.allCases
    private var senderCard: CardInfo?
    private var receiverCard: CardInfo?
    private var masterPass: MasterPassData?
    
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.backgroundColor = .clear
        if #available(iOS 11.0, *) {
            v.contentInsetAdjustmentBehavior = .never
        }
        return v
    }()
    
    private lazy var stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.backgroundColor = .clear
        v.spacing = 8
        v.distribution = .fill
        v.alignment = .fill
        return v
    }()
    
    lazy var environmentSegmentedControl: UISegmentedControl = {
        let v = UISegmentedControl(items: ["PROD", "PREPROD", "DEV"])
        v.selectedSegmentIndex = 0
        v.backgroundColor = .green
        if #available(iOS 13.0, *) {
            v.selectedSegmentTintColor = .white
        } else {
            v.tintColor = .white
        }
        v.addTarget(self, action: #selector(setEnvironment), for: .valueChanged)
        return v
    }()
    
    lazy var isRecurrentSegmentedControl: UISegmentedControl = {
        let v = UISegmentedControl(items: ["Recurrent", "Non-recurrent"])
        v.selectedSegmentIndex = 0
        v.backgroundColor = .green
        if #available(iOS 13.0, *) {
            v.selectedSegmentTintColor = .white
        } else {
            v.tintColor = .white
        }
        v.addTarget(self, action: #selector(setRecurrentPaymentType), for: .valueChanged)
        return v
    }()
    
    lazy var autoPaymentTypeSegmentedControl: UISegmentedControl = {
        let v = UISegmentedControl(items: ["Weekly", "Monthly", "Quaterly"])
        v.selectedSegmentIndex = 0
        v.backgroundColor = .green
        if #available(iOS 13.0, *) {
            v.selectedSegmentTintColor = .white
        } else {
            v.tintColor = .white
        }
        v.addTarget(self, action: #selector(setAutoPaymentType(sender:)), for: .valueChanged)
        return v
    }()

    lazy var p2pTransferSegmentControl: UISegmentedControl = {
        let items = transfers.compactMap { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = -1
        control.backgroundColor = .green
        if #available(iOS 13.0, *) {
            control.selectedSegmentTintColor = .white
        } else {
            control.tintColor = .white
        }
        control.addTarget(self, action: #selector(p2pSegmentControlValueChanged), for: .valueChanged)
        return control
    }()
    
    lazy var invoiceIdTextField: UITextField = {
        let t = UITextField()
        t.backgroundColor = .white
        t.placeholder = "invoice"
        t.keyboardType = .asciiCapableNumberPad
        t.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        return t
    }()
    
    lazy var amountTextField: UITextField = {
        let t = UITextField()
        t.placeholder = "amount"
        t.text = "18049"
        t.backgroundColor = .white
        t.keyboardType = .asciiCapableNumberPad
        t.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        return t
    }()
    
    lazy var descriptionTextField: UITextField = {
       let t = UITextField()
       t.placeholder = "description"
       t.backgroundColor = .white
       t.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
       return t
    }()
    
    lazy var responseLabel: UILabel = {
        let l = UILabel()
        l.backgroundColor = .white
        l.text = "Response will be displayed here"
        l.numberOfLines = 0
        return l
    }()
    
    lazy var terminalTextField: UITextField = {
        let t = UITextField()
        t.placeholder = "terminal"
        t.text = ""
        t.backgroundColor = .white
        t.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        return t
    }()
    
    lazy var button: UIButton = {
        let b = UIButton()
        b.setTitle("Pay with SDK", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        b.backgroundColor = .red
        b.isEnabled = false
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSdkResponse), name: Notification.Name("sdk_response"), object: nil)
        
        setupNavigatonBarAndMainView()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func setupNavigatonBarAndMainView() {
        self.title = "EpaySDK"
        view.backgroundColor = .lightGray
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(responseLabel)
        stackView.addArrangedSubview(invoiceIdTextField)
        stackView.addArrangedSubview(amountTextField)
        stackView.addArrangedSubview(descriptionTextField)
        stackView.addArrangedSubview(terminalTextField)
        stackView.addArrangedSubview(environmentSegmentedControl)
        stackView.addArrangedSubview(isRecurrentSegmentedControl)
        stackView.addArrangedSubview(autoPaymentTypeSegmentedControl)
        stackView.addArrangedSubview(p2pTransferSegmentControl)
    }
    
    func setupConstraints() {
        
        if #available(iOS 11.0, *) {
            scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, left: view.leftAnchor, bottom: view.bottomAnchor)
        } else {
            scrollView.anchor(top: view.topAnchor, right: view.rightAnchor, left: view.leftAnchor, bottom: view.bottomAnchor)
        }
        
        stackView.anchor(top: scrollView.topAnchor, right: scrollView.rightAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, width: view.frame.width)
        
        invoiceIdTextField.anchor(height: 40)
        amountTextField.anchor(height: 40)
        descriptionTextField.anchor(height: 40)
        terminalTextField.anchor(height: 40)
    }
    
    private func getToken(
        invoiceId: String,
        amount: Double,
        terminal: String,
        completion: @escaping (String?) -> Void
    ) {
        guard let url = URL(string: "https://epay-oauth.homebank.kz/oauth2/token") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        let params = [
            "grant_type": "client_credentials",
            "scope": "payment usermanagement",
            "client_id": "",
            "client_secret": "",
            "invoiceID": invoiceId,
            "amount": String(Int(amount)),
            "currency": "KZT",
            "terminal": terminal,
            "is_credit": "N"
        ]

        request.httpBody = params
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("Token error:", error)
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(
                    TokenResponse.self,
                    from: data
                )

                completion(tokenResponse.access_token)

            } catch {
                print(
                    "Token response:",
                    String(data: data, encoding: .utf8) ?? ""
                )
                completion(nil)
            }
        }
        .resume()
    }
    
    @objc func handleButton() {

        invoiceIdTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        

        let amount = Double(amountTextField.text!)!
        let invoiceId = invoiceIdTextField.text!
        let description = descriptionTextField.text!.isEmpty ? "Оплата в интернет магазине" : descriptionTextField.text!
        let terminal = terminalTextField.text!

        let invoice = Invoice(
            id: invoiceId,
            amount: amount,
            currency: "KZT",
            accountId: "uuid000001",
            description: description,
            terminal: terminal,
            postLink: "https://testmerchant/order/1123",
            failurePostLink: "https://testmerchant/order/1123/fail",
            isRecurrent: isRecurrent,
            autoPaymentFrequency: autoPaymentFrequency,
            transferType: transferType,
            sender: senderCard,
            receiver: receiverCard,
            selfCert: true,
            isApplePay: true
        )

        getToken(
            invoiceId: invoiceId,
            amount: amount,
            terminal: terminal
        ) { [weak self] token in

            guard let self = self else { return }

            guard let token = token else {
                DispatchQueue.main.async {
                    self.responseLabel.text = "Не удалось получить токен"
                }
                return
            }

            DispatchQueue.main.async {

                let authConfig = AuthConfig(
                    merchantName: "UberFlower",
                    appClipToken: token,
                    appleMerchantId: "merchant"
                )

                let pm = PaymentModel(
                    authConfig: authConfig,
                    invoice: invoice
                )

                let launchScreenVC = LaunchScreenViewController(
                    paymentModel: pm
                )

                launchScreenVC.setEnvironmetType(
                    type: self.environmentType
                )

                self.navigationController?.pushViewController(
                    launchScreenVC,
                    animated: true
                )
            }
        }
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        
        guard
            let invoiceId = invoiceIdTextField.text, !invoiceId.isEmpty,
            let amount = amountTextField.text, !amount.isEmpty,
            let description = descriptionTextField.text,
            let terminal = terminalTextField.text, !terminal.isEmpty
            else
        {
            self.button.isEnabled = false
            self.button.backgroundColor = .red
            return
        }
        self.button.isEnabled = true
        self.button.backgroundColor = .black
    }
    
    @objc func handleSdkResponse(_ notification: Notification) {
        navigationController?.popToViewController(self, animated: true)
        let isSuccessful = notification.userInfo?["isSuccessful"] as? Bool
        if isSuccessful == true {
            if transferType == nil {
                let reference = notification.userInfo?["paymentReference"] as? String
                let cardID = notification.userInfo?["cardID"] as? String
                responseLabel.text = "Payment was successful\nReference number: \(reference ?? "-1")\nCard id: \(cardID ?? "-1")"
            } else {
                let reference = notification.userInfo?["transferReference"] as? String
                responseLabel.text = "Transfer was successful\nReference number: \(reference ?? "-1")\n"
            }
        } else {
            let errorCode = notification.userInfo?["errorCode"] as? Int
            let errorMessage = notification.userInfo?["errorMessage"] as? String
            responseLabel.text = "Failed\nError: \(errorCode ?? -1)\nMessage: \(errorMessage ?? "-1")"
        }
    }
    
    @objc func setEnvironment(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            environmentType = .prod
        case 1:
            environmentType = .preProd
        default:
            environmentType = .dev
        }
    }
    
    @objc func setRecurrentPaymentType(sender: UISegmentedControl) {
        isRecurrent = sender.selectedSegmentIndex == 0
    }
    
    @objc func setAutoPaymentType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            autoPaymentFrequency = .weekly
        case 1:
            autoPaymentFrequency = .monthly
        default:
            autoPaymentFrequency = .quarterly
        }
    }

    @objc private func p2pSegmentControlValueChanged() {
        transferType = transfers[p2pTransferSegmentControl.selectedSegmentIndex]

        if transferType == .CardId {
            senderCard = CardInfo(cardCred: "", cardNumber: "440563...5096", payerName: "John Johnson")
            receiverCard = CardInfo(cardCred: "", cardNumber: "400303...9821", payerName: "")
        } else if transferType == .masterPass {
            masterPass = MasterPassData(
                token: "",
                merchantName: "KcellEpay",
                session: "",
                isClientParticipation: true,
                isVisible: true,
                masterPassAction: MasterPassAction(SaveCard: true, updateSaveCard: false, recurring: false))
        }else {
            senderCard = nil
            receiverCard = nil
        }
    }
}
