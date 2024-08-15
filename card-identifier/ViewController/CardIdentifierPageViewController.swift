//
//  ViewController.swift
//  card-identifier
//
//  Created by Zeynep Nur Altın on 4.08.2024.
//

import UIKit

class CardIdentifierPageViewController: UIViewController {

    private let viewModel = CardIdentifierViewModel()

    private let cardNumberLabel = UILabel()
    private let cardOwnerNameLabel = UILabel()
    private let cardExpiryDateLabel = UILabel()
    
    // MARK: - ImageView
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "square.and.arrow.down")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        view.addSubview(imageView)
        view.addSubview(cardNumberLabel)
        view.addSubview(cardOwnerNameLabel)
        view.addSubview(cardExpiryDateLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        setupLabels()
    }

    private func setupBindings() {
        viewModel.updateUI = { [weak self] cardDetails in
            self?.updateLabels(with: cardDetails)
        }
    }
    
    @objc private func imageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(
            x: 20,
            y: view.safeAreaInsets.top+100,
            width: view.frame.size.width-40,
            height: 200)
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
    
    private func updateLabels(with cardDetails: CardDetails) {
        cardNumberLabel.text = "Kart numarası: \(cardDetails.cardNumber ?? "")"
        cardOwnerNameLabel.text = "Kart sahibi: \(cardDetails.name ?? "")"
        cardExpiryDateLabel.text = "SKT: \(cardDetails.expiryDate ?? "")"
    }
}

extension CardIdentifierPageViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
                
        if let editedImage = info[.editedImage] as? UIImage {
            imageView.image = editedImage
            viewModel.recognizeText(in: editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            imageView.image = originalImage
            viewModel.recognizeText(in: originalImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
