//
//  ViewController.swift
//  XcapKitExample
//
//  Created by scchn on 2023/2/24.
//

import UIKit

import XcapKit

class ViewController: UIViewController {

    @IBOutlet weak var canvasView: XcapView!
    @IBOutlet weak var lineWidthButton: UIButton!
    @IBOutlet weak var strokeColorWell: UIColorWell!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet var drawingSessionButtons: [UIButton]!
    
    private var settingObservations: [SettingObservation] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNotifcation()
        
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if canvasView.contentSize == .zero {
            canvasView.contentSize = canvasView.frame.size
        }
    }
    
    // MARK: - Setups
    
    private func setupUI() {
        strokeColorWell.addTarget(self, action: #selector(self.strokeColorWellAction(_:)), for: .valueChanged)
        
        setupLineweightButton()
        setupCanvas()
    }
    
    private func setupLineweightButton() {
        let actions = (1...5).map { value in
            UIAction(title: "\(value)") { [weak self] _ in
                guard let self = self else {
                    return
                }
                
                let lineWidth = CGFloat(value)
                
                guard lineWidth != self.canvasView.drawingSessionLineWidth else {
                    return
                }
                
                self.canvasView.drawingSessionLineWidth = lineWidth
                self.canvasView.selectedObjects.forEach { object in
                    object.lineWidth = lineWidth
                }
            }
        }
        
        lineWidthButton.showsMenuAsPrimaryAction = true
        lineWidthButton.menu = UIMenu(title: "Lineweight", children: actions)
    }
    
    private func setupCanvas() {
        canvasView.delegate = self
        canvasView.selectionRange = 16
        canvasView.contentBackgroundColor = .white
        
        // Undo Action Names
        
        canvasView.implicitUndoActionNames[.addObjects] = "Remove"
        canvasView.implicitUndoActionNames[.removeObjects] = "Restore"
        canvasView.implicitUndoActionNames[.dragging] = "Move"
        canvasView.implicitUndoActionNames[.editing] = "Edit"
        canvasView.$drawingSessionLineWidth.undoMode = .enable(name: "Lineweight")
        canvasView.$drawingSessionStrokeColor.undoMode = .enable(name: "Color")
        
        // Observations
        
        canvasView.observeSetting(\.$drawingSessionLineWidth) { [weak self] lineWidth in
            self?.lineWidthButton.setTitle("\(Int(lineWidth))", for: .normal)
        }
        .store(in: &settingObservations)
        
        canvasView.observeSetting(\.$drawingSessionStrokeColor) { [weak self] color in
            self?.strokeColorWell.selectedColor = color
        }
        .store(in: &settingObservations)
    }
    
    private func setupNotifcation() {
        let center = NotificationCenter.default
        
        center.addObserver(forName: .NSUndoManagerCheckpoint, object: nil, queue: .main) { [weak self] notication in
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        let types = [LineSegmentRenderer.self, CircleRenderer.self]
        
        for (index, objectType) in types.enumerated() {
            let isSelected: Bool
            
            if let object = canvasView.currentObject {
                isSelected = type(of: object) == objectType
            } else {
                isSelected = false
            }
            
            drawingSessionButtons[index].tintColor = isSelected ? .black : nil
        }
        
        // Delete
        
        deleteButton.isEnabled = !canvasView.selectedObjects.isEmpty
        
        // Undo
        
        let undoActioName = (
            undoManager?.undoActionName.isEmpty ?? true
            ? "Undo"
            : undoManager?.undoActionName
        )
        undoButton.isEnabled = undoManager?.canUndo ?? false
        undoButton.setTitle(undoActioName, for: .normal)
        
        // Redo
        
        let redoActioName = (
            undoManager?.redoActionName.isEmpty ?? true
            ? "Redo"
            : undoManager?.redoActionName
        )
        redoButton.isEnabled = undoManager?.canRedo ?? false
        redoButton.setTitle(redoActioName, for: .normal)
    }
    
    // MARK: - Actions
    
    @objc private func strokeColorWellAction(_ sender: UIColorWell) {
        let color = sender.selectedColor ?? .black
        
        guard !canvasView.drawingSessionStrokeColor.isEqual(color) else {
            return
        }
        
        canvasView.drawingSessionStrokeColor = color
        canvasView.selectedObjects.forEach { object in
            object.strokeColor = color
        }
    }
    
    @IBAction func lineSegmentButtonAction(_ sender: Any) {
        canvasView.startDrawingSession(ofType: LineSegmentRenderer.self)
    }
    
    @IBAction func circleButtonAction(_ sender: Any) {
        canvasView.startDrawingSession(ofType: CircleRenderer.self)
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        canvasView.removeSelectedObjects()
    }
    
    @IBAction func undoButtonAction(_ sender: Any) {
        guard undoManager?.canUndo ?? false else {
            return
        }
        
        undoManager?.undo()
    }
    
    @IBAction func redoButtonAction(_ sender: Any) {
        guard undoManager?.canRedo ?? false else {
            return
        }
        
        undoManager?.redo()
    }
    
}


extension ViewController: XcapViewDelegate {
    
    func xcapView(_ xcapView: XcapView, didStartDrawingSessionWithObject object: ObjectRenderer) {
        updateUI()
    }
    
    func xcapView(_ xcapView: XcapView, didFinishDrawingSessionWithObject object: ObjectRenderer) {
        updateUI()
    }
    
    func xcapViewDidCancelDrawingSession(_ xcapView: XcapView) {
        updateUI()
    }
    
    func xcapView(_ xcapView: XcapView, didSelectObjects objects: [ObjectRenderer]) {
        updateUI()
    }
    
    func xcapView(_ xcapView: XcapView, didDeselectObjects objects: [ObjectRenderer]) {
        updateUI()
    }
    
}
