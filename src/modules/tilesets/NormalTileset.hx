package modules.tilesets;

import modules.tilesets.CollisionTypes.CollisionType;
import modules.tiles.TileLayer;
import modules.tiles.TileLayer.TileData;

class NormalTileset extends AutoTileset
{
    public var centerTile:TileData;
    public var upTile:TileData;
    public var downTile:TileData;
    public var leftTile:TileData;
    public var rightTile:TileData;
    public var upLeftTile:TileData;
    public var upRightTile:TileData;
    public var downLeftTile:TileData;
    public var downRightTile:TileData;

    public var spike:TileData;
    public var leftNub:TileData;
    public var rightNub:TileData;
    public var leftPlatform:TileData;
    public var rightPlatform:TileData;

    override function retile(surroundingTiles: Array<Array<TileData>>):TileData {
        var currCenterTile:TileData = surroundingTiles[1][1];
        var currCenterCollision:CollisionType = EDITOR.collisionTypes.getCollisionType(currCenterTile);
        if (currCenterCollision == CollisionType.Deadly) return spike;
        if (currCenterCollision == CollisionType.LeftNub) return leftNub;
        if (currCenterCollision == CollisionType.RightNub) return rightNub;
        if (currCenterCollision == CollisionType.LeftPlatform) return leftPlatform;
        if (currCenterCollision == CollisionType.RightPlatform) return rightPlatform;

        if (currCenterCollision != CollisionType.Solid) return currCenterTile;

        var currUpperTile:TileData = surroundingTiles[1][0];
        if (EDITOR.collisionTypes.getCollisionType(currUpperTile) != CollisionType.Solid) return this.upTile;
        return this.centerTile;
    }

    override function parseTiles(collisionLayer:TileLayer):Void {
        super.parseTiles(collisionLayer);

        this.upLeftTile = collisionLayer.data[1][0].clone();
        this.upTile = collisionLayer.data[2][0].clone();
        this.upRightTile = collisionLayer.data[3][0].clone();
        this.leftTile = collisionLayer.data[1][1].clone();
        this.centerTile = collisionLayer.data[2][1].clone();
        this.rightTile = collisionLayer.data[3][1].clone();
        this.downLeftTile = collisionLayer.data[1][2].clone();
        this.downTile = collisionLayer.data[2][2].clone();
        this.downRightTile = collisionLayer.data[3][2].clone();

        this.spike = collisionLayer.data[9][1].clone();
        this.leftNub = collisionLayer.data[1][4].clone();
        this.rightNub = collisionLayer.data[2][4].clone();
        this.leftPlatform = collisionLayer.data[3][4].clone();
        this.rightPlatform = collisionLayer.data[4][4].clone();
    }
}