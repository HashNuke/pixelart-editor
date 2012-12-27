$ ->

  HTMLCanvasElement.prototype.relativeMouseCoordinates = (event)->
    currentElement = this
    totalOffsetX = currentElement.offsetLeft - currentElement.scrollLeft
    totalOffsetY = currentElement.offsetTop  - currentElement.scrollTop

    while(currentElement = currentElement.offsetParent)
      totalOffsetX += currentElement.offsetLeft - currentElement.scrollLeft
      totalOffsetY += currentElement.offsetTop  - currentElement.scrollTop

    return({x: event.pageX - totalOffsetX, y: event.pageY - totalOffsetY})


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


    constructor: (colorPitSelector, paperSelector, previewButtonSelector, clearButtonSelector, downloadButtonSelector, options={})->
      @colorPit = $(colorPitSelector)
      @paper    = $(paperSelector)
      @previewButton = $(previewButtonSelector)
      @clearButton   = $(clearButtonSelector)
      @downloadButton = $(downloadButtonSelector)
      @setOptions(options)
      @brushColor= @colors[0]

      @preparePaper()
      @prepareColorPit()
      @bindEvents()


    setOptions: (options)->
      for option, value of options
        @options[option] = value
      @options.width = @options.height = @options.tileSize * @options.tiles


    preparePaper: ->
      @paper.attr { width: @options.width, height: @options.height }
      @canvas  = @paper[0]
      @context = @canvas.getContext("2d")
      @drawGrid()


    prepareColorPit: ()=>
      @colors.forEach (color)=>
        $("<div/>")
          .css('background', "##{color}")
          .prop("class", "color")
          .data("color", "##{color}")
          .appendTo(@colorPit)


    bindEvents: ()=>
      @colorPit.on "click", ".color", (e)=>
        @brushColor = $(e.currentTarget).data("color")
  
      @previewButton.click  @previewPaper
      @clearButton.click    @clearPaper
      @downloadButton.click @downloadImage
      @paper.click          @drawOnClick


    drawOnClick:  (e)=>
        coords = @canvas.relativeMouseCoordinates(e)
        x = Math.floor(coords.x / @options.tileSize)
        y = Math.floor(coords.y / @options.tileSize)

        @drawnTiles.push {x: x, y: y, color: @brushColor}
        @redrawEverything()


    redrawEverything: ()->
      @context.clearRect(0, 0, @options.width, @options.height)
      for tile in @drawnTiles
        @drawTile(tile.x, tile.y, tile.color)
      @drawGrid()


    drawTile: (x, y, color)->
      @context.fillStyle = color
      @context.lineWidth = 0
      @context.fillRect(
        x * @options.tileSize,
        y * @options.tileSize,
        @options.tileSize,
        @options.tileSize
      )


    drawGrid: ()->
      for i in [0..@options.width] by @options.tileSize
        @context.strokeStyle = "#CCC"
        @context.lineWidth   = 0.5
        
        @context.beginPath()
        @context.moveTo i, 0
        @context.lineTo i, @options.height
        @context.stroke()

        @context.beginPath()
        @context.moveTo 0, i
        @context.lineTo @options.width, i
        @context.stroke()


    downloadImage: ()=>
      window.location.href = @canvas.toDataURL("image/png")
        .replace("image/png", "image/octet-stream")


    previewPaper: (e)=>
      @context.clearRect 0 , 0 , @options.width, @options.height
      for tile in @drawnTiles
        @drawTile(tile.x, tile.y, tile.color)


    clearPaper: (e)=>
      @context.clearRect 0 , 0 , @options.width, @options.height
      @drawnTiles = []
      @drawGrid()

  
  new PaintInterface(
    ".colorpit",
    ".paper",
    "button.preview",
    "button.clear",
    "button.download",
      tiles: 8
      tileSize: 30
  )
