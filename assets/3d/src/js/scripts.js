import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import { FBXLoader } from 'three/examples/jsm/loaders/FBXLoader'

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

var headBone;

// flutterInAppWebViewPlatformReady is the event that is fired when Flutter runs it
window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
 isFlutterInAppWebViewReady = true;
});


// LISTEN TO moveHead EVENT -> The function to rotate the head.
window.addEventListener("moveHead", function(event) {
    rotateHead(...event.detail);
}, false)

// Sets the color of the background
renderer.setClearColor(0xFEFEFE);

// Create a 3D scene using JavaScript THREE.js
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(
    30,
    window.innerWidth / window.innerHeight,
    0.1,
    1000
);

// Camera controller for mouse and touch
const orbit = new OrbitControls(camera, renderer.domElement);

var prevSensorQuaternion = new THREE.Quaternion(0, 0, 0, 1);
var sensorDelta = new THREE.Quaternion(0, 0, 0, 1);
function rotateHead(w, x, y, z) {
    var sensorQuaternion = new THREE.Quaternion(y, x, z, w);
    sensorQuaternion = sensorQuaternion.normalize()
    sensorDelta.multiplyQuaternions(sensorDelta, prevSensorQuaternion.clone().invert().multiply(sensorQuaternion))
    headBone.setRotationFromQuaternion(sensorDelta);
    prevSensorQuaternion = sensorQuaternion;
}

const loader = new FBXLoader();
loader.load('assets/Ch36_nonPBR.fbx', function (model) {
    // const model = gltf.scene
    model.scale.set(.01, .01, .01);

    const skeleton = new THREE.SkeletonHelper(model);
    skeleton.visible = true;
    console.log(model)
    headBone = model.getObjectByName("mixamorig1Head")
    const headBoneWorldPosition = new THREE.Vector3();
    const headPos = headBone.getWorldPosition(headBoneWorldPosition);

    var circleGeometry = new THREE.RingGeometry(1, 1.005, 32, 1, 0, Math.PI * 2);
    var circleMaterial = new THREE.MeshBasicMaterial({ color: 0xff0000, side: THREE.DoubleSide });
    var circleMesh = new THREE.Mesh(circleGeometry, circleMaterial);
    circleMesh.position.set(headPos.x, headPos.y, headPos.z);
    circleMesh.rotation.x = Math.PI / 2;

    const distance = 2;
    const offset = headBoneWorldPosition.clone().add(new THREE.Vector3(0, 0, distance));
    camera.position.copy(offset);
    orbit.target.copy(headBoneWorldPosition);

    orbit.minPolarAngle = Math.PI / 4; // Minimum vertical angle (radians)
    orbit.maxPolarAngle = Math.PI / 2; // Maximum vertical angle (radians)

    orbit.minAzimuthAngle = -Math.PI / 4; // Minimum horizontal angle (radians)
    orbit.maxAzimuthAngle = Math.PI / 4; // Maximum horizontal angle (radians

    orbit.update();

    const iks = [
        {
            target: 5, // "target"
            effector: 4, // "bone3"
            links: [ { index: 3 }, { index: 2 }, { index: 1 } ] // "bone2", "bone1", "bone0"
        }
    ];

    scene.add(skeleton);
    scene.add(model);

}, undefined, function (error) {
    console.error(error);
});

const ambientLight = new THREE.AmbientLight(0xFFFFFF);
ambientLight.intensity = 2;
scene.add(ambientLight);

const gridHelper = new THREE.GridHelper(12, 12);
scene.add(gridHelper);

const axesHelper = new THREE.AxesHelper(4);
scene.add(axesHelper);

function animate() {
    renderer.render(scene, camera);
}

renderer.setAnimationLoop(animate);

window.addEventListener('resize', function () {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize(window.innerWidth, window.innerHeight);
});