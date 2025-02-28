package modules.tilesets;

import util.Random;
import modules.tilesets.CollisionTypes.CollisionType;
import modules.tiles.TileLayer;
import modules.tiles.TileLayer.TileData;

class NormalTileset extends AutoTileset
{
    public var centerTile:TileData;
    public var centerTileVariation:TileData;
    public var upTile:TileData;
    public var downTile:TileData;
    public var leftTile:TileData;
    public var rightTile:TileData;
    public var upLeftTile:TileData;
    public var upRightTile:TileData;
    public var downLeftTile:TileData;
    public var downRightTile:TileData;

    public var horizLeftTile:TileData;
    public var horizCenterTile:TileData;
    public var horizRightTile:TileData;

    public var vertUpTile:TileData;
    public var vertCenterTile:TileData;
    public var vertDownTile:TileData;

    public var upLeftInnerTile:TileData;
    public var upRightInnerTile:TileData;
    public var downLeftInnerTile:TileData;
    public var downRightInnerTile:TileData;

    public var leftSemisolid:TileData;
    public var centerSemisolid:TileData;
    public var rightSemisolid:TileData;

    public var leftSolid:TileData;
    public var centerSolid:TileData;
    public var rightSolid:TileData;

    public var spike:TileData;
    public var leftSpike:TileData;
    public var rightSpike:TileData;
    public var downSpike:TileData;

    public var leftNub:TileData;
    public var rightNub:TileData;
    public var leftPlatform:TileData;
    public var rightPlatform:TileData;

    override function retile(surroundingTiles: Array<Array<TileData>>, rand:Random):TileData {
        var currCenterTile:TileData = surroundingTiles[1][1];
        var currCenterCollision:CollisionType = EDITOR.collisionTypes.getCollisionType(currCenterTile);
        var currUpTile:CollisionType = EDITOR.collisionTypes.getCollisionType(surroundingTiles[1][0]);
        var currDownTile:CollisionType = EDITOR.collisionTypes.getCollisionType(surroundingTiles[1][2]);
        var currLeftTile:CollisionType = EDITOR.collisionTypes.getCollisionType(surroundingTiles[0][1]);
        var currRightTile:CollisionType = EDITOR.collisionTypes.getCollisionType(surroundingTiles[2][1]);

        if (currCenterCollision == CollisionType.Deadly) {
            if (CollisionTypes.platformOrSolid(currDownTile)) return spike;
            if (currUpTile == CollisionType.Solid) return downSpike;
            if (currLeftTile == CollisionType.Solid) return rightSpike;
            if (currRightTile == CollisionType.Solid) return leftSpike;
            return spike;
        }
        if (currCenterCollision == CollisionType.LeftNub) return leftNub;
        if (currCenterCollision == CollisionType.RightNub) return rightNub;
        if (currCenterCollision == CollisionType.LeftPlatform) return leftPlatform;
        if (currCenterCollision == CollisionType.RightPlatform) return rightPlatform;
        if (currCenterCollision == CollisionType.PortalBlock) return currCenterTile;
        if (currCenterCollision == CollisionType.SolidPlatform) {
            if (CollisionTypes.platformOrSolid(currLeftTile) && CollisionTypes.platformOrSolid(currRightTile)) return centerSolid;
            if (CollisionTypes.platformOrSolid(currLeftTile)) return rightSolid;
            if (CollisionTypes.platformOrSolid(currRightTile)) return leftSolid;
            return centerSolid;
        } else if (currCenterCollision == CollisionType.SemisolidPlatform) {
            if (CollisionTypes.platformOrSolid(currLeftTile) && CollisionTypes.platformOrSolid(currRightTile)) return centerSemisolid;
            if (CollisionTypes.platformOrSolid(currLeftTile)) return rightSemisolid;
            if (CollisionTypes.platformOrSolid(currRightTile)) return leftSemisolid;
            return centerSemisolid;
        }

        if (currCenterCollision != CollisionType.Solid) return currCenterTile;

        if (currUpTile != CollisionType.Solid) {
            if (currLeftTile != CollisionType.Solid && currDownTile != CollisionType.Solid) return horizLeftTile;
            if (currRightTile != CollisionType.Solid && currDownTile != CollisionType.Solid) return horizRightTile;
            if (currDownTile != CollisionType.Solid) return horizCenterTile;
            if (currLeftTile != CollisionType.Solid && currRightTile != CollisionType.Solid) return vertUpTile;
            if (currLeftTile != CollisionType.Solid) return upLeftTile;
            if (currRightTile != CollisionType.Solid) return upRightTile;
            return upTile;
        } else if (currDownTile != CollisionType.Solid) {
            // if (currUpTile != CollisionType.Solid) return horizCenterTile;
            if (currLeftTile != CollisionType.Solid && currRightTile != CollisionType.Solid) return vertDownTile;
            if (currLeftTile != CollisionType.Solid) return downLeftTile;
            if (currRightTile != CollisionType.Solid) return downRightTile;
            return downTile;
        } else if (currLeftTile != CollisionType.Solid) {
            if (currRightTile != CollisionType.Solid) return vertCenterTile;
            return leftTile;
        } else if (currRightTile != CollisionType.Solid) {
            return rightTile;
        } else {
            var currUpLeftTile:CollisionType = EDITOR.collisionTypes.getCollisionType(surroundingTiles[0][0]);
            var currUpRightTile:CollisionType = EDITOR.collisionTypes.getCollisionType(surroundingTiles[2][0]);
            var currDownLeftTile:CollisionType = EDITOR.collisionTypes.getCollisionType(surroundingTiles[0][2]);
            var currDownRightTile:CollisionType = EDITOR.collisionTypes.getCollisionType(surroundingTiles[2][2]);
            if (currUpLeftTile != CollisionType.Solid) return upLeftInnerTile;
            if (currUpRightTile != CollisionType.Solid) return upRightInnerTile;
            if (currDownLeftTile != CollisionType.Solid) return downLeftInnerTile;
            if (currDownRightTile != CollisionType.Solid) return downRightInnerTile;
        }

        if (rand.nextInt(19.0) % 20 == 0) return this.centerTileVariation;
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
        this.centerTileVariation = collisionLayer.data[5][1].clone();

        this.vertUpTile = collisionLayer.data[7][0].clone();
        this.vertCenterTile = collisionLayer.data[7][1].clone();
        this.vertDownTile = collisionLayer.data[7][2].clone();

        this.horizLeftTile = collisionLayer.data[1][3].clone();
        this.horizCenterTile = collisionLayer.data[2][3].clone();
        this.horizRightTile = collisionLayer.data[3][3].clone();

        this.leftSolid = collisionLayer.data[4][3].clone();
        this.centerSolid = collisionLayer.data[5][3].clone();
        this.rightSolid = collisionLayer.data[6][3].clone();

        this.leftSemisolid = collisionLayer.data[7][3].clone();
        this.centerSemisolid = collisionLayer.data[8][3].clone();
        this.rightSemisolid = collisionLayer.data[9][3].clone();

        this.upLeftInnerTile = collisionLayer.data[4][0].clone();
        this.upRightInnerTile = collisionLayer.data[6][0].clone();
        this.downLeftInnerTile = collisionLayer.data[4][2].clone();
        this.downRightInnerTile = collisionLayer.data[6][2].clone();

        this.spike = collisionLayer.data[9][1].clone();
        this.leftSpike = collisionLayer.data[8][1].clone();
        this.rightSpike = collisionLayer.data[10][1].clone();
        this.downSpike = collisionLayer.data[9][2].clone();

        this.leftNub = collisionLayer.data[1][4].clone();
        this.rightNub = collisionLayer.data[2][4].clone();
        this.leftPlatform = collisionLayer.data[3][4].clone();
        this.rightPlatform = collisionLayer.data[4][4].clone();
    }
}