//
//  ViewController.swift
//  Triangles in square
//
//  Created by Руслан on 10.09.2022.
//

import UIKit
import ZoomCollectionView

private extension CGFloat {
    static let itemSpacing: CGFloat = 2
}

private extension Int {
    static let initialColumnsCount = 8
}

final class ViewController: UIViewController {

    // MARK: Properties

    private var dataSource: [[UIColor?]] = []
    private var columnsCount = Int.initialColumnsCount {
        didSet {
            setupDataSource()
            if columnsCount != oldValue {
                let layout = createCollectionViewLayout()
                zoomView.layout = layout
                zoomView.collectionView.collectionViewLayout = layout
            }
            zoomView.collectionView.reloadData()
        }
    }
    private let cellId = "cellId"

    // MARK: UI

    // TODO: Идея: добавить два колеса для выбора позиции пустой (белой) клетки
    private lazy var textField: UITextField = {
        let textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let textField = UITextField.textFieldWithInsets(textInsets)
        textField.text = "\(columnsCount)"
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        return textField
    }()
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.setTitle("Сгенерировать", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    private lazy var zoomContainerView = UIView()
    private lazy var zoomView: ZoomCollectionView = {
        let frame = CGRect(origin: .zero, size: zoomContainerView.frame.size)
        let layout = createCollectionViewLayout()
        let zoomView = ZoomCollectionView(frame: frame, layout: layout)
        zoomView.collectionView.dataSource = self
        zoomView.collectionView.register(UICollectionViewCell.self,
                                         forCellWithReuseIdentifier: cellId)
        zoomView.scrollView.maximumZoomScale = 8
        return zoomView
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
    }

    // MARK: Private

    private func createCollectionViewLayout() -> ScalingGridLayout {
        let totalItemSpacing = (CGFloat(columnsCount) - 1) * CGFloat.itemSpacing
        let itemWidth = (zoomContainerView.frame.width - totalItemSpacing) / CGFloat(columnsCount)
        let layout = ScalingGridLayout(
            itemSize: CGSize(width: itemWidth, height: itemWidth),
            columns: CGFloat(columnsCount),
            itemSpacing: CGFloat.itemSpacing,
            scale: 1
        )
        return layout
    }

    private func setupUI() {
        view.backgroundColor = UIColor.white

        view.addSubview(textField)
        let topInset = statusWithNavigationBarsHeight
        let buttonHeight: CGFloat = 40
        let buttonWidth: CGFloat = buttonHeight * 4
        textField.frame = CGRect(x: 5, y: topInset + 5,
                                 width: view.frame.width - buttonWidth - 15,
                                 height: buttonHeight + 5)

        view.addSubview(button)
        button.frame = CGRect(x: textField.frame.maxX + 5, y: topInset + 5,
                              width: buttonWidth, height: buttonHeight + 5)

        view.addSubview(zoomContainerView)
        let frame = CGRect(x: 0, y: textField.frame.maxY + 5,
                           width: view.frame.width,
                           height: view.frame.height - textField.frame.maxY - 5)
        zoomContainerView.frame = frame
        zoomContainerView.addSubview(zoomView)
    }

    private func setupDataSource() {
        dataSource = (0 ..< columnsCount).map { _ in
            (0 ..< columnsCount).map { _ in nil }
        }

        let selectedRow = Int.random(in: 0 ..< columnsCount)
        let selectedColumn = Int.random(in: 0 ..< columnsCount)

        let color = UIColor.white
        let point = Point(row: selectedRow, column: selectedColumn)
        paintBlockAt(point: point, color: color, iteration: columnsCount / 2)
    }

    private func paintBlockAt(point: Point, color: UIColor, iteration: Int) {
        // крайний случай: кол-во столбцов = 1
        guard iteration != 0 else { dataSource[point.row][point.column] = UIColor.randomRGB; return }

        if iteration == 1 {
            dataSource[point.row][point.column] = color
            let neighborsColor = UIColor.randomRGB
            let neighborRowOffset = point.row % 2 == 0 ? 1 : -1
            let neighborColumnOffset = point.column % 2 == 0 ? 1 : -1
            dataSource[point.row + neighborRowOffset][point.column] = neighborsColor
            dataSource[point.row][point.column + neighborColumnOffset] = neighborsColor
            dataSource[point.row + neighborRowOffset][point.column + neighborColumnOffset] = neighborsColor
        }

        if iteration >= 2 {
            paintBlockAt(point: point, color: color, iteration: iteration / 2)
        }

        let blockRow = point.row / iteration
        let blockColumn = point.column / iteration

        let offset = iteration - 1
        let rowOffset = blockRow % 2 == 0 ? offset : -offset
        let columnOffset = blockColumn % 2 == 0 ? offset : -offset
        let adjacentRowOffset = blockRow % 2 == 0 ? 1 : -1
        let adjacentColumnOffset = blockColumn % 2 == 0 ? 1 : -1

        let blockTopLeftPoint = Point(row: blockRow * iteration,
                                      column: blockColumn * iteration)
        let blockRowRange = blockTopLeftPoint.row ... blockTopLeftPoint.row + offset
        let blockColumnRange = blockTopLeftPoint.column ... blockTopLeftPoint.column + offset

        var blockAdjacentPoint = blockTopLeftPoint
        if blockRowRange ~= blockAdjacentPoint.row + rowOffset {
            blockAdjacentPoint.row = blockAdjacentPoint.row + rowOffset
        }
        if blockColumnRange ~= blockAdjacentPoint.column + columnOffset {
            blockAdjacentPoint.column = blockAdjacentPoint.column + columnOffset
        }

        let adjacentPointsColor = UIColor.randomRGB
        for (rowOffset, columnOffset) in [(adjacentRowOffset, 0),
                                          (0, adjacentColumnOffset),
                                          (adjacentRowOffset, adjacentColumnOffset)] {
            let newPoint = Point(row: blockAdjacentPoint.row + rowOffset,
                                 column: blockAdjacentPoint.column + columnOffset)
            if dataSource[newPoint.row][newPoint.column] == nil {
                paintBlockAt(point: newPoint, color: adjacentPointsColor, iteration: iteration / 2)
            }
        }
    }

    // MARK: Actions

    @objc private func didTapButton() {
        if let newColumnsCount = Int(textField.text ?? ""),
           newColumnsCount.isPowerOfTwo {
            view.endEditing(true)
            columnsCount = newColumnsCount
        } else {
            let alert = UIAlertController(title: "Ошибка",
                                          message: "Пожалуйста, введите число, которое является степенью двойки",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Хорошо", style: .cancel))
            present(alert, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataSource.reduce(0) { $0 + $1.count }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        let row = indexPath.row / columnsCount
        let column = indexPath.row % columnsCount
        cell.backgroundColor = dataSource[row][column]

        return cell
    }
}

// MARK: - UICollectionViewDelegate

//extension ViewController: UICollectionViewDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        zoomView.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        let (selectedRow, selectedColumn) = convertToRowAndColumn(indexPath)
//        updateDataSource(withSelectedRow: selectedRow, selectedColumn: selectedColumn)
//    }
//}
