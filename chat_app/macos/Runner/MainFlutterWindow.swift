import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    self.title = "OpenCode Chat"
    // Narrow enough for the drawer layout to kick in below the 760 px
    // breakpoint.
    self.minSize = NSSize(width: 420, height: 540)
    self.setContentSize(NSSize(width: 1180, height: 780))
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
