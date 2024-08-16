//
//  CardIdentifierViewModel.swift
//  card-identifier
//
//  Created by Zeynep Nur Altın
//

import Vision
import UIKit

class CardIdentifierViewModel {
    
    private(set) var cardDetails = CardDetails() {
        didSet {
            updateUI?(cardDetails)
        }
    }
    
    private let ignoreList = ["VALID", "THRU", "BANK", "BANKA", "BANKASI", "bankkart", "VISA", "troy", "tray"]

    var updateUI: ((CardDetails) -> Void)?
    
    var temporaryCardNumber : String = ""

    func recognizeText(in image: UIImage?) {
        resetCardDetails()
        temporaryCardNumber = ""
        print("Processing image for text recognition...")

        guard let cgImage = image?.cgImage else {
            fatalError("Error: Could not get cgImage.")
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                return
            }

            for observation in observations {
                guard let recognizedText = observation.topCandidates(1).first?.string else { continue }
                print("Recognized text: \(recognizedText)")
                self?.processRecognizedText(recognizedText)
            }
        }

        request.recognitionLevel = .accurate

        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error)")
        }
    }
    
    private func processRecognizedText(_ recognizedText: String) {
        // MARK: - Card Number
        //Card number when it formatted XXXX-XXXX-XXXX-XXXX
        if recognizedText.range(of: #"^\d{4} \d{4} \d{4} \d{4}$"#, options: .regularExpression) != nil,
           cardDetails.cardNumber == nil {
            cardDetails.cardNumber = recognizedText
            print("**Kart numarası: ", cardDetails.cardNumber ?? "-")
        }
        
        // MARK: - Card Number Brute Force
        else if recognizedText.range(of: #"^\d{4}$"#, options: .regularExpression) != nil,
           cardDetails.cardNumber == nil {
            temporaryCardNumber += String(recognizedText) + " "
            print(temporaryCardNumber)
            print("! ! Kart numarası ekleniyor... ")
            if temporaryCardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression).count == 16,
               cardDetails.cardNumber == nil {
                cardDetails.cardNumber = temporaryCardNumber.trimmingCharacters(in: .whitespaces)
                print("**Kart numarası: ", cardDetails.cardNumber ?? "-")
            }
        }
        else if recognizedText.range(of: #"^\d{4} \d{4}$"#, options: .regularExpression) != nil,
           cardDetails.cardNumber == nil {
            temporaryCardNumber += String(recognizedText) + " "
            print(temporaryCardNumber)
            print("! ! Kart numarası ekleniyor... ")
            if temporaryCardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression).count == 16,
               cardDetails.cardNumber == nil {
                cardDetails.cardNumber = temporaryCardNumber.trimmingCharacters(in: .whitespaces)
                print("**Kart numarası: ", cardDetails.cardNumber ?? "-")
            }
        }
        // MARK: - Card Owner
        //Card owner name and surname format: XX+ XX++
        else if cardDetails.name == nil,
                  !ignoreList.contains(where: recognizedText.contains),
                  recognizedText.range(of: #"^[A-Z]{2,}\s+[A-Z]{2,}(?:\s[A-Z]+)*$"#, options: .regularExpression) != nil {
            cardDetails.name = recognizedText
            print("**Kart sahibi: ", cardDetails.name ?? "-")
        }
        // MARK: - Valid Thru
        //Valid Thru format: MM/YY
        //If "valid thru" words are detected, clean it.
        else if cardDetails.expiryDate == nil,
                  recognizedText.range(of: #"([A-Z]+:\s)*(0[0-9]|1[0-2])\/([0-9]{2})"#, options: .regularExpression) != nil {
            let cleanedText = recognizedText.replacingOccurrences(of:  #"[^0-9/]"#, with: "", options: .regularExpression)
            cardDetails.expiryDate = cleanedText
            print("**Kart SKT: ", cardDetails.expiryDate ?? "-")
        }
    }

    private func resetCardDetails() {
        cardDetails = CardDetails()
    }
}
