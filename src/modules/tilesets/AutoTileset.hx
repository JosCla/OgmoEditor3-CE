package modules.tilesets;

import util.Random;
import modules.tiles.TileLayer;
import modules.tiles.TileLayer.TileData;
import level.data.Layer;
import level.data.Level;

class AutoTileset
{
    public var level:Level;

    public var keyIndex:Int;
    public var keyLayer:String;

    public function new(level:Level) {
        this.level = level;

        // parse out which tiles are where
        for (i in 0...this.level.layers.length) {
            var currLayer:Layer = this.level.layers[i];
            if (Std.isOfType(currLayer, TileLayer)) {
                var tileLayer:TileLayer = cast currLayer;
                if (tileLayer.data[0][0].idx > 0) {
                    this.parseTiles(tileLayer);
                }
            }
        }
    }

    public function retile(surroundingTiles: Array<Array<TileData>>, rand:Random):TileData {return new TileData();}
    public function parseTiles(tileLayer:TileLayer):Void
    {
        this.keyIndex = tileLayer.data[0][0].idx;
        this.keyLayer = tileLayer.template.name.toLowerCase();
    }
}

