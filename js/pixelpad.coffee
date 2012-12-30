$ ->

  class PaintInterface

    options:
      tiles:    10
      tileSize: 20
      width:    200
      height:   200

    drawnTiles: []

    colors: [
      "d73952", "f65c50", "ff9459",           # red shades
      "46ad42", "099c55", "8ac273",           # green shades
      "2dbfe8", "72669e", "5d3aae", "aa5886", # blue shades
      "ffe2a8", "ffff7d",                     # yellow shades
      "ffffff", "dddddd", "98989d", "333333"  # white, black, grey
    ]


    constructor: (colorPitSelector, paperSelector, clearButtonSelector, downloadButtonSelector, options={})->
      @colorPit = $(colorPitSelector)
      @paper    = $(paperSelector)
      @clearButton    = $(clearButtonSelector)
      @downloadButton = $(downloadButtonSelector)
      @setOptions(options)
      @brushColor= @colors[0]

      @preparePaper()
      @prepareCanvas()
      @prepareColorPit()
      @bindEvents()


    setOptions: (options)->
      for option, value of options
        @options[option] = value
      @options.width = @options.height = @options.tileSize * @options.tiles


    prepareCanvas: =>
      @canvasElement = $("<canvas/>")
      @canvasElement.attr
        width:  @options.width
        height: @options.height

    preparePaper: ->
      for i in [0...(@options.tiles * @options.tiles)]
        $("<div class='tile'/>").appendTo(@paper)
      @paper.css({"width": @options.width + (@options.tiles * 2)})

    prepareColorPit: ->
      @colors.forEach (color)=>
        $("<div/>")
          .css('background', "##{color}")
          .prop("class", "color")
          .data("color", "#{color}")
          .appendTo(@colorPit)


    bindEvents: ->
      @colorPit.on "click", ".color", (e)=>
        @brushColor = $(e.currentTarget).data("color")
  
      @clearButton.click    @clearPaper
      @downloadButton.click @downloadImage
      @paper.on "click", ".tile", @drawOnClick


    drawOnClick: (e)=>
      $target = $(e.currentTarget)
      $target.css('background', "##{@brushColor}")
      x = Math.floor($target.prevAll().length % @options.tiles)
      y = Math.floor($target.prevAll().length / @options.tiles)
      @drawnTiles.push {x: x, y: y, color: @brushColor}


    downloadImage: ()=>
      canvas  = @canvasElement[0]
      context = canvas.getContext("2d")
      context.clearRect 0 , 0 , @options.width, @options.height
      for tile in @drawnTiles
        context.fillStyle = tile.color
        context.lineWidth = 0
        context.fillRect(
          tile.x * @options.tileSize,
          tile.y * @options.tileSize,
          @options.tileSize,
          @options.tileSize
        )

      window.location.href = canvas.toDataURL("image/png")
        .replace("image/png", "image/octet-stream")


    previewPaper: (e)=>
      @context.clearRect 0 , 0 , @options.width, @options.height
      for tile in @drawnTiles
        @drawTile(tile.x, tile.y, tile.color)


    clearPaper: (e)=>
      @paper.find(".tile").css("background-color", "#FFF")
  
  new PaintInterface(
    ".colorpit",
    ".paper",
    "button.clear",
    "button.download",
      tiles: 8
      tileSize: 30
  )
