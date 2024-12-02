siz = this.size;
meanIntensity = this.meanIntensity;
sigma = this.sigma;
numLevels = this.numLevels;
color = this.color;
temporalFrequency = this.temporalFrequency;
repeatInterval = this.repeatInterval;
addDisplay = this.addDisplay;
textureDims = this.textureDims;
nn_textures = this.nn_textures;
t_next = this.t_next;
isStarting = this.isStarting;
isEnding = this.isEnding;


%Don't draw in last object frame cause then there is no next frame.
if ~isEnding
    if temporalFrequency == 0
        %Static noise display...
        
        %Draw display to window to show in next frame.
        %Static display so use element_redraw instead of element_draw for efficiency.
        %Display starts showing at object frame 1 start (screen refresh) after this script runs in object frame 0.
        %element_redraw automatically applies all core display functionality.
        this = element_redraw(this, nn_textures(1), [], siz(2));
    else
        %Dynamic noise display...

        t = GetSecs;

        if repeatInterval < inf
            %Repeat -> get texture number to show next frame based on time from object start and temporal frequency, wrapped to repeat interval
            
            %mod = min 0 -> frame 1
            %mod = max repeatInterval -> max texture number made in open
            i_texture = floor(mod(t, repeatInterval)*temporalFrequency)+1;
            n_texture = nn_textures(i_texture);
        else
            %No repeat -> generate new texture at each change
            
            if isStarting
                %Initial value for next change time at start
                t_next = t+1/temporalFrequency;
            end
            
            if t > t_next
                %Due to change -> close current texture and make new texture

                Screen('Close', nn_textures)

                if addDisplay
                        if numLevels == inf
                            k = min(max(meanIntensity+sigma*randn(textureDims), -1), 1);
                        else
                            k = min(max(floor((meanIntensity+sigma*randn(textureDims))*numLevels)/(numLevels-1), -1), 1);
                        end
                    image = repmat(k, 1, 1, 3);
                else
                    if sigma == inf
                        if numLevels == inf
                            k = rand(textureDims);
                        else
                            k = floor(rand(textureDims)*numLevels)/(numLevels-1);
                        end
                    else
                        if numLevels == inf
                            k = min(max(meanIntensity+sigma*randn(textureDims), 0), 1);
                        else
                            k = min(max(floor((meanIntensity+sigma*randn(textureDims))*numLevels)/(numLevels-1), 0), 1);
                        end
                    end
                    image = repmat(k, 1, 1, 3).*repmat(reshape(color, 1, 1, 3), textureDims);
                end
                nn_textures = element_openTexture([], [], image);

                %Update time for next change based on temporal frequency.
                %Allow for possible dropped frames since prev change.
                t_next = t_next+ceil((t-t_next)*temporalFrequency)/temporalFrequency;
            end
            
            n_texture = nn_textures(1);
        end

        %Draw display to window show in next frame.
        %Dynamic display so use element_draw instead of element_redraw.
        this = element_draw(this, n_texture, [], siz(2));
    end
end


this.nn_textures = nn_textures;
this.t_next = t_next;