package modules.tiles.tools;

import modules.tiles.TileLayer.TileData;
import modules.tilesets.AutoTileset;
import util.Random;

class TileAirbrushTool extends TileTool
{
	public var drawing:Bool = false;
    public var airbrushAdd:Array<Array<Float>> = null;
	public var radius:Float = 4;

	public var lastMousePos:Vector = null;

	public var masking:Bool = false;
	public var maskRect:Rectangle = null;
    public var clickTopLeft:Vector = null;
    public var clickBottomRight:Vector = null;

    public var random:Random = new Random();

	override public function drawOverlay()
	{
		// drawing the stencil mask
		var drawRect:Rectangle = null;
		if (masking)
		{
        	drawRect = new Rectangle(
        	    clickTopLeft.x, clickTopLeft.y
        	    , (clickBottomRight.x - clickTopLeft.x) + 1, (clickBottomRight.y - clickTopLeft.y) + 1
        	);
		}
		else if (maskRect != null)
		{
			drawRect = maskRect;
		}
		if (drawRect != null)
		{
        	var at = layer.gridToLevel(new Vector(drawRect.x, drawRect.y));
        	var w = drawRect.width * layer.template.gridSize.x;
        	var h = drawRect.height * layer.template.gridSize.y;
        	EDITOR.overlay.drawRect(at.x, at.y, w, h, Color.green.x(0.1));
        	EDITOR.overlay.drawRectLines(at.x, at.y, w, h, Color.green);        
		}

		// drawing the airbrush
        if (drawing)
        {
            var maxLevel:Float = 0;
            for (col in 0...airbrushAdd.length)
            {
                for (row in 0...airbrushAdd[0].length)
                {
                    if (airbrushAdd[col][row] > maxLevel) maxLevel = airbrushAdd[col][row];
                }
            }

            if (maxLevel == 0) return;

            for (col in 0...airbrushAdd.length)
            {
                for (row in 0...airbrushAdd[0].length)
                {
                    var at = layer.gridToLevel(new Vector(col, row));
					var w = layer.template.gridSize.x;
					var h = layer.template.gridSize.y;
                    var addLevel = airbrushAdd[col][row];
					EDITOR.overlay.drawRect(at.x, at.y, w, h, Color.white.x(addLevel * 0.7 / maxLevel));
                }
            }
        }

		if (!drawing && !masking)
		{
			if (lastMousePos != null)
			{
				EDITOR.overlay.drawCircleAlt(
					lastMousePos.x,
					lastMousePos.y,
					radius * layer.template.gridSize.x,
					40,
					Color.white.x(0.7)
				);
			}
		}
	}

	override public function activated()
	{
		drawing = false;
        airbrushAdd = null;
		radius = 4;
		masking = false;
		maskRect = null;
		clickTopLeft = null;
		clickBottomRight = null;
		lastMousePos = null;
	}

	override public function onMouseDown(pos:Vector)
	{
		if (!drawing && !masking)
		{
			drawing = true;
            airbrushAdd = [
                for (x in 0...layer.data.length) [
                    for (y in 0...layer.data[0].length) 0.0
                ]
            ];
            updateAirbrush(pos);
            EDITOR.overlayDirty();
		}
	}

	override public function onMouseUp(pos:Vector)
	{
		if (drawing)
		{
			drawing = false;
            finishAirbrush();
			EDITOR.overlayDirty();
		}
	}

	override public function onRightDown(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (!drawing && !masking)
		{
			masking = true;
        	clickTopLeft = new Vector(pos.x, pos.y);
        	clickBottomRight = new Vector(pos.x, pos.y);
			EDITOR.overlayDirty();
		}
	}

	override public function onRightUp(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (masking)
		{
			masking = false;
			finishMask();
			EDITOR.overlayDirty();
		}
	}

	override public function onMouseMove(pos:Vector)
	{
		lastMousePos = pos;
		if (drawing)
		{
            updateAirbrush(pos);
		}
		else if (masking)
		{
			var gridPos:Vector = layer.levelToGrid(pos);
			updateMask(gridPos);
		}
        EDITOR.overlayDirty();
	}

	override public function onKeyPress(key:Int)
	{
		if (key == Keys.P) {
			radius += 0.5;
		} else if (key == Keys.O) {
			radius -= 0.5;
		}

        EDITOR.overlayDirty();
    }

    public function updateAirbrush(pos:Vector)
    {
		var radiusX:Float = radius * layer.template.gridSize.x;
		var radiusY:Float = radius * layer.template.gridSize.y;
		var topLeft:Vector = new Vector(pos.x - radiusX, pos.y - radiusY);
		var bottomRight:Vector = new Vector(pos.x + radiusX, pos.y + radiusY);
		layer.levelToGrid(topLeft, topLeft);
		layer.levelToGrid(bottomRight, bottomRight);

		for (row in topLeft.y.int()...(bottomRight.y.int() + 1)) {
			for (col in topLeft.x.int()...(bottomRight.x.int() + 1)) {
				if (col < 0 || col >= layer.data.length || row < 0 || row >= layer.data[0].length) continue;
				if (maskRect != null && (
					col < maskRect.left || col >= maskRect.right || row < maskRect.top || row >= maskRect.bottom
				)) continue;

				var tileCenter:Vector = new Vector(col + 0.5, row + 0.5);
				var tileCenterLevel:Vector = layer.gridToLevel(tileCenter);
				var posOffset:Vector = new Vector(
					(pos.x - tileCenterLevel.x) / layer.template.gridSize.x,
					(pos.y - tileCenterLevel.y) / layer.template.gridSize.y
				);
				var distance:Float = Math.sqrt(posOffset.x * posOffset.x + posOffset.y * posOffset.y);

				var currAirbrush = airbrushAdd[col][row];
				var newAirbrush = Math.max(0.0, radius - distance);

				if (newAirbrush > currAirbrush) airbrushAdd[col][row] = newAirbrush;
			}
		}
    }

    public function finishAirbrush()
    {
		EDITOR.level.store("airbrush");

        if (layerEditor.brush.length == 0) return;
        if (layerEditor.brush[0].length == 0) return;
        var brushData:TileData = layerEditor.brush[0][0];
        var autoTileset:AutoTileset = EDITOR.getAutoTileset(brushData.idx, layer.template.name);
        if (autoTileset == null) return;

        for (col in 0...airbrushAdd.length)
        {
            for (row in 0...airbrushAdd[0].length)
            {
				if (airbrushAdd[col][row] <= 0.001) continue;

				var currTile:TileData = layer.data[col][row];
				var radiusTile:TileData = new TileData(airbrushAdd[col][row].int());
				var autotileInput:Array<Array<TileData>> = [
					[radiusTile, currTile]
				];

				var res:TileData = autoTileset.retile(autotileInput, this.random);
                this.layer.data[col][row].copy(res);
            }
        }

		EDITOR.dirty();
    }

	public function updateMask(pos:Vector)
	{
        var newTopLeft:Vector = new Vector(
            Math.min(Math.min(pos.x, clickTopLeft.x), clickBottomRight.x).max(0).min(layer.gridCellsX - 1),
            Math.min(Math.min(pos.y, clickTopLeft.y), clickBottomRight.y).max(0).min(layer.gridCellsY - 1),
        );
        var newBottomRight:Vector = new Vector(
            Math.max(Math.max(pos.x, clickTopLeft.x), clickBottomRight.x).max(0).min(layer.gridCellsX - 1),
            Math.max(Math.max(pos.y, clickTopLeft.y), clickBottomRight.y).max(0).min(layer.gridCellsY - 1),
        );

        clickTopLeft = newTopLeft;
        clickBottomRight = newBottomRight;
	}

	public function finishMask()
	{
		// if the player just right-clicked in place, delete any mask
		if (clickTopLeft.x == clickBottomRight.x && clickTopLeft.y == clickBottomRight.y)
		{
			maskRect = null;
			return;
		}

		// else create a masking rectangle from their clicking
    	maskRect = new Rectangle(
            clickTopLeft.x, clickTopLeft.y
            , (clickBottomRight.x - clickTopLeft.x) + 1, (clickBottomRight.y - clickTopLeft.y) + 1
        );
	}

	override public function getName():String return "Airbrush";
	override public function getIcon():String return "layers-clear";
}