//
//  BoxofficeViewController.swift
//  BoxOffice
//
//  Created by kakao on 2023/01/31.
//

import UIKit

class BoxofficeViewController: UIViewController {
    enum ViewMode {
        case list
        case item
    }
    private let movieService: MovieService
    
    private var collectionView: UICollectionView!
    private var boxofficeDataSource: UICollectionViewDiffableDataSource<Int, BoxofficeRecode>?
    private var boxofficeSnapshot = NSDiffableDataSourceSnapshot<Int, BoxofficeRecode>()
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView()
    private var dateSelectionBarbuttonItem: UIBarButtonItem!
    private var viewMode: ViewMode = .item
    private var date: Date = .yesterday {
        didSet {
            self.fetchBoxOffice(for: date)
        }
    }
    
    init(movieService: MovieService) {
        self.movieService = movieService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.configureCollectionView()
        self.boxofficeDataSource = self.createDataSource()
        self.configureSnapshot()
        self.configureHierarchy()
        self.configureConstraint()
        self.configureDateSelectionBarButtonItem()
        self.configureNavigationBar()
        self.configureRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchBoxOffice(for: self.date)
    }

    private func configureHierarchy() {
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.loadingIndicator)
    }
    
    private func configureConstraint() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
        ])
    }
    private func configureNavigationBar() {
        self.navigationItem.rightBarButtonItem = self.dateSelectionBarbuttonItem
    }
    }

    private func configureCollectionView() {
        let layout = self.createCollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        self.collectionView = collectionView
        self.collectionView.delegate = self
    }
    
    private func configureRefreshControl() {
        self.collectionView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func configureDateSelectionBarButtonItem() {
        self.dateSelectionBarbuttonItem = UIBarButtonItem(
            title: "날짜선택",
            style: .plain,
            target: self,
            action: #selector(presentCalenderView)
        )
    }
    
    @objc
    private func presentCalenderView() {
        let dateSelectionViewController = DateSelectionViewController(date: self.date)
        dateSelectionViewController.dateSelectionDelegate = self
        self.present(dateSelectionViewController, animated: true)
    }
    
    @objc
    private func refresh() {
        self.fetchBoxOffice(for: self.date)
    }

    private func configureSnapshot() {
        self.boxofficeSnapshot.appendSections([0])
    }
    
    private func updateSnapshot(items: [BoxofficeRecode]) {
        let currentItems = self.boxofficeSnapshot.itemIdentifiers(inSection: 0)
        self.boxofficeSnapshot.deleteItems(currentItems)
        self.boxofficeDataSource?.apply(self.boxofficeSnapshot)
        self.boxofficeSnapshot.appendItems(items, toSection: 0)
        self.boxofficeDataSource?.apply(self.boxofficeSnapshot)
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, BoxofficeRecode> {
        let listCellRegistration = self.createListCellRegistration()
        let itemCellRegistration = self.createItemCellRegistration()
        return UICollectionViewDiffableDataSource(
            collectionView: self.collectionView
        ) { collectionView, indexPath, itemIdentifier in
            switch self.viewMode {
            case .item:
                return collectionView.dequeueConfiguredReusableCell(
                    using: itemCellRegistration,
                    for: indexPath,
                    item: itemIdentifier
                )
            case .list:
                return collectionView.dequeueConfiguredReusableCell(
                    using: listCellRegistration,
                    for: indexPath,
                    item: itemIdentifier
                )
            }
        }
    }
    
    private func createListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, BoxofficeRecode> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, BoxofficeRecode> { cell, indexPath, itemIdentifier in
            var configuration = BoxofficeListContentView.Configuration()

            configuration.recode = itemIdentifier
            
            cell.contentConfiguration = configuration
        }
    }
    
    private func createItemCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, BoxofficeRecode> {
        return UICollectionView.CellRegistration<UICollectionViewCell, BoxofficeRecode> { cell, indexPath, itemIdentifier in
            var configuration = BoxofficeItemContentView.Configuration()

            configuration.recode = itemIdentifier
            
            cell.contentConfiguration = configuration
        }
    }
    
    private func createCollectionViewListLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = true
        configuration.backgroundColor = .white
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
    
    private func createCollectionViewItemLayout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 10

        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { _, _ in
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 5)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .absolute(200)
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    repeatingSubitem: item,
                    count: 2
                )
                group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 10)

                let section = NSCollectionLayoutSection(group: group)

                return section
            },
            configuration: configuration
        )

        return layout
    }
    
    private func fetchBoxOffice(for date: Date) {
        self.collectionView.refreshControl?.beginRefreshing()
        self.movieService.fetchBoxoffice(
            date: date,
            itemPerPage: nil,
            movieType: nil,
            nationType: nil,
            areaCode: nil
        ) { result in
            switch result {
            case .success(let boxoffice):
                DispatchQueue.main.async {
                    self.title = DateFormatter.yearMonthDayWithDash.string(from: boxoffice.date)
                    self.updateSnapshot(items: boxoffice.boxofficeRecodes)
                    self.collectionView.refreshControl?.endRefreshing()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension BoxofficeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.boxofficeDataSource?.itemIdentifier(for: indexPath)
        guard let movieCode = item?.movieCode,
              let movieTitle = item?.movieName
        else {
            return
        }
        let imageService = DefaultImageService()
        let movieDetailViewController = MovieDetailViewController(
            movieDetailConstructor: .init(
                movieService: self.movieService,
                imageService: imageService,
                movieCode: movieCode,
                movieTitle: movieTitle
            )
        )
        self.navigationController?.pushViewController(movieDetailViewController, animated: true)
    }
}

extension BoxofficeViewController: DateSelectionDelegate {
    func dateSelection(_ date: Date) {
        self.date = date
    }
}

fileprivate extension Date {
    static var yesterday: Date {
        return Date() - 24 * 3600
    }
}
