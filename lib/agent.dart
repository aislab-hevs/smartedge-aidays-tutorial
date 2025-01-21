import 'package:summerschool_tutorial/webview_manager.dart';
import 'package:vector_math/vector_math.dart';

class ThingyAgent {
  Quaternion? _correctionQuaternion;
  Quaternion? _initialQuaternion;

  void applyQuaternion(Quaternion quaternion) {
    quaternion.normalize();
    _correctionQuaternion ??= quaternion.inverted();

    Quaternion correctedQuaternion = _correctionQuaternion! * quaternion;
    _initialQuaternion ??= correctedQuaternion;


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

    WebViewManager().evaluateJavascript(script);
  }

  void resetCorrectionQuaternion() {
    _correctionQuaternion = null;
    _initialQuaternion = null;
  }
}
