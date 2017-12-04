//
//  ViewController.swift
//  AR
//
//  Created by jhw on 26/11/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

public let g_width = 640
public let g_height = 360
public let g_intrinsics = simd_float3x3([float3(513.98, 0.0, 0.0), float3(0.0, 513.98, 0.0), float3(320.0865, 179.7095, 1.0)])

class ViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var DepthView: UIImageView!
    @IBOutlet weak var WeightView: UIImageView!
    @IBOutlet weak var glView: myGLKView!
    
    var isPreviewStart: Bool = false
    var cubeNode: SCNNode!
    
    var cubePose: CameraPose! = nil
    
    var imageRect: ImageRectification!
    var inited: Bool = false
    
    var frameid: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addGestures()
    }
    
    //override session(_:didUpdate:) to update DepthView and WeightView every frame
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
     
        if !inited {
            imageRect = ImageRectification.init()
            inited = true
        }
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        /*
        //
        var pixelbuffer = currentFrame.capturedImage
        
        let image = CIImage.init(cvImageBuffer: pixelbuffer)
        let context = CIContext()
        let cgiImage = context.createCGImage(image, from: image.extent)
        let capturedImage = UIImage.init(cgImage: cgiImage!)
 
        */
        let snapimage = sceneView.snapshot()
        //DepthView.image = capturedImage
        let camerapose = currentFrame.camera.transform
        let pose = CameraPose.init(A: g_intrinsics, trans: camerapose)
        
        if frameid % 2 == 0 {
            let (img1, img2) = imageRect.imageRectification(inputimage: snapimage, inputpose: pose)
            if img1 != nil && img2 != nil {
                DepthView.image = img1
                WeightView.image = img2
            }
        }
        
        frameid = (frameid + 1) % 400
        //print(currentFrame.camera.imageResolution)
    }
    
    
    private func addGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePanGesture(sender:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc
    func handlePanGesture(sender: UIPanGestureRecognizer) {
        if sceneView.scene.rootNode.childNodes.count == 0 || !isPreviewStart{
            return
        }
        
        let velocity = sender.velocity(in: self.view)
        let last_scale = cubeNode.scale.x
        
        if velocity.y > 0 {
            cubeNode.scale = SCNVector3(last_scale * 0.99, last_scale * 0.99, last_scale * 0.99)
        }
            
        else {
            cubeNode.scale = SCNVector3(last_scale * 1.01, last_scale * 1.01, last_scale * 1.01)
        }
    }
    
    @IBAction func setPreviewCube(_ sender: UIButton) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let edgeLength = CGFloat(0.1)
        let cube = SCNBox(width: edgeLength, height: edgeLength, length: edgeLength, chamferRadius: edgeLength/10)
    
        let edgeTexture = UIImage(named: "edgeTexture")
        
        cube.firstMaterial?.diffuse.contents = edgeTexture//sceneView.snapshot()//UIColor.gray.withAlphaComponent(0.5)
        cube.firstMaterial?.lightingModel = .constant
        cube.firstMaterial?.isDoubleSided = true
        
        cubeNode = SCNNode(geometry: cube)
        
        if sceneView.scene.rootNode.childNodes.count > 0 {
            sceneView.scene.rootNode.replaceChildNode(sceneView.scene.rootNode.childNodes[0], with: cubeNode)
        }
        else {
            sceneView.scene.rootNode.addChildNode(cubeNode)
        }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1
        cubeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        cubePose = CameraPose.init(A: g_intrinsics, trans: cubeNode.simdTransform)
        
        isPreviewStart = true
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
