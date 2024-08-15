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
    
    private let ignoreList = ["VALID", "THRU", "Ziraat","BANK","BANKA", "BANKASI", "bankkart", "VISA", "troy", "tray", "türkiye", "Finans"]

    var updateUI: ((CardDetails) -> Void)?

    func recognizeText(in image: UIImage?) {
        resetCardDetails()

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
        if recognizedText.range(of: #"^\d{4} \d{4} \d{4} \d{4}$"#, options: .regularExpression) != nil,
           cardDetails.cardNumber == nil {
            cardDetails.cardNumber = recognizedText
        } else if cardDetails.name == nil,
                  !ignoreList.contains(where: recognizedText.contains),
                  recognizedText.range(of: #"^[A-Z]{2,}\s+[A-Z]{2,}(?:\s[A-Z]+)*$"#, options: .regularExpression) != nil {
            cardDetails.name = recognizedText
        } else if cardDetails.expiryDate == nil,
                  recognizedText.range(of: #"([A-Z]+:\s)*(0[0-9]|1[0-2])\/([0-9]{2})"#, options: .regularExpression) != nil {
            let cleanedText = recognizedText.replacingOccurrences(of:  #"[^0-9/]"#, with: "", options: .regularExpression)
            cardDetails.expiryDate = cleanedText
        }
    }

    private func resetCardDetails() {
        cardDetails = CardDetails()
    }
}
