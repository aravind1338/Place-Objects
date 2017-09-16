//
//  ViewController.swift
//  Place Objects
//
//  Created by Aravind Mantravadi on 2017-08-23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    //MARK: Properties
    @IBOutlet var sceneView: ARSCNView!
    
    private var distanceLabel = UILabel()
    private var trackingStateLabel = UILabel()
    
    private var enableDistanceButton = UIButton()
    private var bodyButton = UIButton()
    private var ballButton = UIButton()
    private var removeObjectButton = UIButton()
    
    private var objectList: [SCNNode] = []
    private var whichButtonIsTapped: String = ""
    private var enableDistance: Bool = false
    
    private var startNode: SCNNode?
    private var endNode: SCNNode?
    
    // Create a session configuration
    let configuration = ARWorldTrackingSessionConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        /*Set up the labels, buttons and a TapGestureRecognizer*/
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapGesture))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        distanceLabel.text = "Distance: ?"
        distanceLabel.textColor = .red
        distanceLabel.frame = CGRect(x: 5, y: 5, width: 150, height: 25)
        view.addSubview(distanceLabel)
        
        trackingStateLabel.frame = CGRect(x: 5, y: 35, width: 300, height: 25)
        view.addSubview(trackingStateLabel)
        
        enableDistanceButton.setTitle("Enable Dist", for: enableDistanceButton.state)
        enableDistanceButton.setTitleColor(.red, for: enableDistanceButton.state)
        enableDistanceButton.frame = CGRect(x: 5, y: 55, width: 150, height: 25)
        enableDistanceButton.addTarget(self, action: #selector(enableButtonAction), for: .touchUpInside)
        view.addSubview(enableDistanceButton)
        
        bodyButton.setTitle("Body", for: bodyButton.state)
        bodyButton.setTitleColor(.red, for: bodyButton.state)
        bodyButton.frame = CGRect(x: 150, y: 25, width: 100, height: 25)
        bodyButton.addTarget(self, action: #selector(bodyButtonAction), for: .touchUpInside)
        view.addSubview(bodyButton)
        
        ballButton.setTitle("Ball", for: ballButton.state)
        ballButton.setTitleColor(.red, for: ballButton.state)
        ballButton.frame = CGRect(x: 250, y: 25, width: 100, height: 25)
        ballButton.addTarget(self, action: #selector(ballButtonAction), for: .touchUpInside)
        view.addSubview(ballButton)
        
        removeObjectButton.setTitle("Remove", for: removeObjectButton.state)
        removeObjectButton.setTitleColor(.red, for: removeObjectButton.state)
        removeObjectButton.frame = CGRect(x: 5, y: 90, width: 100, height: 25)
        removeObjectButton.addTarget(self, action: #selector(removeObjectAction), for: .touchUpInside)
        view.addSubview(removeObjectButton)
        
        setupFocusSquare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Tell the session to automatically detect horizontal planes
        self.configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(self.configuration)
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
    
    //MARK: Button Actions
    
    @objc func bodyButtonAction(sender: UIButton!) {
        whichButtonIsTapped = "Body"
        enableDistance = false
        //createObject(fileName: "manbody.obj", shouldRotate: true)
    }
    
    @objc func ballButtonAction(sender: UIButton!) {
        whichButtonIsTapped = "Ball"
        enableDistance = false
        //createObject(fileName: "TennisBall.obj", shouldRotate: true)
    }
    
    @objc func removeObjectAction(sender: UIButton!) {
        if (objectList.isEmpty == false) {
            objectList.last?.removeFromParentNode()
            objectList.removeLast()
        }else {
            return
        }
    }
    
    @objc func enableButtonAction(sender: UIButton!) {
        if (enableDistance == false) {
            enableDistance = true
            whichButtonIsTapped = ""
        }else {
            enableDistance = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        //let results = sceneView.hitTest(touch.preciseLocation(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        let results = sceneView.hitTest(touch.preciseLocation(in: sceneView), types: [ARHitTestResult.ResultType.estimatedHorizontalPlane])
        guard let hitFeature = results.first else {return}
        
        //Method 1:
        
        /*var translation = matrix_identity_float4x4
        translation.columns.3.z = -1
        let hitPosition = simd_mul(hitFeature.worldTransform, translation)*/
        
        //Method 2:
        
        /*let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)*/
        
        //Method 3:
        
        let hitPosition = SCNVector3.positionFromTransform(hitFeature.worldTransform)
        
        if (whichButtonIsTapped == "Body") {
            createObject(fileName: "manbody.obj", shouldRotate: true, hitPosition: hitPosition)
        }else if (whichButtonIsTapped == "Ball") {
            createObject(fileName: "TennisBall.obj", shouldRotate: true, hitPosition: hitPosition)
        }else {
            return
        }
    }
    
    //Function that creates and places objects
    
    private func createObject(fileName: String, shouldRotate: Bool, hitPosition: SCNVector3) {
        
        let name = "art.scnassets/" + fileName
        guard let object = SCNScene(named: name) else {return}
        let node = SCNNode()
        let nodeArray = object.rootNode.childNodes
        
        for childNode in nodeArray {
            node.addChildNode(childNode)
        }
        
        objectList.append(node)
        
        //Set the position of the object
        
        /*let result = sceneView.hitTest(view.center, types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitResult = result.last else {return}
        let hitTransform = SCNMatrix4(hitResult.worldTransform)
        let position = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        
        node.position = position*/
        
        node.position = hitPosition
        //node.simdTransform = hitPosition
        
        if (shouldRotate == true) {
            node.pivot = SCNMatrix4MakeRotation(Float.pi/2, 2.5, 1, 1)
        }
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    //MARK: Distance Calculator Functions
    
    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        
        if sender.state != .ended || enableDistance == false{
            return
        }
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        if let endNode = endNode {
            // Reset
            startNode?.removeFromParentNode()
            self.startNode = nil
            endNode.removeFromParentNode()
            self.endNode = nil
            distanceLabel.text = "Distance: ?"
            return
        }
        
        let planeHitTestResults = sceneView.hitTest(view.center, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            let hitPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let sphere = SCNSphere(radius: 0.005)
            sphere.firstMaterial?.diffuse.contents = UIColor.red
            sphere.firstMaterial?.lightingModel = .constant
            sphere.firstMaterial?.isDoubleSided = true
            let node = SCNNode(geometry: sphere)
            node.position = hitPosition
            sceneView.scene.rootNode.addChildNode(node)
            
            if let startNode = startNode {
                endNode = node
                let vector = startNode.position - node.position
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.roundingMode = .ceiling
                formatter.maximumFractionDigits = 2
                // Scene units map to meters in ARKit.
                distanceLabel.text = "Distance: " + formatter.string(from: NSNumber(value: vector.length()))! + " m"
            }
            else {
                startNode = node
            }
        }
        else {
            // Create a transform with a translation of 0.1 meters (10 cm) in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.1
            // Add a node to the session
            let sphere = SCNSphere(radius: 0.005)
            sphere.firstMaterial?.diffuse.contents = UIColor.red
            sphere.firstMaterial?.lightingModel = .constant
            sphere.firstMaterial?.isDoubleSided = true
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.simdTransform = simd_mul(currentFrame.camera.transform, translation)
            sceneView.scene.rootNode.addChildNode(sphereNode)
            
            if let startNode = startNode {
                endNode = sphereNode
                self.distanceLabel.text = String(format: "%.2f", distance(startNode: startNode, endNode: sphereNode)) + "m"
            }
            else {
                startNode = sphereNode
            }
        }
    }
    
    func distance(startNode: SCNNode, endNode: SCNNode) -> Float {
        let vector = SCNVector3Make(startNode.position.x - endNode.position.x, startNode.position.y - endNode.position.y, startNode.position.z - endNode.position.z)
        // Scene units map to meters in ARKit.
        return sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    }
    
    var dragOnInfinitePlanesEnabled = false
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            trackingStateLabel.text = "Tracking not available"
            trackingStateLabel.textColor = .red
        case .normal:
            trackingStateLabel.text = "Tracking normal"
            trackingStateLabel.textColor = .green
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                trackingStateLabel.text = "Tracking limited: excessive motion"
            case .insufficientFeatures:
                trackingStateLabel.text = "Tracking limited: insufficient features"
            }
            trackingStateLabel.textColor = .yellow
        }
    }
    
    // MARK: - Focus Square
    
    var focusSquare = FocusSquare()
    
    func setupFocusSquare() {
        focusSquare.unhide()
        focusSquare.removeFromParentNode()
        sceneView.scene.rootNode.addChildNode(focusSquare)
    }
    
    func updateFocusSquare() {
        let (worldPosition, planeAnchor, _) = worldPositionFromScreenPosition(view.center, objectPos: focusSquare.position)
        if let worldPosition = worldPosition {
            focusSquare.update(for: worldPosition, planeAnchor: planeAnchor, camera: sceneView.session.currentFrame?.camera)
        }
    }
    
    
    //MARK: Plane Detection Methods
    
    //The following functions are automatically called when the ARSessionView adds, updates, and removes anchors
    
    // When a plane is detected, make a planeNode for it
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = SCNNode()
        node.addChildNode(planeNode)
        planeNode.geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        material.transparency = 0.5
        planeNode.geometry?.materials = [material]
        planeNode.position = SCNVector3Make(planeAnchor.center.x, -0.002, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-.pi/2.0, 1, 0, 0)
        
        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        
        node.addChildNode(planeNode)
    }
    
    // When a detected plane is removed, remove the planeNode
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        // Remove existing plane nodes
        node.enumerateChildNodes {
            (childNode, _) in
            childNode.removeFromParentNode()
        }
        
    }
    
}

extension ViewController {
    
    // Code from Apple PlacingObjects demo: https://developer.apple.com/sample-code/wwdc/2017/PlacingObjects.zip
    
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor
            
            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        
        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        
        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
            
            let pointOnPlane = objectPos ?? SCNVector3Zero
            
            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }
        
        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
    
}

