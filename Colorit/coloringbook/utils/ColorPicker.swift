
import UIKit
import ImageIO

public class ColorPicker: UIView {

    private var pickerImage1:PickerImage?
    private var pickerImage2:PickerImage?
    private var image:UIImage?
    private var data1Shown = false
    private lazy var opQueue:OperationQueue = {return OperationQueue()}()
    private var lock:NSLock = NSLock()
    private var rerender = false
    public var onColorChange:((_ color:UIColor, _ finished:Bool)->Void)? = nil
    

    public var a:CGFloat = 1 {
        didSet {
            if a < 0 || a > 1 {
                a = max(0, min(1, a))
            }
        }
    }

    public var h:CGFloat = 0 { // // [0,1]
        didSet {
            if h > 1 || h < 0 {
                h = max(0, min(1, h))
            }
            renderBitmap()
            setNeedsDisplay()
        }

    }
    private var currentPoint:CGPoint = CGPoint.zero


    public func saturationFromCurrentPoint() -> CGFloat {
        return (1 / bounds.width) * currentPoint.x
    }
    
    public func brigthnessFromCurrentPoint() -> CGFloat {
        return (1 / bounds.height) * currentPoint.y
    }
    
    public var color:UIColor  {
        set(value) {
            var hue:CGFloat = 1
            var saturation:CGFloat = 1
            var brightness:CGFloat = 1
            var alpha:CGFloat = 1
            value.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            a = alpha
            if hue != h || pickerImage1 === nil {
                self.h = hue
            }
            currentPoint = CGPoint(x: saturation * bounds.width, y: brightness * bounds.height)
            self.setNeedsDisplay()
        }
        get {
            return UIColor(hue: h, saturation: saturationFromCurrentPoint(), brightness: brigthnessFromCurrentPoint(), alpha: a)
        }
    }
    
    override public var bounds : CGRect {
        didSet {
            changeSize()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        isUserInteractionEnabled = true
        clipsToBounds = false
    }
    
    private func changeSize() {
        if let pImage1 = pickerImage1 {
            pImage1.changeSize(Int(self.bounds.width), height: Int(self.bounds.height))
        }
        if let pImage2 = pickerImage2 {
            pImage2.changeSize(Int(self.bounds.width), height: Int(self.bounds.height))
        }
        renderBitmap()
        self.setNeedsDisplay()
    }
    
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        handleTouche(touch: touch, ended: false)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        handleTouche(touch: touch, ended: false)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        handleTouche(touch: touch, ended: true)
    }
    
    private func handleColorChange(color:UIColor, changing:Bool) {
        if color !== self.color {
            if let handler = onColorChange {
                handler(color, !changing)
            }
            setNeedsDisplay()
        }
    }
    
    private func handleTouche(touch:UITouch, ended:Bool) {
        // set current point
        let point = touch.location(in: self)
        if self.bounds.contains(point) {
            currentPoint = point
        } else {
            let x:CGFloat = min(bounds.width, max(0, point.x))
            let y:CGFloat = min(bounds.width, max(0, point.y))
            currentPoint = CGPoint(x: x, y: y)
        }
        handleColorChange(color: pointToColor(point: point), changing: !ended)
    }
    
    private func pointToColor(point:CGPoint) ->UIColor {
        let s:CGFloat = min(1, max(0, (1.0 / bounds.width) * point.x))
        let b:CGFloat = min(1, max(0, (1.0 / bounds.height) * point.y))
        return UIColor(hue: h, saturation: s, brightness: b, alpha:a)
    }
    
    private func renderBitmap() {
        if self.bounds.isEmpty {
            return
        }
        if !lock.try() {
            rerender = true
            return
        }
        rerender = false
        
        if pickerImage1 == nil {
            self.pickerImage1 = PickerImage(width: Int(bounds.width), height: Int(bounds.height))
            self.pickerImage2 = PickerImage(width: Int(bounds.width), height: Int(bounds.height))
        }
        
        opQueue.addOperation { () -> Void in
            // Write colors to data array
            if self.data1Shown { self.pickerImage2!.writeColorData(self.h, a:self.a) }
            else { self.pickerImage1!.writeColorData(self.h, a:self.a)}
            
            
            // flip images
            self.image = self.data1Shown ? self.pickerImage2!.image! : self.pickerImage1!.image!
            self.data1Shown = !self.data1Shown
            
            // make changes visible
            OperationQueue.main.addOperation({ () -> Void in
                self.setNeedsDisplay()
                self.lock.unlock()
                if self.rerender {
                    self.renderBitmap()
                }
            })
            
        }
      
    }
    


    public override func draw(_ rect: CGRect) {
        if let img = image {
            img.draw(in: rect)
        }
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: currentPoint.x - 5, y: currentPoint.y - 5, width: 10, height: 10))
        UIColor.white.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()
        
        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalIn: CGRect(x: currentPoint.x - 4, y: currentPoint.y - 4, width: 8, height: 8))
        UIColor.black.setStroke()
        oval2Path.lineWidth = 1
        oval2Path.stroke()
    }

}
