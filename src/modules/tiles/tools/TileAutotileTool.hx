package modules.tiles.tools;

import modules.tilesets.AutoTileset;
import util.Random;
import modules.tiles.TileLayer.TileData;

class TileAutotileTool extends TileTool
{
    public var clickTopLeft:Vector = null;
    public var clickBottomRight:Vector = null;
	public var random:Random = new Random();

    public var testTileset:AutoTileset;

	override public function drawOverlay()
	{
        if (clickTopLeft != null && clickBottomRight != null)
		{
            var rect:Rectangle = getClickRect();
		    var at = layer.gridToLevel(new Vector(clickTopLeft.x, clickTopLeft.y));
		    var w = rect.width * layer.template.gridSize.x;
		    var h = rect.height * layer.template.gridSize.y;
		    EDITOR.overlay.drawRect(at.x, at.y, w, h, Color.green.x(0.1));
		    EDITOR.overlay.drawRectLines(at.x, at.y, w, h, Color.green);		
		}
        else 
        {
		    EDITOR.overlay.drawRect(5, 5, 24, 36, Color.green.x(0.1));
		    EDITOR.overlay.drawRectLines(5, 5, 24, 36, Color.green);		
        }
	}

	override public function activated()
	{
        clickTopLeft = null;
        clickBottomRight = null;
        this.testTileset = new AutoTileset(layer.level);
	}

	override public function onMouseDown(pos:Vector)
	{
		layer.levelToGrid(pos, pos);
        pos.clone(clickTopLeft);
        pos.clone(clickBottomRight);

	}

	override public function onMouseUp(pos:Vector)
	{
        // todo

        Popup.open("hi", "entity", "here it is: " + clickTopLeft.x, ["sure."]);
        clickTopLeft = null;
        clickBottomRight = null;
	}

	override public function onMouseMove(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

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

    public function getClickRect()
    {
        return new Rectangle(
            clickTopLeft.x, clickTopLeft.y
            , (clickBottomRight.x - clickTopLeft.x), (clickBottomRight.y - clickTopLeft.y)
        );
    }
	
	override public function onKeyRelease(key:Int)
	{
        // todo
	}

	override public function getIcon():String return 'value-color';
	override public function getName():String return 'AutoTile';
	override public function keyToolAlt():Int return 4;
	override public function keyToolShift():Int return 0;

    override public function getExtraInfo():String {
        var rect: Rectangle = getClickRect();
        var size: Vector = new Vector(rect.width, rect.height);
        return " " + (Math.abs(size.x)+1) + " x " + (Math.abs(size.y)+1);
    }
}