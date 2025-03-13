package modules.tiles.tools;

import modules.tiles.TileLayer.TileData;

class TileAirbrushTool extends TileTool
{
	public var drawing:Bool = false;
    public var airbrushAdd:Array<Array<Float>> = null;
	public var radius:Float = 5;

	override public function drawOverlay()
	{
        if (drawing)
        {
            var maxLevel:Float = 0;
            for (col in 0...airbrushAdd.length)
            {
                for (row in 0...airbrushAdd.length)
                {
                    if (airbrushAdd[col][row] > maxLevel) maxLevel = airbrushAdd[col][row];
                }
            }

            if (maxLevel == 0) return;

            for (col in 0...airbrushAdd.length)
            {
                for (row in 0...airbrushAdd.length)
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
		// layer.levelToGrid(pos, pos);

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
		// layer.levelToGrid(pos, pos);

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
        // TODO
		EDITOR.level.store("airbrush");
		EDITOR.dirty();
    }

    /*
	public function doDraw()
	{
		if (anyChanges)
		{
			var random:Random = null;
			if (OGMO.ctrl)
				random = this.random;
			EDITOR.level.store("line fill");

			for (p in points)
			{
				if (layer.insideGrid(p)) layer.data[p.x.int()][p.y.int()].copy(brushAt(brush, start.x.int(), start.y.int(), end.x.int(), start.y.int(), p.x.int(), p.y.int(), random));
			}
		}
	}

	public function updateLine()
	{
		points = Calc.bresenham(start.x.int(), start.y.int(), end.x.int(), end.y.int());
		EDITOR.overlayDirty();
	}

	public var anyChanges(get, never):Bool;
	function get_anyChanges():Bool
	{
		var ret = false;

		var random:Random = null;
		if (OGMO.ctrl)
		{
			random = this.random;
			random.pushState();
		}

		for (p in points)
		{
			if (layer.insideGrid(p))
			{
				if (!layer.data[p.x.int()][p.y.int()].equals(brushAt(brush, start.x.int(), start.y.int(), end.x.int(), start.y.int(), p.x.int(), p.y.int(), random)))
				{
					ret = true;
					break;
				}
			}
		}

		if (random != null)
			random.popState();

		return ret;
	}
    */

	override public function getName():String return "Airbrush";
	override public function getIcon():String return "layers-clear";
}