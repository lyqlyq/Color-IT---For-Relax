
import UIKit

@IBDesignable public class ColorWell: UIView {

    @IBInspectable public var color:UIColor = UIColor.cyan {
        didSet {
            setNeedsDisplay()
        }
    }

    public var previewColor:UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var borderColor:UIColor = UIColor.darkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var borderWidth:CGFloat = 2 {
        didSet{
            setNeedsDisplay()
        }
    }
    
    func commonInit() {
        backgroundColor = UIColor.clear
        isOpaque = false
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override public func draw(_ rect: CGRect) {
        
        let ovalPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        color.setFill()
        ovalPath.fill()
        
        if let col = previewColor {
            let ovalPath = UIBezierPath(rect: CGRect(x: bounds.width/2, y: 0, width: bounds.width/2, height: bounds.height))
            col.setFill()
            ovalPath.fill()
        }
        
        //borderColor.setStroke()
        //ovalPath.lineWidth = borderWidth
        //ovalPath.stroke()
    }


}
