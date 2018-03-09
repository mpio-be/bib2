
# TODO 
    customized map
    SNB breeders map
    caught parents map
    second clutches

    Interface for entering NEST Data (AT suggestions)
    When entering something in the nest_stage column it easily happens, that you press the down-arrow instead of the enter-button. Then you get the 
    next auto-filter nest_stage value, e.g. NOTA instead of YOUNG. This is a fatal mistake, because then the nest disappears from your to-do map and 
    never turns up again and you will miss this nest. 
    So it would be better to have NOTA in the first place of the auto-filter and YOUNG in the last. ✔
    
    By the way, what means WE in the auto-filter of nest_stage? ✔

    If nest_stage is Eggs, there should be a number in the eggs-column and not in the chicks-column (often the number of eggs is by mistake entered 
        in the chicks-column.) There should be a warning.
    If nest_stage is Young, there should be a number in the chicks -column (often the number of young is by mistake entered in the eggs-column.) 
    There should be a warning.

    Nest map
    stage age is quite helpful, but as there are many numbers on the map which are overlapping, in many cases you can’t read the 
    nest box number anymore. In cases where stage age is not needed, it should not appear. This is the case when nest_stage is NOTA.
    Days to hatch should disappear from the map as soon as the chicks have hatched.
    If there is a second clutch in a certain box, stage age and days to hatch should start from the new nest and not continue from the first nest. 



# local
    require(sysmanager); push_github_all('bib2')
    

 # server
    require(sysmanager)
    install_github( "valcu/bib2"      ,auth_token = github_pat(),  dependencies = TRUE)
    install_shiny_ui('bib2', restartShiny = TRUE)   