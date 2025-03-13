package modules.tilesets;

import util.Random;
import modules.tilesets.CollisionTypes.CollisionType;
import modules.tiles.TileLayer;
import modules.tiles.TileLayer.TileData;

class TopLayerTileset extends AutoTileset
{
    public var centerTile:TileData;
    public var upperTile:TileData;

    override function retile(surroundingTiles: Array<Array<TileData>>, rand:Random):TileData {
        var currCenterTile:TileData = surroundingTiles[1][1];
        var currUpperTile:TileData = surroundingTiles[1][0];

        if (EDITOR.collisionTypes.getCollisionType(currCenterTile) != CollisionType.Solid) return currCenterTile;
        if (EDITOR.collisionTypes.getCollisionType(currUpperTile) != CollisionType.Solid) return this.upperTile;
        return this.centerTile;
    }

    override function parseTiles(tileLayer:TileLayer):Void {
        super.parseTiles(tileLayer);
        this.upperTile = tileLayer.data[1][0].clone();
        this.centerTile = tileLayer.data[1][1].clone();
    }
}