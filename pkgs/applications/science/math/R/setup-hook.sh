addRLibPath () {
    addToSearchPath R_LIBS_SITE $1/library
}

addEnvHooks addRLibPath
