package modules.tiles.tools;

import modules.tiles.TileLayer.TileData;
import level.editor.Tool;
import util.Random;

class TileTool extends Tool
{
	public var layerEditor(get, never):TileLayerEditor;
	function get_layerEditor():TileLayerEditor return cast EDITOR.currentLayerEditor;

	public var layer(get, never):TileLayer;
	function get_layer():TileLayer return cast EDITOR.level.currentLayer;
	
	public function brushAt(brush:Array<Array<TileData>>, xOrigin:Int, yOrigin:Int, xEnd:Int, yEnd:Int, x:Int, y:Int, ?random:Random, isFlood:Bool = false):TileData
	{
		if (random == null)
		{
            if (xOrigin > xEnd) {
                var tempX = xEnd;
                xEnd = xOrigin;
                xOrigin = tempX;
            } 
            
            if (yOrigin > yEnd) {
                var tempY = yEnd;
                yEnd = yOrigin;
                yOrigin = tempY;
            }

            var doSpecial = !OGMO.ctrl && !OGMO.shift && !OGMO.alt && !isFlood;
            var onlyReplaceEmpty = OGMO.tab;

            var atX;
            if (doSpecial && brush.length == 3) {
                if (xOrigin == xEnd) atX = 1;
                else if (x == xOrigin) atX = 0;
                else if (x == xEnd) atX = 2;
                else atX = 1;
            } else {
                atX = (x - xOrigin) % brush.length;
                if (atX < 0) atX += brush.length;
            }
			
            var atY;
            if (doSpecial && brush[atX].length == 3) {
                if (yOrigin == yEnd) atY = 1;
                else if (y == yOrigin) atY = 0;
                else if (y == yEnd) atY = 2;
                else atY = 1;
            } else {
                atY = (y - yOrigin) % brush[atX].length; 
			    if (atY < 0) atY += brush[atX].length;
            }

            if (onlyReplaceEmpty && !layer.data[x][y].equals(new TileData(TileData.EMPTY_TILE))) {
                return new TileData(TileData.NONEXIST_TILE);
            }
					
			return brush[atX][atY];
		}
		else return random.nextChoice2D(brush);
	}
	
	public function brushRandom(brush:Array<Array<TileData>>):TileData
	{
		return brush[Math.floor(Math.random() * brush.length)][Math.floor(Math.random() * brush[0].length)];
	}

	override public function onKeyPress(key:Int)
	{
		if (OGMO.keyIsCtrl(key)) return;
		switch (key)
		{
			case H:
				for (column in layerEditor.brush) for (tile in column) tile.doFlip(true);
				layerEditor.flipBrush(true);
				EDITOR.overlayDirty();
			case V:
				for (column in layerEditor.brush) for (tile in column) tile.doFlip(false);
				layerEditor.flipBrush(false);
				EDITOR.overlayDirty();
			case R:
				for (column in layerEditor.brush) for (tile in column) tile.doRotate(true);
				layerEditor.rotateBrush(true);
				EDITOR.overlayDirty();
			case E:
				for (column in layerEditor.brush) for (tile in column) tile.doRotate(false);
				layerEditor.rotateBrush(false);
				EDITOR.overlayDirty();
		}
	}
}
