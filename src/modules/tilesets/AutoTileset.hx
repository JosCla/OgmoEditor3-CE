package modules.tilesets;

import modules.tiles.TileLayer;
import modules.tiles.TileLayer.TileData;
import level.data.Layer;
import level.data.Level;

class AutoTileset
{
    public var level:Level;

    public var keyIndex:Int;

    public function new(level:Level) {
        this.level = level;

        // parse out which tiles are where
        for (i in 0...this.level.layers.length) {
            var currLayer:Layer = this.level.layers[i];
            if (currLayer.template.name.toLowerCase() == "collision" && Std.isOfType(currLayer, TileLayer)) {
                this.parseTiles(cast (currLayer, TileLayer));
            }
        }
    }

    public function retile(surroundingTiles: Array<Array<TileData>>):TileData {return null;}
    public function parseTiles(collisionLayer:TileLayer):Void
    {
        this.keyIndex = collisionLayer.data[0][0].idx;
    }
}

