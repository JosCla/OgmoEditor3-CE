package modules.tiles.tools;

import util.Random;
import modules.tiles.TileLayer.TileData;

class TileLineTool extends TileTool
{
	public var drawing:Bool = false;
	public var deleting:Bool = false;
	public var brush:Array<Array<TileData>>;
	public var start:Vector = new Vector();
	public var end:Vector = new Vector();
	public var points:Array<Vector>;
	public var random:Random = new Random();

	override public function drawOverlay()
	{
		if (deleting)
		{
			for (p in points)
			{
				if (layer.insideGrid(p))
				{
					var at = layer.gridToLevel(p);
					var w = layer.template.gridSize.x;
					var h = layer.template.gridSize.y;
					EDITOR.overlay.drawRect(at.x, at.y, w, h, Color.red.x(0.5));
				}
			}
		}
		else if (drawing)
		{
			var random:Random = null;
			if (OGMO.ctrl)
			{
				random = this.random;
				random.pushState();
			}
			
			EDITOR.overlay.setAlpha(0.5);
			for (p in points)
			{
				if (layer.insideGrid(p))
				{
					var at = layer.gridToLevel(p);
					EDITOR.overlay.drawTile(at.x, at.y, layer.tileset, brushAt(brush, start.x.int(), start.y.int(), end.x.int(), end.y.int(), p.x.int(), p.y.int(), random));
				}
			}
			EDITOR.overlay.setAlpha(1);

			if (random != null) random.popState();
		}
	}

	override public function activated()
	{
		drawing = false;
	}

	override public function onMouseDown(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (!drawing)
		{
			drawing = true;
			deleting = false;
			start = end = pos;
			brush = layerEditor.brush;
			updateLine();
		}
	}

	override public function onMouseUp(pos:Vector)
	{
		if (drawing)
		{
			drawing = false;
			deleting = false;
			doDraw();
			EDITOR.dirty();
		}
	}

	override public function onMouseMove(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (drawing && !pos.equals(end))
		{
			end = pos;
			updateLine();
		}
	}

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

	override public function getName():String return "Line";
	override public function getIcon():String return "line";
	override public function keyToolAlt():Int return 4;
}