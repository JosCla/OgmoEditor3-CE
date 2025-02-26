package modules.tilesets;

import level.data.Layer;
import modules.tiles.TileLayer;
import level.data.Level;

enum CollisionType {
    Empty;
    Solid;
    Key;
    SolidPlatform;
    SemisolidPlatform;
    Deadly;
    LeftNub;
    RightNub;
    LeftPlatform;
    RightPlatform;
    Other;
}

class CollisionTypes {
    private var atlasLevel:Level;
    private var collisionTypeMap:Map<Int, CollisionType> = new Map<Int, CollisionType>();

    public function new() {}

    public function initialize(atlasLevel:Level):Void {
        this.atlasLevel = atlasLevel;

        for (i in 0...this.atlasLevel.layers.length) {
            var currLayer:Layer = this.atlasLevel.layers[i];
            if (currLayer.template.name.toLowerCase() == "collision" && Std.isOfType(currLayer, TileLayer)) {
                this.parseAtlas(cast currLayer);
            }
        }
    }

    public function getCollisionType(tileData:TileData):CollisionType {
        return getCollisionTypeFromIdx(tileData.idx);
    }

    public function getCollisionTypeFromIdx(idx:Int):CollisionType {
        if (idx < 0) return CollisionType.Empty;
        if (collisionTypeMap[idx] == null) return CollisionType.Solid;
        return collisionTypeMap[idx];
    }

    private function parseAtlas(collisionLayer:TileLayer):Void {
        this.collisionTypeMap = new Map<Int, CollisionType>();

        parseRow(collisionLayer, 0, CollisionType.Key);
        parseRow(collisionLayer, 1, CollisionType.SolidPlatform);
        parseRow(collisionLayer, 2, CollisionType.SemisolidPlatform);
        parseRow(collisionLayer, 3, CollisionType.Deadly);
        parseRow(collisionLayer, 4, CollisionType.Deadly);
        parseRow(collisionLayer, 5, CollisionType.Other);
        parseRow(collisionLayer, 6, CollisionType.Other);
        parseRow(collisionLayer, 7, CollisionType.LeftNub);
        parseRow(collisionLayer, 8, CollisionType.RightNub);
        parseRow(collisionLayer, 9, CollisionType.Other);
        parseRow(collisionLayer, 10, CollisionType.Other);
        parseRow(collisionLayer, 11, CollisionType.LeftPlatform);
        parseRow(collisionLayer, 12, CollisionType.RightPlatform);
        parseRow(collisionLayer, 13, CollisionType.Other);
        parseRow(collisionLayer, 14, CollisionType.Other);
        parseRow(collisionLayer, 15, CollisionType.Other);
        parseRow(collisionLayer, 16, CollisionType.Other);
        parseRow(collisionLayer, 17, CollisionType.Other);
        parseRow(collisionLayer, 18, CollisionType.Other);
        parseRow(collisionLayer, 19, CollisionType.Other);
        parseRow(collisionLayer, 20, CollisionType.Other);
        parseRow(collisionLayer, 21, CollisionType.Other);
    }

    private function parseRow(collisionLayer:TileLayer, row:Int, rowType:CollisionType):Void {
        for (col in 0...collisionLayer.data.length) {
            var currData:TileData = collisionLayer.data[col][row];
            if (currData.idx >= 0) collisionTypeMap[currData.idx] = rowType;
        }
    }

    public static function platformOrSolid(collisionType:CollisionType):Bool {
        return (collisionType == CollisionType.Solid || collisionType == CollisionType.SolidPlatform || collisionType == CollisionType.SemisolidPlatform);
    }
}