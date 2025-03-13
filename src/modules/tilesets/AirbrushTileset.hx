package modules.tilesets;

import util.Random;
import modules.tilesets.CollisionTypes.CollisionType;
import modules.tiles.TileLayer;
import modules.tiles.TileLayer.TileData;

class AirbrushTileset extends AutoTileset
{
    public var layerToTile:Array<Array<TileData>>;
    public var tileToLayer:Map<Int, Int>;

    override function retile(surroundingTiles: Array<Array<TileData>>, rand:Random):TileData {
        var depth:Int = surroundingTiles[0][0].idx;
        var cappedDepth:Int = Math.min(depth, layerToTile.length - 1).int();
        var newTile:TileData = layerToTile[cappedDepth][rand.nextInt(layerToTile[cappedDepth].length)];

        var prevTile:TileData = surroundingTiles[0][1];
        var prevDepth:Int = tileToLayer[prevTile.idx];

        if (prevDepth == null || prevDepth < cappedDepth) {
            return newTile;
        } else {
            return prevTile;
        }
    }

    override function parseTiles(tileLayer:TileLayer):Void {
        super.parseTiles(tileLayer);

        this.layerToTile = new Array<Array<TileData>>();
        this.tileToLayer = new Map<Int, Int>();

        var layer:Int = 0;
        while (true) {
            // if next layer is empty, leave
            if (layer + 1 >= tileLayer.data.length) break;
            if (tileLayer.data[layer + 1][0].idx <= 0) break;

            // else try to parse this layer
            var currLayer:Array<TileData> = new Array<TileData>();
            var row:Int = 0;
            while (true) {
                // if next tile is empty, leave
                if (row >= tileLayer.data[layer + 1].length) break;
                var currTile = tileLayer.data[layer + 1][row];
                if (currTile.idx <= 0) break;

                // else push a new possibility to this layer (and track this tile in the reverse lookup)
                currLayer.push(currTile.clone());
                if (tileToLayer[currTile.idx] == null)
                    tileToLayer[currTile.idx] = layer;

                row++;
            }
            this.layerToTile.push(currLayer);

            layer++;
        }
    }
}