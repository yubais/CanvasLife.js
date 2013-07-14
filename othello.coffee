# 0: 何もない
# 1: 黒石
# 2: 白石
# 自分が n の場合、相手は (3-n)

# chekcStone: 石を置けるかどうか確認
# setStone: 石を置く一連の流れ
# putStone: 石を置く (mapを更新して描写)
# 初期配置の生成には putStone だけを用いる
# reverse: それによる石の反転

class Othello extends Grid

	# クラス変数
	black = "#000000"
	white = "#ffffff"
	directions = [
		[-1,-1]
		[-1, 0]
		[-1,+1]
		[ 0,-1]
		[ 0,+1]
		[+1,-1]
		[+1, 0]
		[+1,+1]
	]

	constructor: (jqo, args) ->
		args.gridColor = "#000000"
		args.bgColor = "#008800"
		args.cols = 8 if args.cols? == false
		args.rows = 8 if args.rows? == false
		super(jqo, args)
		this.phase = 0
		this.initialize()
	
	# --------------------------------------------------
	initialize: ->
		self = this

		# 初期マップを作成 (0ばっかりの2次元リスト)
		this.map = {}
		for x in [-1 .. this.cols]
			this.map[x] = {}
			for y in [-1 .. this.rows]
				this.map[x][y] = 0
		xc = Math.floor(this.cols / 2) - 1
		yc = Math.floor(this.rows / 2) - 1

		# 4石を設置
		this.putStone(xc  , yc  , 2)
		this.putStone(xc+1, yc  , 1)
		this.putStone(xc  , yc+1, 1)
		this.putStone(xc+1, yc+1, 2)

		this.onClick( (x,y) ->
			self.setStone(x,y)
		)
		this.changePhase()
	
	# --------------------------------------------------
	# マウスオン時に石が置けるかどうか判定
	# onmouseover をグリッドごとにするのが面倒なので断念
		
	# --------------------------------------------------
	# 石を置いてthis.mapを更新する
	putStone: (x, y, color)->
		if color == 1
			this.stone(black, x, y)
			this.map[x][y] = 1
		if color == 2
			this.stone(white, x, y)
			this.map[x][y] = 2
	
	# --------------------------------------------------
	# 石を置いた場合の一連の処理
	setStone: (x,y) ->
		# 石が置けるかどうかの判定
		if this.checkStone(x,y) == false
			# 置けない場合のコールバックをするべき？
			console.log "そこに石は置けない"
			return false

		this.putStone(x,y,this.phase)
		for d in directions
			if this.checkDirection(x,y,d)
				this.reverse(x,y,d)

		this.changePhase()

	# --------------------------------------------------
	# 指定位置に石がおけるか確認
	checkStone: (x,y) ->
		if this.map[x][y] != 0
			return false

		opponent = 3 - this.phase
		around = this.around(x,y)

		# 周囲8方向に相手の石がなければ false
		# この処理は後述の処理と重複するが、クイックチェック的に実行
		if opponent in around == false
			return false

		# 周囲8方向が反転可能かチェック
		result = []
		for d in directions
			if this.map[x + d[0]][y + d[1]] == opponent
				result.push(this.checkDirection(x + d[0], y + d[1], d))

		# resultが要素ゼロの可能性もあるのでANDは使わない
		if true in result
			return true
		else
			return false

	# --------------------------------------------------
	# 特定位置に対し、その周囲8ヶ所の値を返す
	around: (x,y) ->
		result = []
		for d in directions
			result.push(this.map[x + d[0]][y + d[1]])
		return result

	# --------------------------------------------------
	# 特定方向に反転可能かチェック
	# 最初の1個が敵側であることを確認してから実行されたし
	checkDirection: (x,y,d) ->
		# その方向に石がなければ反転不可能
		if this.map[x + d[0]][y + d[1]] == 0
			return false
		# その方向に自分の石があれば反転可能
		if this.map[x + d[0]][y + d[1]] == this.phase
			return true
		# その方向に相手の石があれば再帰
		if this.map[x + d[0]][y + d[1]] == 3 - this.phase
			return this.checkDirection(x + d[0], y + d[1], d)

	# --------------------------------------------------
	# 置かれた石のまわりの石を反転
	reverse: (x, y, d) ->
		if this.map[x + d[0]][y + d[1]] == 0
			return false
		if this.map[x + d[0]][y + d[1]] == this.phase
			return true
		if this.map[x + d[0]][y + d[1]] == 3 - this.phase
			this.putStone(x+d[0], y+d[1], this.phase)
			this.reverse(x+d[0], y+d[1], d)

	# --------------------------------------------------
	# 手番を反転
	changePhase: ->
		console.log this.phase
		this.phase = 3 - this.phase if this.phase > 0
		this.phase = 1 if this.phase == 0

		this.countStone()

		if this.count.total >= 64
			if this.count[1] > this.count[2]
				$("#console").text("黒番の勝利 | 黒#{this.count[1]}, 白#{this.count[2]}")
			else if this.count[1] < this.count[2]
				$("#console").text("白番の勝利 | 黒#{this.count[1]}, 白#{this.count[2]}")
			else
				$("#console").text("引き分け | 黒#{this.count[1]}, 白#{this.count[2]}")
			this.phase = 3
			
		if this.phase == 1
			$("#console").text("黒番です | 黒#{this.count[1]}, 白#{this.count[2]}")
		if this.phase == 2
			$("#console").text("白番です | 黒#{this.count[1]}, 白#{this.count[2]}")

	# --------------------------------------------------
	# 石を数える
	countStone: ->
		this.count = {
			0: 0 # 空白
			1: 0 # 黒石
			2: 0 # 白石
			total: 0
		}

		for x in [-1 .. this.cols]
			for y in [-1 .. this.rows]
				this.count[this.map[x][y]]++
				#this.count[point]++

		this.count.total = this.count[1] + this.count[2]

