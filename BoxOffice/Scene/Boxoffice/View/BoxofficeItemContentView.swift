//
//  BoxofficeListContentView.swift
//  BoxOffice
//
//  Created by kakao on 2023/02/01.
//

import UIKit

final class BoxofficeItemContentView: UIView, UIContentView {
    private let rankLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()
    
    private let rankDescriptionLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let audienceLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let mainStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = .init(top: 10, leading: 5, bottom: 10, trailing: 5)
        stackView.layer.borderColor = UIColor.black.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    var configuration: UIContentConfiguration {
        didSet {
            self.configure(self.configuration)
        }
    }
    
    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        self.configureHierarchy()
        self.configureConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configure(_ configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration,
              let rank = configuration.recode?.rank,
              let rankType = configuration.recode?.rankType,
              let title = configuration.recode?.movieName,
              let audienceCount = configuration.recode?.audienceCount,
              let audienceAccumulation = configuration.recode?.audienceAccumulation
        else { return }
        
        self.rankLabel.text = String(rank)
        self.rankDescriptionLabel.attributedText = self.configureRankDescription(
            rankType: rankType
        )
        self.titleLabel.text = title
        self.audienceLabel.text = self.configureAudienceLabel(
            audienceCount: audienceCount,
            audienceAccumulation: audienceAccumulation
        )
    }
    
    private func configureAudienceLabel(audienceCount: Int, audienceAccumulation: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let count = formatter.string(from: audienceCount as NSNumber)
        let accumulation = formatter.string(from: audienceAccumulation as NSNumber)
        return "오늘 \(count ?? "-") / 총 \(accumulation ?? "-")"
    }
    
    private func configureRankDescription(rankType: BoxofficeRecode.RankType) -> NSAttributedString {
        switch rankType {
        case .new:
            self.rankDescriptionLabel.textColor = .red
            return NSAttributedString(string: "신규")
        case .old(let rankInten):
            if rankInten == 0 {
                self.rankDescriptionLabel.textColor = .black
                return NSAttributedString(string: "-")
            } else {
                let imageAttachment = NSTextAttachment()
                let imageConfig = UIImage.SymbolConfiguration(
                    pointSize: 14,
                    weight: .regular,
                    scale: .default
                )
                let imageName = rankInten > 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill"
                let imageColor = rankInten > 0 ? UIColor.red : UIColor.blue
                imageAttachment.image = UIImage(systemName: imageName, withConfiguration: imageConfig)?
                    .withTintColor(imageColor)
                let string = NSMutableAttributedString(string: "")
                string.append(NSAttributedString(attachment: imageAttachment))
                string.append(NSAttributedString(string: "\(abs(rankInten))"))
                return string
            }
        }
    }
    
    private func configureHierarchy() {
        self.addSubview(self.mainStackView)
        self.mainStackView.addArrangedSubview(self.rankLabel)
        self.mainStackView.addArrangedSubview(self.titleLabel)
        self.mainStackView.addArrangedSubview(self.rankDescriptionLabel)
        self.mainStackView.addArrangedSubview(self.audienceLabel)
    }

    private func configureConstraint() {
        NSLayoutConstraint.activate([
            self.mainStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.mainStackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.mainStackView.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
    }
}

extension BoxofficeItemContentView {
    struct Configuration: UIContentConfiguration {
        var recode: BoxofficeRecode?
        
        func makeContentView() -> UIView & UIContentView {
            return BoxofficeItemContentView(configuration: self)
        }
        
        func updated(for state: UIConfigurationState) -> BoxofficeItemContentView.Configuration {
            return self
        }
    }
}
