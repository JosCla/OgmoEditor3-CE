package level.editor.ui;

import rendering.Texture;

class AdjacentLevel
{
    public var tex:Texture;
    public var pos:Vector;

    public function new(tex:Texture, pos:Vector)
    {
        this.tex = tex;
        this.pos = pos;
    }
}