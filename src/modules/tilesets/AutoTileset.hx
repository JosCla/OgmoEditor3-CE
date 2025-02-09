package modules.tilesets;

import modules.tiles.TileLayer;
import modules.tiles.TileLayer.TileData;
import level.data.Layer;
import level.data.Level;

class AutoTileset
{
    public var level:Level;

    public var centerTile:TileData;
    public var upperTile:TileData;

    public function new(level:Level) {
        this.level = level;

        // parse out which tiles are where
        // var allLayers:String = "";
        for (i in 0...this.level.layers.length) {
            var currLayer:Layer = this.level.layers[i];
            // allLayers += currLayer.template.name.toLowerCase() + ": " + Type.getClassName(Type.getClass(currLayer));
            if (currLayer.template.name.toLowerCase() == "collision" && Std.isOfType(currLayer, TileLayer)) {
                this.parseTiles(cast (currLayer, TileLayer));
            }
        }

            // Popup.open("hi", "entity", allLayers, ["ok"]);

        Popup.open("gaming", "entity", "Hey there! " + centerTile.idx + " " + upperTile.idx, ["ok"]);
    }

    public function retile(surroundingTiles: Array<Array<TileData>>) {
        if (surroundingTiles[1][0].isEmptyTile()) {
            return this.upperTile;
        } else {
            return this.centerTile;
        }
    }

    public function parseTiles(collisionLayer:TileLayer) {
        this.upperTile = collisionLayer.data[0][0];
        this.centerTile = collisionLayer.data[0][1];
    }
}

