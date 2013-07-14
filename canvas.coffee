#------------------------------------------------------------------------------#
# CanvasLife.js: HTML5のCanvasが書きにくいので若干使いやすくした
#------------------------------------------------------------------------------#

class Canvas
	constructor: (jqo, defaultStyle) ->
		
		# jQuery object
		this.jqo = jqo

		this.width = this.jqo.width()
		this.height = this.jqo.height()
		this.jqo.attr("width", this.width)
		this.jqo.attr("height", this.height)

		this.offset()

		# strokeの色、fillの色のデフォルト
		this.default = {}
		if defaultStyle
			if defaultStyle.strokeColor != undefined
				this.default.strokeColor = defaultStyle.strokeColor
			if defaultStyle.fillColor != undefined
				this.default.fillColor = defaultStyle.fillColor

	# Contextの取得。毎回書くのめんどいのでメソッド化。
	ctx: ->
		return this.jqo[0].getContext("2d")
	
	# ブラウザ上におけるCanvas要素の四隅の位置を取得
	# クリックイベント等の作成時に必要
	offset: ->
		tmp = this.jqo.offset()
		this.left = tmp.left
		this.top = tmp.top
		this.right = tmp.left + this.width
		this.bottom = tmp.top + this.height
	
	# Pathを描写
	@drawPath: (ctx, type) ->
		if type == "s"
			ctx.stroke()
		if type == "f"
			ctx.fill()
		if type == "fs"
			ctx.fill()
			ctx.stroke()
		
	# ctxに、pointsの点を順につないだパスを追加
	# todo: pointsの形状が正しくないときの処理

	polylinePath: (ctx, points) ->
		ctx.beginPath()
		if points? == false
			throw new Error("CanvasLife Error: missing of points")
			return false
		for p in points
			ctx.lineTo(p[0], p[1])
	
	setCtxStyle: (ctx, style) ->
		if style?
			if (style.strokeWidth == undefined)
				ctx.lineWidth = this.default.strokeWidth
			else
				ctx.lineWidth = style.strokeWidth

			if (style.strokeColor == undefined)
				ctx.strokeStyle = this.default.strokeColor
			else
				ctx.strokeStyle = style.strokeColor
	
			if (style.fillColor == undefined)
				ctx.fillStyle = this.default.fillColor
			else
				ctx.fillStyle = style.fillColor

	# 折れ線 (閉じないストローク)
	line: (args) ->
		ctx = this.ctx()
		this.setCtxStyle(ctx, args)
		this.polylinePath(ctx, args.points)
		ctx.stroke()
	
	# 多角形
	polygonal: (args) ->
		ctx = this.ctx()
		this.setCtxStyle(ctx, args)
		this.polylinePath(ctx, args.points)
		ctx.closePath()

		Canvas.drawPath(ctx, args.type)

	# 円
	circle: (args) ->
		ctx = this.ctx()
		this.setCtxStyle(ctx, args)

		ctx.beginPath()
		if args.center[0] && args.center[1] && args.radius && args.type
			ctx.arc(args.center[0], args.center[1], args.radius, 0, Math.PI*2)
			Canvas.drawPath(ctx, args.type)
		else
			console.log args
			throw new Error("CanvasLife Error: Invalid Parameters")
	
	# Canvas全体を消去
	allClear: () ->
		ctx = this.ctx()
		ctx.clearRect(0,0,this.width,this.height)

