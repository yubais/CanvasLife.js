// Generated by CoffeeScript 1.6.1
var Canvas, Grid, Othello,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Canvas = (function() {

  function Canvas(jqo, defaultStyle) {
    this.jqo = jqo;
    this.width = Number(jqo.attr("width"));
    this.height = Number(jqo.attr("height"));
    this.offset();
    this["default"] = {};
    if (defaultStyle) {
      if (defaultStyle.strokeColor !== void 0) {
        this["default"].strokeColor = defaultStyle.strokeColor;
      }
      if (defaultStyle.fillColor !== void 0) {
        this["default"].fillColor = defaultStyle.fillColor;
      }
    }
  }

  Canvas.prototype.ctx = function() {
    return this.jqo[0].getContext("2d");
  };

  Canvas.prototype.offset = function() {
    var tmp;
    tmp = this.jqo.offset();
    this.left = tmp.left;
    this.top = tmp.top;
    this.right = tmp.left + this.width;
    return this.bottom = tmp.top + this.height;
  };

  Canvas.drawPath = function(ctx, type) {
    if (type === "s") {
      ctx.stroke();
    }
    if (type === "f") {
      ctx.fill();
    }
    if (type === "fs") {
      ctx.fill();
      return ctx.stroke();
    }
  };

  Canvas.prototype.polylinePath = function(ctx, points) {
    var p, _i, _len, _results;
    ctx.beginPath();
    if ((points != null) === false) {
      throw new Error("CanvasLife Error: missing of points");
      return false;
    }
    _results = [];
    for (_i = 0, _len = points.length; _i < _len; _i++) {
      p = points[_i];
      _results.push(ctx.lineTo(p[0], p[1]));
    }
    return _results;
  };

  Canvas.prototype.setCtxStyle = function(ctx, style) {
    if (style != null) {
      if (style.strokeWidth === void 0) {
        ctx.lineWidth = this["default"].strokeWidth;
      } else {
        ctx.lineWidth = style.strokeWidth;
      }
      if (style.strokeColor === void 0) {
        ctx.strokeStyle = this["default"].strokeColor;
      } else {
        ctx.strokeStyle = style.strokeColor;
      }
      if (style.fillColor === void 0) {
        return ctx.fillStyle = this["default"].fillColor;
      } else {
        return ctx.fillStyle = style.fillColor;
      }
    }
  };

  Canvas.prototype.line = function(args) {
    var ctx;
    ctx = this.ctx();
    this.setCtxStyle(ctx, args);
    this.polylinePath(ctx, args.points);
    return ctx.stroke();
  };

  Canvas.prototype.polygonal = function(args) {
    var ctx;
    ctx = this.ctx();
    this.setCtxStyle(ctx, args);
    this.polylinePath(ctx, args.points);
    ctx.closePath();
    return Canvas.drawPath(ctx, args.type);
  };

  Canvas.prototype.circle = function(args) {
    var ctx;
    ctx = this.ctx();
    this.setCtxStyle(ctx, args);
    ctx.beginPath();
    if (args.center[0] && args.center[1] && args.radius && args.type) {
      ctx.arc(args.center[0], args.center[1], args.radius, 0, Math.PI * 2);
      return Canvas.drawPath(ctx, args.type);
    } else {
      console.log(args);
      throw new Error("CanvasLife Error: Invalid Parameters");
    }
  };

  Canvas.prototype.allClear = function() {
    var ctx;
    ctx = this.ctx();
    return ctx.clearRect(0, 0, this.width, this.height);
  };

  return Canvas;

})();

Grid = (function(_super) {

  __extends(Grid, _super);

  function Grid(jqo, args) {
    Grid.__super__.constructor.call(this, jqo);
    this.gridColor = "#000000";
    if (args.gridColor != null) {
      this.gridColor = args.gridColor;
    }
    this.bgColor = "#ffffff";
    if (args.bgColor != null) {
      this.bgColor = args.bgColor;
    }
    this.cols = args.cols;
    this.rows = args.rows;
    this.xstep = this.width / this.cols;
    this.ystep = this.height / this.rows;
    this.jqo.css("background-color", this.bgColor);
    this.jqo.css("border", "solid 1px " + this.gridColor);
    this.drawGrid('vertical', this.xstep, this.gridColor);
    this.drawGrid('horizontal', this.ystep, this.gridColor);
  }

  Grid.prototype.drawGrid = function(direction, step, color) {
    var ctx, i;
    ctx = this.ctx();
    ctx.beginPath();
    ctx.strokeStyle = color;
    i = 1;
    while (i * step < this.width) {
      if (direction === "horizontal") {
        ctx.moveTo(0, i * step);
        ctx.lineTo(this.width, i * step);
      } else {
        ctx.moveTo(i * step, 0);
        ctx.lineTo(i * step, this.height);
      }
      i++;
    }
    return ctx.stroke();
  };

  Grid.prototype.fill = function(color, x, y) {
    return this.polygonal({
      points: [[this.xstep * x, this.ystep * y], [this.xstep * (x + 1), this.ystep * y], [this.xstep * (x + 1), this.ystep * (y + 1)], [this.xstep * x, this.ystep * (y + 1)]],
      type: "fs",
      strokeColor: this.gridColor,
      fillColor: color
    });
  };

  Grid.prototype.stone = function(color, x, y) {
    return this.circle({
      center: [this.xstep * (x + 0.5), this.ystep * (y + 0.5)],
      radius: Math.min(this.xstep, this.ystep) * 0.4,
      fillColor: color,
      type: "f"
    });
  };

  Grid.prototype.clear = function(x, y) {
    return this.fill(this.bgColor, x, y);
  };

  Grid.prototype.on = function(event, callback) {
    var self;
    self = this;
    return this.jqo.on(event, function(e) {
      var x, y;
      x = Math.floor((e.clientX - self.left) / self.xstep);
      y = Math.floor((e.clientY - self.top) / self.ystep);
      return callback(x, y);
    });
  };

  Grid.prototype.onClick = function(callback) {
    return this.on("click", callback);
  };

  Grid.prototype.onMouseover = function(callback) {
    return this.on("mouseover", callback);
  };

  Grid.prototype.onMouseout = function(callback) {
    return this.on("mouseout", callback);
  };

  return Grid;

})(Canvas);

Othello = (function(_super) {
  var black, directions, white;

  __extends(Othello, _super);

  black = "#000000";

  white = "#ffffff";

  directions = [[-1, -1], [-1, 0], [-1, +1], [0, -1], [0, +1], [+1, -1], [+1, 0], [+1, +1]];

  function Othello(jqo, args) {
    args.gridColor = "#000000";
    args.bgColor = "#008800";
    if ((args.cols != null) === false) {
      args.cols = 8;
    }
    if ((args.rows != null) === false) {
      args.rows = 8;
    }
    Othello.__super__.constructor.call(this, jqo, args);
    this.phase = 0;
    this.initialize();
  }

  Othello.prototype.initialize = function() {
    var self, x, xc, y, yc, _i, _j, _ref, _ref1;
    self = this;
    this.map = {};
    for (x = _i = -1, _ref = this.cols; -1 <= _ref ? _i <= _ref : _i >= _ref; x = -1 <= _ref ? ++_i : --_i) {
      this.map[x] = {};
      for (y = _j = -1, _ref1 = this.rows; -1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = -1 <= _ref1 ? ++_j : --_j) {
        this.map[x][y] = 0;
      }
    }
    xc = Math.floor(this.cols / 2) - 1;
    yc = Math.floor(this.rows / 2) - 1;
    this.putStone(xc, yc, 2);
    this.putStone(xc + 1, yc, 1);
    this.putStone(xc, yc + 1, 1);
    this.putStone(xc + 1, yc + 1, 2);
    this.onClick(function(x, y) {
      return self.setStone(x, y);
    });
    return this.changePhase();
  };

  Othello.prototype.putStone = function(x, y, color) {
    if (color === 1) {
      this.stone(black, x, y);
      this.map[x][y] = 1;
    }
    if (color === 2) {
      this.stone(white, x, y);
      return this.map[x][y] = 2;
    }
  };

  Othello.prototype.setStone = function(x, y) {
    var d, _i, _len;
    if (this.checkStone(x, y) === false) {
      console.log("そこに石は置けない");
      return false;
    }
    this.putStone(x, y, this.phase);
    for (_i = 0, _len = directions.length; _i < _len; _i++) {
      d = directions[_i];
      if (this.checkDirection(x, y, d)) {
        this.reverse(x, y, d);
      }
    }
    return this.changePhase();
  };

  Othello.prototype.checkStone = function(x, y) {
    var around, d, opponent, result, _i, _len;
    if (this.map[x][y] !== 0) {
      return false;
    }
    opponent = 3 - this.phase;
    around = this.around(x, y);
    if (__indexOf.call(around, opponent) >= 0 === false) {
      return false;
    }
    result = [];
    for (_i = 0, _len = directions.length; _i < _len; _i++) {
      d = directions[_i];
      if (this.map[x + d[0]][y + d[1]] === opponent) {
        result.push(this.checkDirection(x + d[0], y + d[1], d));
      }
    }
    if (__indexOf.call(result, true) >= 0) {
      return true;
    } else {
      return false;
    }
  };

  Othello.prototype.around = function(x, y) {
    var d, result, _i, _len;
    result = [];
    for (_i = 0, _len = directions.length; _i < _len; _i++) {
      d = directions[_i];
      result.push(this.map[x + d[0]][y + d[1]]);
    }
    return result;
  };

  Othello.prototype.checkDirection = function(x, y, d) {
    if (this.map[x + d[0]][y + d[1]] === 0) {
      return false;
    }
    if (this.map[x + d[0]][y + d[1]] === this.phase) {
      return true;
    }
    if (this.map[x + d[0]][y + d[1]] === 3 - this.phase) {
      return this.checkDirection(x + d[0], y + d[1], d);
    }
  };

  Othello.prototype.reverse = function(x, y, d) {
    if (this.map[x + d[0]][y + d[1]] === 0) {
      return false;
    }
    if (this.map[x + d[0]][y + d[1]] === this.phase) {
      return true;
    }
    if (this.map[x + d[0]][y + d[1]] === 3 - this.phase) {
      this.putStone(x + d[0], y + d[1], this.phase);
      return this.reverse(x + d[0], y + d[1], d);
    }
  };

  Othello.prototype.changePhase = function() {
    console.log(this.phase);
    if (this.phase > 0) {
      this.phase = 3 - this.phase;
    }
    if (this.phase === 0) {
      this.phase = 1;
    }
    this.countStone();
    if (this.count.total >= 64) {
      if (this.count[1] > this.count[2]) {
        $("#console").text("黒番の勝利 | 黒" + this.count[1] + ", 白" + this.count[2]);
      } else if (this.count[1] < this.count[2]) {
        $("#console").text("白番の勝利 | 黒" + this.count[1] + ", 白" + this.count[2]);
      } else {
        $("#console").text("引き分け | 黒" + this.count[1] + ", 白" + this.count[2]);
      }
      this.phase = 3;
    }
    if (this.phase === 1) {
      $("#console").text("黒番です | 黒" + this.count[1] + ", 白" + this.count[2]);
    }
    if (this.phase === 2) {
      return $("#console").text("白番です | 黒" + this.count[1] + ", 白" + this.count[2]);
    }
  };

  Othello.prototype.countStone = function() {
    var x, y, _i, _j, _ref, _ref1;
    this.count = {
      0: 0,
      1: 0,
      2: 0,
      total: 0
    };
    for (x = _i = -1, _ref = this.cols; -1 <= _ref ? _i <= _ref : _i >= _ref; x = -1 <= _ref ? ++_i : --_i) {
      for (y = _j = -1, _ref1 = this.rows; -1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = -1 <= _ref1 ? ++_j : --_j) {
        this.count[this.map[x][y]]++;
      }
    }
    return this.count.total = this.count[1] + this.count[2];
  };

  return Othello;

})(Grid);