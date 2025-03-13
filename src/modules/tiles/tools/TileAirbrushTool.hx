package modules.tiles.tools;

import modules.tiles.TileLayer.TileData;
import modules.tilesets.AutoTileset;
import util.Random;

class TileAirbrushTool extends TileTool
{
	public var drawing:Bool = false;
    public var airbrushAdd:Array<Array<Float>> = null;
	public var radius:Float = 4;

    public var random:Random = new Random();

	override public function drawOverlay()
	{
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
					EDITOR.overlay.drawRect(at.x, at.y, w, h, Color.white.x(addLevel * 1.0 / maxLevel));
                }
            }
        }
	}

	override public function activated()
	{
		drawing = false;
        airbrushAdd = null;
	}

	override public function onMouseDown(pos:Vector)
	{
		if (!drawing)
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
		}
	}

	override public function onMouseMove(pos:Vector)
	{
		if (drawing)
		{
            updateAirbrush(pos);
            EDITOR.overlayDirty();
		}
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

	override public function getName():String return "Airbrush";
	override public function getIcon():String return "layers-clear";
}