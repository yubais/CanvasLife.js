class Grid extends Canvas
	constructor: (jqo, args) ->
		super(jqo)
		this.gridColor = "#000"
		this.bgColor = "#080"
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
