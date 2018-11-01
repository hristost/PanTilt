//
//  ViewController.swift
//  PanTilt
//
//  Created by hristost on 11/01/2018.
//  Copyright (c) 2018 hristost. All rights reserved.
//

import UIKit
import PanTilt

class ViewController: UIViewController {

    var canvasView: CanvasView!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView = CanvasView(frame: self.view.frame)
        self.view.addSubview(canvasView)
        let zoomGesture = ZoomPanGestureRecognizer(view: canvasView)
        canvasView.addGestureRecognizer(zoomGesture)
        canvasView.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

