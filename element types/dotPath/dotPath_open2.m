color = this.color;
textureSize = this.textureSize;


%Request object background color = transparent.
%Transparent version of dot color prevents artifacts if adjacent pixels are blended, e.g. if rotation.
c = [color 0];
this = element_setBackColor(this, c);

%Open texture for drawing, sized to fit display, background = object background color
n_texture = element_openTexture(textureSize);


this.n_texture = n_texture;