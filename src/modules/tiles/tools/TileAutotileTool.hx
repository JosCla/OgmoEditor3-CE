package modules.tiles.tools;

import modules.tilesets.TopLayerTileset;
import util.Random;
import modules.tiles.TileLayer.TileData;

class TileAutotileTool extends TileTool
{
    public var clickTopLeft:Vector = null;
    public var clickBottomRight:Vector = null;
    public var random:Random = new Random();

    public var testTileset:TopLayerTileset;

    public static var greyTile:Int = 544;

    override public function drawOverlay()
    {
        if (isClicking())
        {
            var rect:Rectangle = getClickRect();
            var at = layer.gridToLevel(new Vector(clickTopLeft.x, clickTopLeft.y));
            var w = rect.width * layer.template.gridSize.x;
            var h = rect.height * layer.template.gridSize.y;
            EDITOR.overlay.drawRect(at.x, at.y, w, h, Color.green.x(0.1));
            EDITOR.overlay.drawRectLines(at.x, at.y, w, h, Color.green);        
        }
    }

    override public function activated()
    {
        clickTopLeft = null;
        clickBottomRight = null;
        this.testTileset = new TopLayerTileset(layer.level);
    }

    override public function onMouseDown(pos:Vector)
    {
        layer.levelToGrid(pos, pos);
        clickTopLeft = new Vector(pos.x, pos.y);
        clickBottomRight = new Vector(pos.x, pos.y);
        EDITOR.overlayDirty();
    }

    override public function onMouseUp(pos:Vector)
    {
        if (isClicking())
        {
            autoTileRect(getClickRect());

            clickTopLeft = null;
            clickBottomRight = null;
            EDITOR.overlayDirty();
        }
    }

    override public function onMouseMove(pos:Vector)
    {
        if (isClicking())
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

            EDITOR.overlayDirty();
        }
    }

    public function isClicking()
    {
        return (clickTopLeft != null && clickBottomRight != null);
    }

    public function getClickRect()
    {
        if (!isClicking()) return null;

        return new Rectangle(
            clickTopLeft.x, clickTopLeft.y
            , (clickBottomRight.x - clickTopLeft.x) + 1, (clickBottomRight.y - clickTopLeft.y) + 1
        );
    }
    
    override public function onKeyPress(key:Int)
    {
        if (key == Keys.Space)
        {
            autoTileRect(new Rectangle(
                0, 0,
                layer.data.length, layer.data[0].length
            ));
        }
    }

    public function autoTileRect(rect:Rectangle)
    {
        var res:Array<Array<TileData>> = [for (x in 0...rect.width.int()) [for (y in 0...rect.height.int()) new TileData()]];

        // building autotile result
        for (rowOffset in 0...rect.height.int()) {
            var row:Int = rowOffset + rect.y.int();
            for (colOffset in 0...rect.width.int()) {
                var col:Int = colOffset + rect.x.int();

                var section = getAutoTileSection(row, col);

                res[colOffset][rowOffset] = testTileset.retile(section);
            }
        }

        // pasting autotile result
		EDITOR.level.store("autotile");
        for (rowOffset in 0...rect.height.int()) {
            var row:Int = rowOffset + rect.y.int();
            for (colOffset in 0...rect.width.int()) {
                var col:Int = colOffset + rect.x.int();

                layer.data[col][row] = res[colOffset][rowOffset];
            }
        }

        // (marking editor as dirty)
        EDITOR.dirty();
    }

    private function getAutoTileSection(centerRow:Int, centerCol:Int)
    {
        var layerWidth:Int = layer.data.length;
        var layerHeight:Int = layer.data[0].length;

        var res:Array<Array<TileData>> = [for (x in 0...3) [for (y in 0...3) new TileData()]];
        for (dX in -1...1) {
            var col:Int = centerCol + dX;
            for (dY in -1...1) {
                var row:Int = centerRow + dY;
                if (row >= 0 && row < layerHeight && col >= 0 && col < layerWidth)
                    res[dX+1][dY+1] = layer.data[col][row];
                else
                    res[dX+1][dY+1] = new TileData(greyTile);
            }
        }

        return res;
    }

    override public function getIcon():String return 'value-color';
    override public function getName():String return 'AutoTile';
    override public function keyToolAlt():Int return 4;
    override public function keyToolShift():Int return 0;

    override public function getExtraInfo():String {
        if (!isClicking()) return "";

        var rect: Rectangle = getClickRect();
        var size: Vector = new Vector(rect.width, rect.height);
        return " " + (Math.abs(size.x)+1) + " x " + (Math.abs(size.y)+1);
    }
}