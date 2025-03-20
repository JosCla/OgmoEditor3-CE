package level.editor.ui;

import rendering.Texture;

class AdjacentLevel
{
    var tex:Texture;
    var pos:Vector;

    function new(tex:Texture, pos:Vector)
    {
        this.tex = tex;
        this.pos = pos;
    }
}