# とりあえずHTML5のCanvas要素を扱いやすくしたクラス
class Canvas
	constructor: (dom) ->
		this.dom = dom
		this.width = Number(dom.attr('width'))
		this.height = Number(dom.attr('height'))
		this.offset()
	
	# contextを取得。書くのがめんどいのでメソッド化
	ctx: ->
		return this.dom[0].getContext('2d')

	# グリッドを描写。direction = 'vertical' or 'horizontal'
	grid: (direction, step, color) ->
		ctx = this.ctx()
		ctx.beginPath()
		ctx.strokeStyle = color

		i = 0
		while i * step < this.width
			if direction == "horizontal"
				ctx.moveTo(0, i*step)
				ctx.lineTo(this.width, i*step)
			else
				ctx.moveTo(i*step, 0)
				ctx.lineTo(i*step, this.height)
			i++
		ctx.stroke()
	
	# 画面上における4辺の位置を取得
	offset: ->
		tmp = this.dom.offset()
		this.left = tmp.left
		this.top = tmp.top
		this.right = tmp.left + this.width
		this.bottom = tmp.top + this.height

# グリッドの概念を入れる
class Grid extends Canvas
	constructor: (dom, cols, rows) ->
		super(dom)
		this.gridColor = "#000"
		this.bgColor = "#080"
		this.cols = cols
		this.rows = rows
		this.xstep = this.width / this.cols
		this.ystep = this.height / this.rows
		this.clear()
		this.getClick()

	# canvasを消去してグリッド線を引く
	clear: ->
		this.dom.css("background-color",this.bgColor)
		clear = this.ctx()
		clear.clearRect(0,0,this.width,this.height)
		this.grid('vertical', this.xstep, this.gridColor)
		this.grid('horizontal', this.ystep, this.gridColor)

	# 指定した座標のマス目を塗りつぶす
	fill: (color, x, y) ->
		ctx = this.ctx()
		ctx.beginPath()
		ctx.fillStyle = color
		ctx.strokeStyle = this.gridColor
		ctx.moveTo(this.xstep * x, this.ystep * y)
		ctx.lineTo(this.xstep * (x+1), this.ystep * y)
		ctx.lineTo(this.xstep * (x+1), this.ystep * (y+1))
		ctx.lineTo(this.xstep * x, this.ystep * (y+1))
		ctx.closePath()
		ctx.fill()
		ctx.stroke()

	# 指定した座標のマス目を丸く塗りつぶす
	fillRound: (color, x, y) ->
		ctx = this.ctx()
		ctx.beginPath()
		ctx.fillStyle = color
		radius = Math.min(this.xstep, this.ystep) / 2 * 0.8
		ctx.arc(this.xstep * (x + 0.5), this.ystep * (y + 0.5), radius, 0, 2*3.14159265, false)
		#ctx.arc(this.ystep * (y + 0.5), this.xstep * (x + 0.5), radius, 0, 2*3.14159265, false)
		ctx.fill()
	
	# 塗りつぶしを消去
	unfill: (x, y) ->
		this.fill(this.bgColor,x,y)
	
	# クリックイベントを設置
	getClick: ->
		self = this
		this.dom.click (e)->
			x = Math.floor((e.clientX - self.left) / self.xstep)
			y = Math.floor((e.clientY - self.top)  / self.ystep)
			if self.console?
				self.console.text(x + "," + y)
			else
				console.log x, y
			if self.onclick?
				self.onclick(x,y)

# セルオートマトンの汎用クラス
class Cellautomaton extends Grid
	# パラメータを設定
	constructor: (dom, cols, rows, divisionRate, deathRate, initialPlayers) ->
		super(dom, cols, rows)
		this.divisionRate = divisionRate
		this.deathRate = deathRate
		this.initialPlayers = initialPlayers
		this.interval = 100

		this.setDOMs()
		this.initialize()

	# 画面とコンソールを設定
	setDOMs: ->
		self = this
		if this.dom.parents(".game")?
			this.region = this.dom.parent(".game")
		else
			return false

		this.console = this.region.find(".console")
			
	# プレイヤーを配置して時刻をゼロに
	initialize: ->
		console.log "initialize"

	# setIntervalを実行（すでに実行中のものがあれば消去してから実行）
	start: ->
		self = this
		if this.timer?
			clearInterval(this.timer)
		this.timer = setInterval( () ->
			self.progress()
		, this.interval)
	
	# setIntervalを停止
	stop: ->
		if this.timer?
			clearInterval(this.timer)
	
	# 1時刻ごとの処理
	progress: ->
		console.log "progress"

class Point
	constructor: (x, y, color, footnote) ->
		this.x = x
		this.y = y
		this.color = color
		if footnote?
			this.footnote = footnote

	randomWalk: () ->
		d = Math.floor(Math.random() * 5) # direction of random walk
		this.x += 1 if d == 0
		this.x -= 1 if d == 1
		this.y += 1 if d == 2
		this.y -= 1 if d == 3
	
