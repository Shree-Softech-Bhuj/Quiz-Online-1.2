//import UIKit
/////Protocol determines the layout of the tab bar
//public protocol EVTabBar: class {
//    ///UIImage that serves as deliminator between the tab bar and UIViewControllers displayed
//    var shadowView: UIImageView { get set }
//    ///Array containing UIViewControllers to be displayed
//    var subviewControllers: [UIViewController] { get set }
//    ///EVPageViewController itself
//    var topTabBar: EVPageViewTopTabBar? { get set }
//    ///UIPageViewController that serves as the base
//    var pageController: UIPageViewController { get set }
//}
//
//public extension EVTabBar where Self: UIViewController {
//    ///Sets up the UI of the page view and tab bar
//    public func setupPageView() {
//        topTabBar?.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(topTabBar!)
//        pageController.view.translatesAutoresizingMaskIntoConstraints = false
//        pageController.view.frame = view.bounds
//        shadowView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(shadowView)
//        pageController.setViewControllers([subviewControllers[0]], direction: .forward, animated: false, completion: nil)
//        addChild(pageController)
//        view.addSubview(pageController.view)
//        pageController.didMove(toParent: self)
//        pageController.view.addSubview(shadowView)
//    }
//    ///Sets constraints for the view
//    public func setupConstraints() {
//        let views: [String:AnyObject] = ["menuBar" : topTabBar!, "pageView" : pageController.view, "shadow" : shadowView]
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[menuBar]|", options: [], metrics: nil, views: views)) //"V:|[menuBar(==60)]|"
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[menuBar(==60)][pageView]|", options: [], metrics: nil, views: views))
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[pageView]|", options: [], metrics: nil, views: views))
//
//        pageController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[shadow]|", options: [], metrics: nil, views: views))
//        pageController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[shadow(7)]", options: [], metrics: nil, views: ["shadow" : shadowView]))
//    }
//}
//
import UIKit
///Protocol determines the layout of the tab bar
public protocol EVTabBar: class {
    ///UIImage that serves as deliminator between the tab bar and UIViewControllers displayed
    var shadowView: UIImageView { get set }
    ///Array containing UIViewControllers to be displayed
    var subviewControllers: [UIViewController] { get set }
    ///EVPageViewController itself
    var topTabBar: EVPageViewTopTabBar? { get set }
    ///UIPageViewController that serves as the base
    var pageController: UIPageViewController { get set }
}

public extension EVTabBar where Self: UIViewController {
    ///Sets up the UI of the page view and tab bar
    func setupPageView() {
        
        topTabBar?.translatesAutoresizingMaskIntoConstraints = false
//        topTabBar?.backgroundColor = UIColor.black
        view.addSubview(topTabBar!)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageController.view.frame = view.bounds
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shadowView)
        pageController.setViewControllers([subviewControllers[1]], direction: .forward, animated: false, completion: nil) // by default view LIVE on index 1
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)
        pageController.view.addSubview(shadowView)
    }
    ///Sets constraints for the view
    func setupConstraints() {
        let views: [String:AnyObject] = ["menuBar" : topTabBar!, "pageView" : pageController.view, "shadow" : shadowView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[menuBar]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-75-[menuBar(==50)][pageView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[pageView]|", options: [], metrics: nil, views: views))     
        pageController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[shadow]|", options: [], metrics: nil, views: views))
        pageController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[shadow(0)]", options: [], metrics: nil, views: ["shadow" : shadowView]))
    }
}
