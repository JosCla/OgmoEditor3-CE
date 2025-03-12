package modules.tiles.tools;

import modules.tiles.TileLayer.TileData;

class TileAirbrushTool extends TileTool
{
	public var drawing:Bool = false;
    public var airbrushAdd:Array<Array<Int>> = null;

	override public function drawOverlay()
	{
        if (drawing)
        {
            var maxLevel:Int = 0;
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
		layer.levelToGrid(pos, pos);

		if (!drawing)
		{
			drawing = true;
            airbrushAdd = [
                for (x in 0...layer.data.length) [
                    for (y in 0...layer.data[0].length) 0
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
		    EDITOR.level.store("create decal");
			drawing = false;
            finishAirbrush();
			EDITOR.dirty();
		}
	}

	override public function onMouseMove(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (drawing)
		{
            updateAirbrush(pos);
            EDITOR.overlayDirty();
		}
	}

    /*
	override public function onRightDown(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (!drawing)
		{
			drawing = true;
			deleting = true;
			start = end = pos;
			brush = [[new TileData()]];
			updateLine();
		}
	}

	override public function onRightUp(pos:Vector)
	{
		if (drawing)
		{
			drawing = false;
			deleting = false;
			doDraw();
			EDITOR.dirty();
		}
	}
	
	override public function onKeyPress(key:Int)
	{
		super.onKeyPress(key);

		if (OGMO.keyIsCtrl(key))
			EDITOR.overlayDirty();
	}
	
	override public function onKeyRelease(key:Int)
	{
		if (OGMO.keyIsCtrl(key))
		{
			random.randomize();
			EDITOR.overlayDirty();
		}
	}
    */

    public function updateAirbrush(pos:Vector)
    {
        // TODO
        airbrushAdd[pos.x.int()][pos.y.int()] += 1;
    }

    public function finishAirbrush()
    {
        // TODO
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