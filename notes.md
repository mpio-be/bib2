
# TODO 
    second clutches

# local
    require(sysmanager); push_github_all('bib2')

# server
    require(sysmanager);install_github('valcu/bib2', auth_token = github_pat(TRUE) )
    restart_shinyServer(readline())

    