%Giles Holland 2023


color = this.color;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
%---


%Run before all other objects each frame so that it draws behind them (background)
this = element_setFrameOrder(this, 'before');