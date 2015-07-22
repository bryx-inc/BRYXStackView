// Copyright (c) 2015 Bryx, Inc. <harlan@bryx.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

/// A struct for holding references to views and their corresponding insets.
private struct ViewBox {
    let view: UIView
    let edgeInsets: UIEdgeInsets
}

/// The StackView class provides a streamlined interface for
/// laying out a collection of views in a column.
/// StackView takes advantage of Auto Layout to make sure its
/// views size appropriately on all devices and orientations.
@availability(iOS, introduced=7.0)
public class StackView: UIView {
    
    /// Holds a reference to the constraints placed on the
    /// views in the stack.
    ///
    /// When a new view is added, these constraints are
    /// removed from the StackView and re-generated.
    private var stackConstraints = [NSLayoutConstraint]()
    
    /// Holds all the stacked views and their corresponding
    /// edge insets so the constraints can be re-generated.
    private var viewBoxes = [ViewBox]()
    
    /// Tells whether or not we are currently batching updates.
    /// If this proerty is true, then updateConstraints will only
    /// call the superview's method.
    private var isBatchingUpdates = false
    
    public init() {
        super.init(frame: CGRectZero)
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Removes all subviews from the StackView,
    /// and all associated constraints.
    @availability(iOS, introduced=7.0)
    public func removeAllSubviews() {
        self.batchUpdates({
            for subview in self.subviews {
                subview.removeFromSuperview()
            }
            self.stackConstraints.removeAll(keepCapacity: true)
            self.viewBoxes.removeAll(keepCapacity: true)
        })
    }
    
    /// Batches updates of views, and calls completion when finished.
    /// Use this when you have many views to add, and only want to update
    /// the constraints when all views have been added.
    ///
    /// :param: updates The updates (view insertions or removals)
    /// :param: completion An optional block to call once the updates have
    ///                    finished and the constraints have been updated.
    ///
    /// :note: This method is safe to call inside an existing batch update.
    public func batchUpdates(updates: () -> (), completion: (() -> ())? = nil) {
        if self.isBatchingUpdates {
            // If we're already batching updates, don't modify the isBatchingUpdates
            // value. Instead, just call the updates.
            updates()
        } else {
            self.isBatchingUpdates = true
            updates()
            self.isBatchingUpdates = false
            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()
        }
        completion?()
    }
    
    /// If the view hierarchy has changed, and the StackView is not batching updates,
    /// this method recomputes the constraints needed to represent the stacked views
    /// with all of their edge insets.
    override public func updateConstraints() {
        if self.stackConstraints.isEmpty && !self.isBatchingUpdates {
            var affectedBoxes = [ViewBox]()
            for box in self.viewBoxes {
                if box.view.hidden { continue }
                // Horizontally constrain the new view with respect to the edge insets.
                var views = ["view": box.view]
                let horizontal = NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|-(\(box.edgeInsets.left))-[view]-(\(box.edgeInsets.right))-|",
                    options: .DirectionLeadingToTrailing,
                    metrics: nil, views: views
                    ) as! [NSLayoutConstraint]
                self.addConstraints(horizontal)
                self.stackConstraints += horizontal
                
                // If there isn't an existing view in the stack, we'll need
                // to vertically constrain with respect to the superview,
                // so use `|`. Otherwise, if we have a previously-added view,
                // constrain vertically to that view and
                let parent: String
                var topInset = box.edgeInsets.top
                if let last = affectedBoxes.last {
                    parent = "[parent]"
                    views["parent"] = last.view
                    
                    // Add the previous view's 'bottom' to this view's
                    // 'top'.
                    topInset += last.edgeInsets.bottom
                } else {
                    parent = "|"
                }
                
                // Vertically constrain the new view with respect to the edge insets.
                // Also add the bottom from the previous view's edge insets.
                let vertical = NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:\(parent)-(\(topInset))-[view]",
                    options: .DirectionLeadingToTrailing,
                    metrics: nil, views: views
                    ) as! [NSLayoutConstraint]
                self.addConstraints(vertical)
                self.stackConstraints += vertical
                
                affectedBoxes.append(box)
            }
            if let box = affectedBoxes.last {
                // Reset the lastViewConstraints to the constraints on this new view.
                let lastConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:[view]-(\(box.edgeInsets.bottom))-|",
                    options: .DirectionLeadingToTrailing,
                    metrics: nil, views: ["view": box.view]
                    ) as! [NSLayoutConstraint]
                self.addConstraints(lastConstraints)
                self.stackConstraints += lastConstraints
            }
        }
        super.updateConstraints()
    }
    
    /// Adds a subview to the StackView with associated edge insets.
    /// StackView will attempt to create constraints such that the view has
    /// padding around it that matches the provided insets.
    ///
    /// :param: view The view to add.
    /// :param: edgeInsets A UIEdgeInsets struct containing top and bottom insets
    ///                    that the view should respect within the stack.
    public func addSubview(view: UIView, withEdgeInsets edgeInsets: UIEdgeInsets) {
        // Remove the constraints on the view.
        super.addSubview(view)
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.viewBoxes.append(ViewBox(view: view, edgeInsets: edgeInsets))
        self.invalidateConstraints()
    }
    
    /// Inserts a subview at the provided index in the stack. Also re-orders the views
    /// in the stack such that the new order is respected.
    ///
    /// :param: view The view to add.
    /// :param: index The index, vertically, where the view should live in the stack.
    /// :param: edgeInsets: The insets to apply around the view.
    public func insertSubview(view: UIView, atIndex index: Int, withEdgeInsets edgeInsets: UIEdgeInsets) {
        super.insertSubview(view, atIndex: index)
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.viewBoxes.insert(ViewBox(view: view, edgeInsets: edgeInsets), atIndex: index)
        self.invalidateConstraints()
    }
    
    /// Inserts a subview at the provided index in the stack. Also re-orders the views
    /// in the stack such that the new order is respected.
    ///
    /// :param: view The view to add.
    /// :param: index The index, vertically, where the view should live in the stack.
    public override func insertSubview(view: UIView, atIndex index: Int) {
        self.insertSubview(view, atIndex: index, withEdgeInsets: UIEdgeInsetsZero)
    }
    
    /// Re-sets the edge insets associated with a view in the stack, and triggers a layout pass.
    /// If the view is not found in the stack, this method does nothing.
    ///
    /// :param: insets The new insets to apply to the view.
    /// :param: view The view to update.
    public func setEdgeInsets(insets: UIEdgeInsets, forView view: UIView) {
        for (index, box) in enumerate(self.viewBoxes) {
            if box.view === view {
                self.viewBoxes[index] = ViewBox(view: view, edgeInsets: insets)
                self.invalidateConstraints()
                break
            }
        }
    }
    
    /// Adds all of the provided views to the stack with the provided edgeInsets applied to each of them.
    ///
    /// :param: views An Array of UIViews to be added to the stack.
    /// :param: insets UIEdgeInsets to apply around each view.
    public func addSubviews(views: [UIView], withEdgeInsets edgeInsets: UIEdgeInsets = UIEdgeInsetsZero, completion: (() -> ())? = nil) {
        self.batchUpdates({
            for view in views {
                self.addSubview(view, withEdgeInsets: edgeInsets)
            }
            }, completion: completion)
    }
    
    /// Removes all constraints added by the StackView and tells the
    /// view to update the constraints if it's not currently batching requests.
    public func invalidateConstraints() {
        self.removeConstraints(self.stackConstraints)
        self.stackConstraints.removeAll(keepCapacity: true)
        if !self.isBatchingUpdates {
            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()
        }
    }
    
    /// Adds a subview to the StackView with associated edge insets.
    /// StackView will attempt to create constraints such that the view has
    /// padding around it that matches the provided insets.
    ///
    /// :param: view The view to add.
    override public func addSubview(view: UIView) {
        self.addSubview(view, withEdgeInsets: UIEdgeInsetsZero)
    }
    
}
