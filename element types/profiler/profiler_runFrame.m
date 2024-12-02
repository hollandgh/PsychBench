if this.profileWholeTrial
    %Undocumented
    
    this = element_end(this);
else
    %Profile during element run
    
    if this.isStarting        
        profile on
    elseif this.isEnding        
        profile off
    end
end