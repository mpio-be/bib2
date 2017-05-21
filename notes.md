
# TODO 
    customized map
    SNB breeders map
    caught parents map
    second clutches

# local
    require(sysmanager); push_github_all('bib2')
    

 # server
    require(sysmanager)
    install_github( "valcu/bib2"      ,auth_token = github_pat(),  dependencies = TRUE)
    install_shiny_ui('bib2', restartShiny = TRUE)   