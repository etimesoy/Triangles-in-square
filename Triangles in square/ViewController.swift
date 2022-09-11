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
            removedCellPoint = Point(row: Int.random(in: 0 ..< columnsCount),
                                     column: Int.random(in: 0 ..< columnsCount))
            setupDataSource()
            if columnsCount != oldValue {
                let layout = createCollectionViewLayout()
                zoomView.layout = layout
                zoomView.collectionView.collectionViewLayout = layout
            }
            zoomView.collectionView.reloadData()
            pickerView.reloadAllComponents()
            pickerView.selectRow(removedCellPoint.row, inComponent: 0, animated: true)
            pickerView.selectRow(removedCellPoint.column, inComponent: 1, animated: true)
        }
    }
    private var removedCellPoint = Point(row: 0, column: 0)
    private let cellId = "cellId"

    // MARK: UI

    private lazy var textField: UITextField = {
        let textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let textField = UITextField.textFieldWithInsets(textInsets)
        textField.text = "\(columnsCount)"
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.gray.cgColor
        return textField
    }()
    private lazy var generateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.setTitle("Сгенерировать", for: .normal)
        button.addTarget(self, action: #selector(didTapGenerateButton), for: .touchUpInside)
        return button
    }()
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    private lazy var removeCellButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.setTitle("Выколоть эту клетку", for: .normal)
        button.addTarget(self, action: #selector(didTapRemoveCellButton), for: .touchUpInside)
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
        let generateButtonWidth: CGFloat = buttonHeight * 4
        textField.frame = CGRect(x: 5, y: topInset + 5,
                                 width: view.frame.width - generateButtonWidth - 15,
                                 height: buttonHeight + 5)

        view.addSubview(generateButton)
        generateButton.frame = CGRect(x: textField.frame.maxX + 5, y: topInset + 5,
                              width: generateButtonWidth, height: buttonHeight + 5)

        let removeCellButtonWidth: CGFloat = buttonHeight * 5
        view.addSubview(pickerView)
        pickerView.frame = CGRect(x: 5, y: textField.frame.maxY + 5,
                                  width: view.frame.width - removeCellButtonWidth - 15,
                                  height: buttonHeight + 5)

        view.addSubview(removeCellButton)
        removeCellButton.frame = CGRect(x: pickerView.frame.maxX + 5, y: textField.frame.maxY + 5,
                                        width: removeCellButtonWidth, height: buttonHeight + 5)

        view.addSubview(zoomContainerView)
        let frame = CGRect(x: 0, y: pickerView.frame.maxY + 5,
                           width: view.frame.width,
                           height: view.frame.height - textField.frame.maxY - 5)
        zoomContainerView.frame = frame
        zoomContainerView.addSubview(zoomView)
    }

    private func setupDataSource() {
        dataSource = (0 ..< columnsCount).map { _ in
            (0 ..< columnsCount).map { _ in nil }
        }
        paintBlockAt(point: removedCellPoint, color: UIColor.white, iteration: columnsCount / 2)
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

    @objc private func didTapGenerateButton() {
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

    @objc private func didTapRemoveCellButton() {
        removedCellPoint = Point(row: pickerView.selectedRow(inComponent: 0),
                                 column: pickerView.selectedRow(inComponent: 1))
        setupDataSource()
        zoomView.collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return columnsCount
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
}
