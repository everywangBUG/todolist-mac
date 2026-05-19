import AppKit
import Foundation

func createIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    guard let context = NSGraphicsContext.current?.cgContext else { return image }

    let scale = size / 1024.0
    context.scaleBy(x: scale, y: scale)

    let rect = CGRect(x: 0, y: 0, width: 1024, height: 1024)
    let cornerRadius: CGFloat = 224

    let clipPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    clipPath.addClip()

    let gradientColors = [
        NSColor(red: 0.20, green: 0.60, blue: 1.00, alpha: 1.0).cgColor,
        NSColor(red: 0.10, green: 0.40, blue: 0.85, alpha: 1.0).cgColor
    ]
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: [0.0, 1.0])!
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 1024), end: CGPoint(x: 1024, y: 0), options: [])

    let shadowPath = NSBezierPath(roundedRect: rect.insetBy(dx: 40, dy: 40), xRadius: cornerRadius - 20, yRadius: cornerRadius - 20)
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(white: 0.0, alpha: 0.15)
    shadow.shadowOffset = NSSize(width: 0, height: -8)
    shadow.shadowBlurRadius = 30
    shadow.set()
    NSColor(white: 1.0, alpha: 0.08).setFill()
    shadowPath.fill()
    NSShadow().set()

    let checkSize: CGFloat = 420
    let checkX: CGFloat = (1024 - checkSize) / 2
    let checkY: CGFloat = (1024 - checkSize) / 2 + 20

    let strokeWidth: CGFloat = 72
    let checkPath = NSBezierPath()
    checkPath.lineWidth = strokeWidth
    checkPath.lineCapStyle = .round
    checkPath.lineJoinStyle = .round

    let p1 = CGPoint(x: checkX + checkSize * 0.12, y: checkY + checkSize * 0.45)
    let p2 = CGPoint(x: checkX + checkSize * 0.38, y: checkY + checkSize * 0.18)
    let p3 = CGPoint(x: checkX + checkSize * 0.88, y: checkY + checkSize * 0.82)

    checkPath.move(to: p1)
    checkPath.line(to: p2)
    checkPath.line(to: p3)

    let checkShadow = NSShadow()
    checkShadow.shadowColor = NSColor(white: 0.0, alpha: 0.25)
    checkShadow.shadowOffset = NSSize(width: 0, height: -4)
    checkShadow.shadowBlurRadius = 12
    checkShadow.set()

    NSColor.white.setStroke()
    checkPath.stroke()

    NSShadow().set()

    let lineY1 = checkY + checkSize * 0.92
    let lineY2 = checkY + checkSize * 1.05
    let lineXStart = checkX + checkSize * 0.05
    let lineXEnd = checkX + checkSize * 0.55

    for (index, lineY) in [lineY1, lineY2].enumerated() {
        let linePath = NSBezierPath()
        linePath.lineWidth = strokeWidth * 0.45
        linePath.lineCapStyle = .round
        linePath.move(to: CGPoint(x: lineXStart, y: lineY))
        linePath.line(to: CGPoint(x: lineXEnd - CGFloat(index) * checkSize * 0.08, y: lineY))
        NSColor.white.withAlphaComponent(0.6).setStroke()
        linePath.stroke()
    }

    let shinePath = NSBezierPath()
    shinePath.move(to: CGPoint(x: 0, y: 1024))
    shinePath.line(to: CGPoint(x: 0, y: 620))
    shinePath.curve(to: CGPoint(x: 404, y: 0), controlPoint1: CGPoint(x: 0, y: 280), controlPoint2: CGPoint(x: 0, y: 0))
    shinePath.line(to: CGPoint(x: 0, y: 0))
    shinePath.close()

    NSColor.white.withAlphaComponent(0.08).setFill()
    shinePath.fill()

    image.unlockFocus()
    return image
}

func createIcns(outputPath: String) {
    let iconsetPath = outputPath + ".iconset"
    let fm = FileManager.default

    try? fm.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

    let sizes: [(name: String, size: CGFloat)] = [
        ("icon_16x16", 16),
        ("icon_16x16@2x", 32),
        ("icon_32x32", 32),
        ("icon_32x32@2x", 64),
        ("icon_128x128", 128),
        ("icon_128x128@2x", 256),
        ("icon_256x256", 256),
        ("icon_256x256@2x", 512),
        ("icon_512x512", 512),
        ("icon_512x512@2x", 1024)
    ]

    for (name, size) in sizes {
        let image = createIcon(size: size)
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            print("Failed to create icon for \(name)")
            continue
        }
        let filePath = (iconsetPath as NSString).appendingPathComponent(name + ".png")
        try? pngData.write(to: URL(fileURLWithPath: filePath))
    }

    let task = Process()
    task.launchPath = "/usr/bin/iconutil"
    task.arguments = ["-c", "icns", "-o", outputPath, iconsetPath]
    task.launch()
    task.waitUntilExit()

    try? fm.removeItem(atPath: iconsetPath)

    if fm.fileExists(atPath: outputPath) {
        print("Icon created successfully at: \(outputPath)")
    } else {
        print("Failed to create icon")
    }
}

let resourcesPath = "/Users/gene/Desktop/web/todolist-mac/TodoList/TodoList/Resources"
let icnsPath = (resourcesPath as NSString).appendingPathComponent("AppIcon.icns")
createIcns(outputPath: icnsPath)
