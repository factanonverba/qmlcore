/// Grid is a usefull way to automatically position its children
Layout {
	property int horizontalSpacing; ///< horizontal spacing between rows, overrides regular spacing, pixels
	property int verticalSpacing; ///< vertical spacing between columns, overrides regular spacing, pixels
	property int rowsCount; ///< read-only property, represents number of row in a grid
	property enum horizontalAlignment { AlignLeft, AlignRight, AlignHCenter, AlignJustify };	///< content horizontal alignment
	property enum flow { FlowTopToBottom, FlowLeftToRight };	///< content filling direction

	///@private
	onWidthChanged: {
		if (this.flow == this.FlowTopToBottom)
			this._delayedLayout.schedule()
	}

	///@private
	onHeightChanged: {
		if (this.flow == this.FlowLeftToRight)
			this._delayedLayout.schedule()
	}

	///@private
	onFlowChanged: {
		this._delayedLayout.schedule()
	}

	///@private
	function _layout() {
		var children = this.children;
		var crossPos = 0, directPos = 0, crossMax = 0, directMax = 0;
		var dsp = this.verticalSpacing || this.spacing,
			csp = this.horizontalSpacing || this.spacing // Cross Spacing
		this.count = children.length
		var rows = []
		rows.push({idx: 0, size: 0}) //starting value
		var horizontal = this.flow == this.FlowLeftToRight
		var size = horizontal ? this.height : this.width
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]

			if (!('height' in c) || !('width' in c))
				continue

			if (!horizontal) {
				var dbm = c.anchors.topMargin || c.anchors.margins // Direct Before Margin
				var dam = c.anchors.bottomMargin || c.anchors.margins // Direct After Margin
				var cbm = c.anchors.leftMargin || c.anchors.margins // Cross Before Margin
				var cam = c.anchors.rightMargin || c.anchors.margins // Cross After Margin
				var crossSize = c.width + cam + cbm
				var directSize = c.height + dbm + dam
			} else {
				var dbm = c.anchors.leftMargin || c.anchors.margins // Direct Before Margin
				var dam = c.anchors.rightMargin || c.anchors.margins // Direct After Margin
				var cbm = c.anchors.topMargin || c.anchors.margins // Cross Before Margin
				var cam = c.anchors.bottomMargin || c.anchors.margins // Cross After Margin
				var crossSize = c.height + cam + cbm
				var directSize = c.width + dbm + dam
			}

			if (c.recursiveVisible) {
				if (size - crossPos < crossSize) { // not enough space to put the item, initiate a new row
					rows.push({idx: i, size: crossPos - csp})
					directPos = directMax + dsp;
					directMax = directPos + directSize;
					if (horizontal) {
						c.y = cbm;
						c.x = directPos + dbm;
					} else {
						c.x = cbm;
						c.y = directPos + dbm;
					}
				} else {
					if (horizontal) {
						c.y = crossPos + cbm;
						c.x = directPos + dbm;
					} else  {
						c.x = crossPos + cbm;
						c.y = directPos + dbm;
					}
				}
				if (directMax < directPos + directSize)
					directMax = directPos + directSize;

				if (!horizontal)
					crossPos = c.x + c.width + cam + csp;
				else
					crossPos = c.y + c.height + cam + csp;

				if (crossMax < crossPos - csp)
					crossMax = crossPos - csp;
			}
		}

		this.rowsCount = rows.length;
		rows.push({idx: children.length, size: crossPos - csp}) // add last point

		this.contentHeight = horizontal ? crossMax : directMax;
		this.contentWidth = horizontal ? directMax : crossMax;

		if (this.horizontalAlignment === this.AlignLeft)
			return

		var right = this.horizontalAlignment === this.AlignRight
		var center = this.horizontalAlignment === this.AlignHCenter
		var justify = this.horizontalAlignment === this.AlignJustify
		var shift, row

		for (var i = 0; i < rows.length - 1; ++i) {
			row = rows[i+1]

			if (right)
				shift = size - row.size
			else if (center)
				shift = (size - row.size) / 2
			else if (justify)
				shift = (size - row.size)

			if (shift !== 0) {
				var cindex = rows[i].idx, lindex = row.idx
				if (right || center) {
		 			for (; cindex < lindex; ++cindex) {
		 				if (!horizontal)
							children[cindex].x += shift
						else
							children[cindex].y += shift
		 			}
		 		} else if (justify) {
		 			var c = lindex - cindex + 1
		 			var sp = shift / c
		 			for (; cindex < lindex; ++cindex) {
		 				if (!horizontal)
							children[cindex].x += sp * (cindex + c - lindex)
						else
							children[cindex].y += sp * (cindex + c - lindex)
		 			}
		 		}
		 	}
 		}
	}

	///@private
	function addChild(child) {
		_globals.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		if (child instanceof _globals.core.Item) {
			child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
			child.onChanged('width', delayedLayout.schedule.bind(delayedLayout))
			child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
			child.anchors.on('marginsUpdated', delayedLayout.schedule.bind(delayedLayout))
		}
	}

	onHorizontalSpacingChanged,
	onVerticalSpacingChanged,
	onHorizontalAlignmentChanged: {
		this._delayedLayout.schedule()
	}
}
