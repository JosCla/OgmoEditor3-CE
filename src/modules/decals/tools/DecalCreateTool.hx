package modules.decals.tools;

import level.data.Value;

class DecalCreateTool extends DecalTool
{
	public var canPreview:Bool;
	public var previewAt:Vector = new Vector();
	public var scale:Vector = new Vector(1, 1);
	public var origin:Vector = new Vector(0.5, 0.5);
	public var created:Decal = null;

	public var deleting:Bool = false;
	public var firstDelete:Bool = false;
	public var lastDeletePos:Vector = new Vector();
    public var useTileGrid:Bool = false;
	public var lastMouseDownPos:Vector = new Vector();

	override public function drawOverlay()
	{
		if (layerEditor.brush != null && created == null && !deleting && canPreview && (!OGMO.shift))
		{
			EDITOR.overlay.drawTexture(previewAt.x, previewAt.y, layerEditor.brush, layerEditor.brush.center, scale);
		}
	}

	override public function activated()
	{
		canPreview = false;
		scale = new Vector(1, 1);
		lastMouseDownPos = null;
	}

	override public function onMouseLeave()
	{
		canPreview = false;
	}

	override public function onMouseDown(pos:Vector)
	{
		deleting = false;

		if (layerEditor.brush == null) return;
		if (useTileGrid) Ogmo.editor.getTileLayer().snapToGrid(pos, pos); 
        else layer.snapToGrid(pos, pos); 

		lastMouseDownPos = pos;

		EDITOR.level.store("create decal");
		EDITOR.locked = true;
		EDITOR.dirty();

		var path = js.node.Path.relative((cast layerEditor.template:DecalLayerTemplate).folder, layerEditor.brush.path);
		var values = [for (template in (cast layerEditor.template:DecalLayerTemplate).values) new Value(template)];
		created = new Decal(pos, path, layerEditor.brush, origin, scale, 0, values);
		layer.decals.push(created);

		resetCreatedPosition(pos);

		if (OGMO.ctrl)
			layerEditor.selected.push(created);
		else
			layerEditor.selected = [created];

		layerEditor.selectedChanged = true;
	}

	override public function onMouseUp(pos:Vector)
	{
		if (created != null)
		{
			created = null;
			EDITOR.locked = false;

			//if (OGMO.shift)
			//	EDITOR.toolBelt.setTool(0);
		}
	}

	override public function onRightDown(pos:Vector)
	{
        if (layerEditor.brush != null) {
            layerEditor.brush = null;
            EDITOR.toolBelt.setTool(0);
        } else {
            created = null;
            deleting = true;
            lastDeletePos = pos;
            EDITOR.locked = true;
    
            doDelete(pos);
        }
	}

	override public function onRightUp(pos:Vector)
	{
		deleting = false;
		EDITOR.locked = false;
	}

	public function doDelete(pos:Vector)
	{
		var hit = layer.getAt(pos);

		if (hit.length > 0)
		{
			if (!firstDelete)
			{
				firstDelete = true;
				EDITOR.level.store("delete decals");
			}

			layerEditor.remove(hit[hit.length - 1]);
			EDITOR.dirty();
		}
	}

	override public function onMouseMove(pos:Vector)
	{
		if (created != null)
		{
			resetCreatedPosition(pos);
		}
		else if (deleting)
		{
			if (!pos.equals(lastDeletePos))
			{
				pos.clone(lastDeletePos);
				doDelete(pos);
			}
		}
		else if (layerEditor.brush != null)
		{

			if (useTileGrid) Ogmo.editor.getTileLayer().snapToGrid(pos, pos); 
            else layer.snapToGrid(pos, pos); 

            if (!pos.equals(previewAt)) {
                canPreview = true;
                previewAt = pos;
                EDITOR.overlayDirty();
            }
		}
	}

	private function resetCreatedPosition(pos:Vector)
	{
		if (useTileGrid) Ogmo.editor.getTileLayer().snapToGrid(pos, pos); 
        else layer.snapToGrid(pos, pos); 

		if (OGMO.shift)
		{
			var newPos:Vector = new Vector(
				Math.min(pos.x.int(), lastMouseDownPos.x.int()),
				Math.min(pos.y.int(), lastMouseDownPos.y.int())
			);
			var newScale:Vector = new Vector(
				Math.abs(pos.x.int() - lastMouseDownPos.x.int()) / created.texture.width,
				Math.abs(pos.y.int() - lastMouseDownPos.y.int()) / created.texture.height
			);

			newPos = newPos.add(new Vector(
				created.texture.width * 0.5 * newScale.x,
				created.texture.height * 0.5 * newScale.y
			));
			newPos = new Vector(Math.floor(newPos.x), Math.floor(newPos.y));

			if (!newPos.equals(created.position) || !newScale.equals(scale))
			{
				newPos.clone(created.position);
				newScale.clone(created.scale);
				EDITOR.dirty();
			}
		}
		else
		{
			if (!pos.equals(created.position))
			{
				pos.clone(created.position);
				EDITOR.dirty();
			}
		}
	}

	override public function onKeyPress(key:Int)
	{
		if (key == Keys.H)
		{
			if ((cast layerEditor.template : DecalLayerTemplate).scaleable)
			{
				scale.x = -scale.x;
				EDITOR.dirty();
			}
		}
		else if (key == Keys.V)
		{
			if ((cast layerEditor.template : DecalLayerTemplate).scaleable)
			{
				scale.y = -scale.y;
				EDITOR.dirty();
			}
		}
        else if (key == Keys.O) {
            useTileGrid = !useTileGrid;
        }
		// TODO - Prep for UX overhaul PR!
		else if (key == Keys.B)
		{
			EDITOR.level.store("move decal to back");
			for (decal in layerEditor.selected) moveDecalToBack(decal);
			EDITOR.dirty();
		}
		else if (key == Keys.F)
		{
			EDITOR.level.store("move decal to front");
			for (decal in layerEditor.selected) moveDecalToFront(decal);
			EDITOR.dirty();
		}
		else if (key == Keys.Shift)
		{
			EDITOR.overlayDirty();
		}
	}

    override public function onScroll(isUp:Bool) 
    {
        if (layerEditor.brush == null) return;

        var palettePanel:Dynamic = layerEditor.palettePanel;
        var subdirectory:Dynamic = palettePanel.subdirectory;
        if (subdirectory == null) subdirectory = (cast layerEditor.template : DecalLayerTemplate).files;
        var textures:Array<Dynamic> = subdirectory.textures;

        if (textures.length == 0) return;

        var currentIndex = textures.indexOf(layerEditor.brush);
        currentIndex += isUp? 1 : -1;
        if (currentIndex >= textures.length) currentIndex = 0;
        else if (currentIndex < 0) currentIndex = textures.length - 1;

        layerEditor.brush = textures[currentIndex];
        EDITOR.overlayDirty();
    }

	function moveDecalToBack(decal:Decal)
	{
		var index = layer.decals.indexOf(decal);
		if (index < 0) return;
		layer.decals.splice(index, 1);
		layer.decals.unshift(decal);
	}

	function moveDecalToFront(decal:Decal)
	{
		var index = layer.decals.indexOf(decal);
		if (index < 0) return;
		layer.decals.splice(index, 1);
		layer.decals.push(decal);
	}

	override public function getIcon():String return "entity-create";
	override public function getName():String return "Create";

    override public function useScrolling():Bool return true;

}
