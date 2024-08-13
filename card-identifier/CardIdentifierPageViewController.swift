//
//  ViewController.swift
//  card-identifier
//
//  Created by Zeynep Nur Altın on 4.08.2024.
//

import Vision
import UIKit

class CardIdentifierPageViewController: UIViewController {
    
    struct CardDetails {
        var cardNumber: String?
        var name: String?
        var expiryDate: String?
        var cvv: String?
    }
    
    private var cardDetails = CardDetails()
    
    private let ignoreList = ["VALID", "THRU", "Ziraat","BANK","BANKA", "BANKASI", "bankkart", "VISA", "troy", "tray", "türkiye", "Finans"]
    
    private let cardNumberLabel = UILabel()
    private let cardOwnerNameLabel = UILabel()
    private let cardExpiryDateLabel = UILabel()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "example1")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cardNumberLabel)
        view.addSubview(imageView)
        view.addSubview(cardOwnerNameLabel)
        view.addSubview(cardExpiryDateLabel)
        
        view.backgroundColor = .white
        
        setupLabels()
        
        recognizeText(image: imageView.image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(
            x: 20,
            y: view.safeAreaInsets.top,
            width: view.frame.size.width-40,
            height: view.frame.size.width-40)
        cardNumberLabel.frame = CGRect(
            x: 20,
            y: imageView.frame.maxY + 40,
            width: view.frame.size.width-40,
            height: 50)
        cardOwnerNameLabel.frame = CGRect(
            x: 20,
            y: cardNumberLabel.frame.maxY+2,
            width: view.frame.size.width-40,
            height: 50)
        cardExpiryDateLabel.frame = CGRect(
            x: 20,
            y: cardOwnerNameLabel.frame.maxY+2,
            width: view.frame.size.width-40,
            height: 50)
    }
    
    private func setupLabels() {
        setupLabel(cardNumberLabel, withText: "Kart numarası: ")
        setupLabel(cardOwnerNameLabel, withText: "Kart sahibi: ")
        setupLabel(cardExpiryDateLabel, withText: "SKT: ")
    }

    private func setupLabel(_ label: UILabel, withText text: String) {
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .white
        label.textColor = .black
        label.text = text
    }
    
    func recognizeText(image: UIImage?){
        guard let cgImage = image?.cgImage else {
            fatalError("Error: Could not get cgImage.")
        }
        
        //Handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [ : ])
        
        //Request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                    return
            }
            for observation in observations {
                guard let recognizedText = observation.topCandidates(1).first?.string else { continue }
                print("Recognized text: \(recognizedText)")
                if recognizedText.range(of: #"^\d{4} \d{4} \d{4} \d{4}$"#, options: .regularExpression) != nil, self?.cardDetails.cardNumber == nil {
                    self?.cardNumberLabel.text? += "\(recognizedText)"
                    self?.cardDetails.cardNumber = recognizedText
                    print("**Kart numarası: \(self?.cardDetails.cardNumber ?? "")")
                }
                else if self?.cardDetails.name == nil,
                        !(self?.ignoreList.contains(where: recognizedText.contains))!,
                    recognizedText.range(of: #"^[A-Z]{2,}\s+[A-Z]{2,}(?:\s[A-Z]+)*$"#, options: .regularExpression) != nil {
                        self?.cardOwnerNameLabel.text? += "\(recognizedText)"
                        self?.cardDetails.name = recognizedText
                        print("**Kart sahibi: \(self?.cardDetails.name ?? "")")
                }
                
                else if self?.cardDetails.expiryDate == nil,
                    recognizedText.range(of: #"([A-Z]+:\s)*(0[0-9]|1[0-2])\/([0-4][0-9])"#, options: .regularExpression) != nil {
                    let cleanedText = recognizedText.replacingOccurrences(of:  #"[^0-9/]"#, with: "", options: .regularExpression)
                        self?.cardExpiryDateLabel.text? += "\(cleanedText)"
                        self?.cardDetails.expiryDate = cleanedText
                        print("**Kart SKT: \(self?.cardDetails.expiryDate ?? "")")
                }
                
            }
        }
        
        //Precision value
        request.recognitionLevel = .accurate
        
        //Process request
        do{
            try handler.perform([request])
        }catch{
            cardNumberLabel.text = "\(error)"
        }
    }
}

