package modules.tiles.tools;

import level.data.Layer;
import modules.tilesets.AutoTileset;
import modules.tilesets.TopLayerTileset;
import util.Random;
import modules.tiles.TileLayer.TileData;

class TileAutotileTool extends TileTool
{
    public var clickTopLeft:Vector = null;
    public var clickBottomRight:Vector = null;
    public var random:Random = new Random();

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
            var rect:Rectangle = new Rectangle(
                0, 0,
                layer.data.length, layer.data[0].length
            );

            if (OGMO.shift) {
                if (layerEditor.brush.length == 0) return;
                if (layerEditor.brush[0].length == 0) return;
                var brushData:TileData = layerEditor.brush[0][0];
                autoTileRectWithInd(rect, brushData.idx);
            } else {
                autoTileRect(rect);
            }
        }
    }

    public function autoTileRect(rect:Rectangle)
    {
        // first getting the autotile layer
        var autoTileLayer:TileLayer = null;
        for (i in 0...layer.level.layers.length) {
            var currLayer:Layer = layer.level.layers[i];
            if (currLayer.template.name.toLowerCase() == "autotile" && Std.isOfType(currLayer, TileLayer)) {
                autoTileLayer = cast currLayer;
                break;
            }
        }
        if (autoTileLayer == null) return;

        // building autotile result
        var res:Array<Array<TileData>> = [for (x in 0...rect.width.int()) [for (y in 0...rect.height.int()) layer.data[rect.x.int() + x][rect.y.int() + y]]];
        var autoTilerMap:Map<Int, AutoTileset> = new Map<Int, AutoTileset>();
        for (rowOffset in 0...rect.height.int()) {
            var row:Int = rowOffset + rect.y.int();
            for (colOffset in 0...rect.width.int()) {
                var col:Int = colOffset + rect.x.int();

                var section = getAutoTileSection(row, col);
                var autoTileset = getAutoTileset(autoTileLayer, row, col, autoTilerMap);
                if (autoTileset == null) continue;

                res[colOffset][rowOffset] = autoTileset.retile(section);
            }
        }

        // pasting autotile result
		EDITOR.level.store("autotile");
        for (rowOffset in 0...rect.height.int()) {
            var row:Int = rowOffset + rect.y.int();
            for (colOffset in 0...rect.width.int()) {
                var col:Int = colOffset + rect.x.int();

                layer.data[col][row].copy(res[colOffset][rowOffset]);
            }
        }

        // (marking editor as dirty)
        EDITOR.dirty();
    }

    public function autoTileRectWithInd(rect:Rectangle, keyIdx:Int)
    {
        // trying to build an autotiler from the provided index
        var autoTileset:AutoTileset = EDITOR.getAutoTileset(keyIdx);
        if (autoTileset == null) return;

        // building autotile result
        var res:Array<Array<TileData>> = [for (x in 0...rect.width.int()) [for (y in 0...rect.height.int()) layer.data[rect.x.int() + x][rect.y.int() + y]]];
        for (rowOffset in 0...rect.height.int()) {
            var row:Int = rowOffset + rect.y.int();
            for (colOffset in 0...rect.width.int()) {
                var col:Int = colOffset + rect.x.int();
                var section = getAutoTileSection(row, col);
                res[colOffset][rowOffset] = autoTileset.retile(section);
            }
        }

        // pasting autotile result
		EDITOR.level.store("autotile");
        for (rowOffset in 0...rect.height.int()) {
            var row:Int = rowOffset + rect.y.int();
            for (colOffset in 0...rect.width.int()) {
                var col:Int = colOffset + rect.x.int();

                layer.data[col][row].copy(res[colOffset][rowOffset]);
            }
        }

        // (marking editor as dirty)
        EDITOR.dirty();
    }

    private function getAutoTileset(autoTileLayer:TileLayer, row:Int, col:Int, autoTilerMap:Map<Int, AutoTileset>):AutoTileset
    {
        var keyIdx:Int = autoTileLayer.data[col][row].idx;
        if (keyIdx < 0) return null;

        // checking if we've already cached this autotileset
        if (autoTilerMap[keyIdx] != null) return autoTilerMap[keyIdx];

        // trying to recreate it if we haven't already
        var newAutoTileset:AutoTileset = EDITOR.getAutoTileset(keyIdx);
        if (newAutoTileset != null) {
            autoTilerMap[keyIdx] = newAutoTileset;
        }
        return newAutoTileset;
    }

    private function getAutoTileSection(centerRow:Int, centerCol:Int)
    {
        var layerWidth:Int = layer.data.length;
        var layerHeight:Int = layer.data[0].length;

        var res:Array<Array<TileData>> = [for (x in 0...3) [for (y in 0...3) new TileData()]];
        for (dX in -1...2) {
            var col:Int = centerCol + dX;
            for (dY in -1...2) {
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
    override public function keyToolAlt():Int return 6;
    override public function keyToolShift():Int return 6;

    override public function getExtraInfo():String {
        if (!isClicking()) return "";

        var rect: Rectangle = getClickRect();
        var size: Vector = new Vector(rect.width, rect.height);
        return " " + (Math.abs(size.x)+1) + " x " + (Math.abs(size.y)+1);
    }
}