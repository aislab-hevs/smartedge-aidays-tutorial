import 'package:summerschool_tutorial/webview_manager.dart';
import 'package:vector_math/vector_math.dart';

/// A class that processes quaternions and sends the results to a web view.
class ThingyAgent {
  /// Holds the quaternion used for correcting the input quaternion.
  Quaternion? _correctionQuaternion;

  /// Stores the initial corrected quaternion, used as a reference.
  Quaternion? _initialQuaternion;

  /// Applies a quaternion, processes it, and sends it to a web view.
  ///
  /// Normalizes the given quaternion, applies a "correction" based on the first
  /// received quaternion, and sends the resulting quaternion to a web view
  /// using JavaScript.
  ///
  /// [quaternion]: The input quaternion to process.
  void applyQuaternion(Quaternion quaternion) {
    // Normalize the input quaternion to ensure it has unit length.
    quaternion.normalize();

    // Initialize the correction quaternion if not already set.
    // The correction quaternion is the inverse of the first input quaternion.
    _correctionQuaternion ??= quaternion.inverted();

    // Apply the correction quaternion to the input quaternion to get
    // a corrected quaternion.
    Quaternion correctedQuaternion = _correctionQuaternion! * quaternion;

    // Store the initial corrected quaternion if not already set.
    _initialQuaternion ??= correctedQuaternion;

    // Construct a JavaScript script that triggers a "moveHead" event
    // in the web view with the corrected quaternion's components.
    String script = """
          window.dispatchEvent(new CustomEvent("moveHead", {
            detail: JSON.parse("${[
      correctedQuaternion.w,
      correctedQuaternion.x,
      correctedQuaternion.y,
      correctedQuaternion.z,
    ]}")
          }));
          """;

    // Evaluate the constructed JavaScript in the web view.
    WebViewManager().evaluateJavascript(script);
  }

  /// Resets the correction and initial quaternions.
  ///
  /// This clears the stored quaternions, effectively starting fresh.
  void resetCorrectionQuaternion() {
    _correctionQuaternion = null;
    _initialQuaternion = null;
  }
}
