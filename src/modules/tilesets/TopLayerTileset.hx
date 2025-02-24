package modules.tilesets;

import modules.tiles.TileLayer;
import level.data.Level;
import modules.tiles.TileLayer.TileData;

class TopLayerTileset extends AutoTileset
{
    public var centerTile:TileData;
    public var upperTile:TileData;

    override function retile(surroundingTiles: Array<Array<TileData>>):TileData {
        if (surroundingTiles[1][1].isEmptyTile()) return surroundingTiles[1][1];
        if (surroundingTiles[1][0].isEmptyTile()) return this.upperTile;
        return this.centerTile;
    }

    override function parseTiles(collisionLayer:TileLayer):Void {
        super.parseTiles(collisionLayer);
        this.upperTile = collisionLayer.data[1][0].clone();
        this.centerTile = collisionLayer.data[1][1].clone();
    }
}