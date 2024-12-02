% contrastMultShaderExample.frag.txt and this file contrastMultShaderExampleSetup.m 
% are an example of a custom shader that multiplies the contrast of the element
% by some factor relative to some mean intensity. To try the example, make any
% visual element and set its property .shader as follows.
%
% element.shader.fileName = "contrastMultShaderExample.frag.txt";
% element.shader.setupCode = "contrastMultShaderExampleSetup";
% element.shader.setupVars.c = 2;
% element.shader.setupVars.m = 0.5;
%
% You can change the values for .shader.setupVars.c and .m above.


glUseProgram(n_shader);
glUniform1i(glGetUniformLocation(n_shader, 'texture'), 0);
glUniform1f(glGetUniformLocation(n_shader, 'contrastMult'), vars.c);
glUniform1f(glGetUniformLocation(n_shader, 'meanIntensity'), vars.m);