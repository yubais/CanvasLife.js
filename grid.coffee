class Grid extends Canvas
	constructor: (jqo, args) ->
		super(jqo)
		this.gridColor = "#000000"
		this.gridColor = args.gridColor if args.gridColor?
		this.bgColor = "#ffffff"
		this.bgColor = args.bgColor if args.bgColor?
		this.cols = args.cols
		this.rows = args.rows
		this.xstep = this.width / this.cols
		this.ystep = this.height / this.rows

		this.jqo.css("background-color",this.bgColor)
		this.jqo.css("border","solid 1px #{this.gridColor}")

		this.drawGrid('vertical', this.xstep, this.gridColor)
		this.drawGrid('horizontal', this.ystep, this.gridColor)

	# グリッドを描写。direction = 'vertical' or 'horizontal'
	drawGrid: (direction, step, color) ->
		ctx = this.ctx()
		ctx.beginPath()
		ctx.strokeStyle = color

		i = 1
		while i * step < this.width
			if direction == "horizontal"
				ctx.moveTo(0, i*step)
				ctx.lineTo(this.width, i*step)
			else
				ctx.moveTo(i*step, 0)
				ctx.lineTo(i*step, this.height)
			i++
		ctx.stroke()
	
	# 指定されたマス目を指定された色で塗りつぶす
	fill: (color, x, y) ->
		this.polygonal({
			points: [
				[this.xstep *  x   , this.ystep *  y   ]
				[this.xstep * (x+1), this.ystep *  y   ]
				[this.xstep * (x+1), this.ystep * (y+1)]
				[this.xstep *  x   , this.ystep * (y+1)]
			]
			type: "fs"
			strokeColor: this.gridColor
			fillColor: color
		})
	
	# 指定されたマス目にオセロめいた石を置く
	stone: (color, x, y) ->
		this.circle({
			center: [this.xstep * (x+0.5), this.ystep * (y + 0.5) ]
			radius: Math.min(this.xstep, this.ystep) * 0.4
			fillColor: color
			type: "f"
		})
		
	# 指定されたマス目を背景色に戻す
	clear: (x, y) ->
		this.fill(this.bgColor, x, y)
	
	# クリック時にマス目のx,yを指定してcallbackを実行
	on: (event, callback) ->
		self = this
		this.jqo.on event, (e) ->
			x = Math.floor((e.pageX - self.left) / self.xstep)
			y = Math.floor((e.pageY - self.top)  / self.ystep)
			callback(x,y)

	# これ作っといたほうが綺麗に書ける
	onClick: (callback) ->
		this.on("click", callback)
	onMouseover: (callback) ->
		this.on("mouseover", callback)
	onMouseout: (callback) ->
		this.on("mouseout", callback)

